from scapy.layers.inet import IP, TCP, UDP

from .models import FiveTuple


class PacketParser:

    @staticmethod
    def parse(packet):
        if not packet.haslayer(IP):
            return None

        ip = packet[IP]

        if packet.haslayer(TCP):
            tcp = packet[TCP]

            five_tuple = FiveTuple(
                src_ip=ip.src,
                dst_ip=ip.dst,
                src_port=tcp.sport,
                dst_port=tcp.dport,
                protocol=6,
            )

            return five_tuple, int(tcp.flags)

        if packet.haslayer(UDP):
            udp = packet[UDP]

            five_tuple = FiveTuple(
                src_ip=ip.src,
                dst_ip=ip.dst,
                src_port=udp.sport,
                dst_port=udp.dport,
                protocol=17,
            )

            return five_tuple, 0

        return None
