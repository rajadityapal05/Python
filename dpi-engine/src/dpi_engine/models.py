from dataclasses import dataclass


@dataclass(frozen=True)
class FiveTuple:
    src_ip: str
    dst_ip: str
    src_port: int
    dst_port: int
    protocol: int


@dataclass
class ParsedPacket:
    packet_id: int
    timestamp: float
    raw_bytes: bytes
    five_tuple: FiveTuple
    tcp_flags: int = 0
