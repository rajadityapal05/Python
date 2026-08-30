from scapy.all import sniff

from .engine import DPIEngine


class LiveSniffer:

    def __init__(self, engine=None):
        self.engine = engine or DPIEngine()

    def process_packet(self, packet):

        decision = self.engine.process_packet(packet)

        application = self.engine.last_application or "unknown"
        domain = self.engine.last_domain or "-"

        print(
            f"[{decision:<7}] "
            f"{application:<10} "
            f"{domain:<30} "
            f"size={len(bytes(packet))}"
        )

    def print_report(self):

        stats = self.engine.get_statistics()

        print()
        print("================================")
        print("       DPI LIVE REPORT")
        print("================================")
        print(f"Total Packets : {stats['total_packets']}")
        print(f"Forwarded     : {stats['forwarded_packets']}")
        print(f"Blocked       : {stats['blocked_packets']}")
        print(f"Flows         : {stats['flows']}")
        print()

        print("Applications:")

        if stats["applications"]:
            for application, count in stats["applications"].items():
                print(f"  {application:<12} : {count}")
        else:
            print("  None")

        print("================================")

    def start(self, interface=None):

        print("================================")
        print("       DPI LIVE SNIFFER")
        print("================================")
        print("Press Ctrl+C to stop.")
        print()

        try:
            sniff(
                iface=interface,
                prn=self.process_packet,
                store=False,
            )

        except KeyboardInterrupt:
            print()
            print("Stopping live sniffer...")

        finally:
            self.print_report()
