from scapy.layers.dns import DNS, DNSQR


class DNSExtractor:

    @staticmethod
    def extract_query(packet):
        if not packet.haslayer(DNS):
            return None

        dns = packet[DNS]

        if not dns.qd:
            return None

        question = dns.qd

        if not question.haslayer(DNSQR):
            return None

        qname = question.qname

        if isinstance(qname, bytes):
            qname = qname.decode(
                "ascii",
                errors="ignore"
            )

        return qname.rstrip(".").lower() or None
