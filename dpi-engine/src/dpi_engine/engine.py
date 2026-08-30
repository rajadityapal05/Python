from .classifier import ApplicationClassifier
from .dns_extractor import DNSExtractor
from .flow_tracker import FlowTracker
from .packet_parser import PacketParser
from .rules import RuleManager
from .sni_extractor import SNIExtractor
from .tls_parser import TLSParser


class DPIEngine:

    def __init__(self, rule_manager=None):
        self.classifier = ApplicationClassifier()
        self.flow_tracker = FlowTracker()
        self.rules = rule_manager or RuleManager()

        self.total_packets = 0
        self.forwarded_packets = 0
        self.blocked_packets = 0

        self.application_stats = {}

        self.last_domain = None
        self.last_application = None

    def process_packet(self, packet):

        self.total_packets += 1

        parsed = PacketParser.parse(packet)

        if parsed is None:
            self.last_domain = None
            self.last_application = None
            self.forwarded_packets += 1
            return "ALLOW"

        five_tuple, _ = parsed

        flow = self.flow_tracker.update(
            five_tuple,
            len(bytes(packet))
        )

        domain = SNIExtractor.extract_http_host(packet)

        if not domain:
            domain = TLSParser.extract_sni(packet)

        if not domain:
            domain = DNSExtractor.extract_query(packet)

        application = ApplicationClassifier.classify(domain)

        self.last_domain = domain
        self.last_application = application

        if application:
            flow.application = application

            self.application_stats[application] = (
                self.application_stats.get(application, 0) + 1
            )

        decision = self.rules.decide(application)

        flow.decision = decision

        if decision == "BLOCK":
            self.blocked_packets += 1
        else:
            self.forwarded_packets += 1

        return decision

    def get_statistics(self):

        return {
            "total_packets": self.total_packets,
            "forwarded_packets": self.forwarded_packets,
            "blocked_packets": self.blocked_packets,
            "flows": self.flow_tracker.get_flow_count(),
            "applications": dict(self.application_stats),
        }
