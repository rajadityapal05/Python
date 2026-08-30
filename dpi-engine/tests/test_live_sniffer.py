from scapy.all import Ether, IP, TCP, Raw

from src.dpi_engine.live_sniffer import LiveSniffer


def make_packet():
    payload = (
        "GET / HTTP/1.1\r\n"
        "Host: www.youtube.com\r\n"
        "Connection: close\r\n"
        "\r\n"
    ).encode()

    return (
        Ether()
        / IP(src="192.168.1.10", dst="1.1.1.1")
        / TCP(sport=50000, dport=80)
        / Raw(load=payload)
    )


def test_live_sniffer_process_packet():
    sniffer = LiveSniffer()

    sniffer.process_packet(make_packet())

    stats = sniffer.engine.get_statistics()

    assert stats["total_packets"] == 1
    assert stats["blocked_packets"] == 1
    assert stats["flows"] == 1
