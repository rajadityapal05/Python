from src.dpi_engine.classifier import ApplicationClassifier
from src.dpi_engine.models import FiveTuple
from src.dpi_engine.packet_parser import PacketParser
from src.dpi_engine.rules import RuleManager


def test_classifier():
    assert ApplicationClassifier.classify("www.youtube.com") == "youtube"
    assert ApplicationClassifier.classify("github.com") == "github"
    assert ApplicationClassifier.classify("example.com") == "other"


def test_rules():
    rules = RuleManager()

    assert rules.decide("youtube") == "BLOCK"
    assert rules.decide("github") == "ALLOW"
    assert rules.decide("unknown") == "UNKNOWN"


def test_five_tuple():
    flow = FiveTuple(
        src_ip="192.168.1.10",
        dst_ip="8.8.8.8",
        src_port=50000,
        dst_port=443,
        protocol=6,
    )

    assert flow.src_ip == "192.168.1.10"
    assert flow.dst_port == 443
    assert flow.protocol == 6
