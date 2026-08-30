from pathlib import Path

from scapy.all import Ether, IP, TCP, Raw, wrpcap

from src.dpi_engine.pcap_processor import PCAPProcessor


def make_packet(host, destination, source_port):
    payload = (
        f"GET / HTTP/1.1\r\n"
        f"Host: {host}\r\n"
        f"Connection: close\r\n"
        f"\r\n"
    ).encode()

    return (
        Ether()
        / IP(src="192.168.1.10", dst=destination)
        / TCP(sport=source_port, dport=80)
        / Raw(load=payload)
    )


def test_pcap_processing(tmp_path):
    pcap_file = Path(tmp_path) / "test.pcap"

    packets = [
        make_packet("www.youtube.com", "1.1.1.1", 50000),
        make_packet("github.com", "2.2.2.2", 50001),
        make_packet("example.com", "3.3.3.3", 50002),
    ]

    wrpcap(str(pcap_file), packets)

    processor = PCAPProcessor()
    stats = processor.process_file(pcap_file)

    assert stats["total_packets"] == 3
    assert stats["blocked_packets"] == 1
    assert stats["forwarded_packets"] == 2
    assert stats["flows"] == 3

    assert stats["applications"]["youtube"] == 1
    assert stats["applications"]["github"] == 1
    assert stats["applications"]["other"] == 1
