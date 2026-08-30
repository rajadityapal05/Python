import argparse

from .live_sniffer import LiveSniffer
from .pcap_processor import PCAPProcessor


def print_report(stats):
    print()
    print("================================")
    print("       DPI ENGINE REPORT")
    print("================================")
    print(f"Total Packets : {stats['total_packets']}")
    print(f"Forwarded     : {stats['forwarded_packets']}")
    print(f"Blocked       : {stats['blocked_packets']}")
    print(f"Flows         : {stats['flows']}")
    print()
    print("Applications:")

    for application, count in stats["applications"].items():
        print(f"  {application:12} : {count}")

    print("================================")


def main():
    parser = argparse.ArgumentParser(
        description="Deep Packet Inspection Engine"
    )

    parser.add_argument(
        "pcap",
        nargs="?",
        help="Path to the PCAP file"
    )

    parser.add_argument(
        "--live",
        action="store_true",
        help="Start live packet capture"
    )

    parser.add_argument(
        "--interface",
        default=None,
        help="Network interface for live capture"
    )

    args = parser.parse_args()

    if args.live:
        sniffer = LiveSniffer()
        sniffer.start(interface=args.interface)
        return

    if not args.pcap:
        parser.error(
            "Provide a PCAP file or use --live"
        )

    processor = PCAPProcessor()
    stats = processor.process_file(args.pcap)

    print_report(stats)


if __name__ == "__main__":
    main()
