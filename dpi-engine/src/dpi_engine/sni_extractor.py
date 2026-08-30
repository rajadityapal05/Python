import re

from scapy.layers.inet import TCP


class SNIExtractor:

    @staticmethod
    def extract_http_host(packet):
        if not packet.haslayer(TCP):
            return None

        payload = bytes(packet[TCP].payload)

        if not payload:
            return None

        text = payload.decode("latin1", errors="ignore")

        match = re.search(
            r"\r?\nHost:\s*([^\r\n]+)",
            text,
            re.IGNORECASE
        )

        if match:
            return match.group(1).strip().lower()

        return None
