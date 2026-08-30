from .engine import DPIEngine
from .pcap_reader import PcapFileReader


class PCAPProcessor:

    def __init__(self, engine=None):
        self.engine = engine or DPIEngine()

    def process_file(self, file_path):
        reader = PcapFileReader(file_path)

        for packet in reader.read_packets():
            self.engine.process_packet(packet)

        return self.engine.get_statistics()
