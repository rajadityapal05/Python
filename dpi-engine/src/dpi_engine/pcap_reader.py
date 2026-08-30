from pathlib import Path

from scapy.utils import PcapReader


class PcapFileReader:
    def __init__(self, file_path):
        self.file_path = Path(file_path)

    def read_packets(self):
        if not self.file_path.exists():
            raise FileNotFoundError(
                f"PCAP file not found: {self.file_path}"
            )

        with PcapReader(str(self.file_path)) as reader:
            for packet in reader:
                yield packet
