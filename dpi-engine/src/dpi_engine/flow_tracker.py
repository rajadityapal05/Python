from dataclasses import dataclass, field
from time import time

from .models import FiveTuple


@dataclass
class Flow:
    five_tuple: FiveTuple
    packet_count: int = 0
    byte_count: int = 0
    first_seen: float = field(default_factory=time)
    last_seen: float = field(default_factory=time)
    application: str | None = None
    decision: str = "UNKNOWN"

    def update(self, packet_size: int):
        now = time()

        self.packet_count += 1
        self.byte_count += packet_size
        self.last_seen = now


class FlowTracker:

    def __init__(self):
        self.flows = {}

    def get_or_create(self, five_tuple: FiveTuple):
        if five_tuple not in self.flows:
            self.flows[five_tuple] = Flow(
                five_tuple=five_tuple
            )

        return self.flows[five_tuple]

    def update(self, five_tuple: FiveTuple, packet_size: int):
        flow = self.get_or_create(five_tuple)
        flow.update(packet_size)
        return flow

    def get_flow_count(self):
        return len(self.flows)

    def get_flows(self):
        return list(self.flows.values())
