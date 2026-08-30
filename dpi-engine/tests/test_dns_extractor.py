from scapy.all import Ether, IP, UDP
from scapy.layers.dns import DNS, DNSQR

from src.dpi_engine.dns_extractor import DNSExtractor


def make_dns_packet(host):
    return (
        Ether()
        / IP(src="192.168.1.10", dst="8.8.8.8")
        / UDP(sport=50000, dport=53)
        / DNS(
            rd=1,
            qd=DNSQR(
                qname=host
            )
        )
    )


def test_dns_query_extraction():
    packet = make_dns_packet(
        "www.youtube.com."
    )

    result = DNSExtractor.extract_query(packet)

    assert result == "www.youtube.com"


def test_non_dns_packet():
    packet = (
        Ether()
        / IP(src="192.168.1.10", dst="8.8.8.8")
        / UDP(sport=50000, dport=443)
    )

    assert DNSExtractor.extract_query(packet) is None
