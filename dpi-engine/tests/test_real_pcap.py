from pathlib import Path

from src.dpi_engine.pcap_processor import PCAPProcessor


def test_real_pcap_file():
    pcap_file = Path("tests/data/test_dpi.pcap")

    assert pcap_file.exists()

    processor = PCAPProcessor()
    stats = processor.process_file(pcap_file)

    assert stats["total_packets"] == 3
    assert stats["blocked_packets"] == 1
    assert stats["forwarded_packets"] == 2
    assert stats["flows"] == 3
