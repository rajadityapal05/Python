# DPI Engine

A modular Python-based Deep Packet Inspection engine for authorized network traffic analysis, application classification, traffic policy enforcement, flow tracking, PCAP processing, and live monitoring.

## Overview

DPI Engine analyzes network packets using Scapy and combines protocol-level inspection with application classification and configurable traffic rules.

The project was designed with a modular architecture so packet parsing, protocol extraction, classification, rule evaluation, flow tracking, and command-line interaction remain separated and testable.

## Features

- Deep packet inspection using Scapy
- HTTP Host extraction
- TLS ClientHello SNI extraction
- DNS query extraction
- Application classification
- BLOCK / ALLOW / UNKNOWN traffic rules
- Five-tuple flow tracking
- Offline PCAP analysis
- Live packet monitoring
- Traffic statistics
- Command-line interface
- Automated Pytest test suite

## Detection Pipeline

`	ext
Network Traffic
      |
      v
Packet Capture
  PCAP / Live
      |
      v
Packet Parser
      |
 +----+----+----+
 |         |    |
 v         v    v
HTTP      TLS  DNS
Host      SNI  Query
 |         |    |
 +---------+----+
           |
           v
    Domain Detection
           |
           v
 Application Classifier
           |
           v
      Rule Manager
           |
     +-----+-----+
     |     |     |
     v     v     v
   BLOCK ALLOW UNKNOWN
     |     |     |
     +-----+-----+
           |
           v
      Flow Tracking
           |
           v
       Statistics
` 

## Architecture

The system is organized into independent components for packet processing, protocol extraction, classification, policy decisions, flow tracking, and reporting.

See the detailed architecture documentation:

- [Architecture](docs/architecture.md)
- [Design](docs/design.md)
- [Traffic Rules](docs/rules.md)
- [Project Documentation](docs/pages.doc.md)

## Project Structure

`	ext
dpi-engine/
|-- data/
|-- rules/
|-- scripts/
|-- src/
|   |-- dpi_engine/
|       |-- classifier.py
|       |-- cli.py
|       |-- dns_extractor.py
|       |-- engine.py
|       |-- flow_tracker.py
|       |-- live_sniffer.py
|       |-- models.py
|       |-- packet_parser.py
|       |-- pcap_processor.py
|       |-- pcap_reader.py
|       |-- rules.py
|       |-- sni_extractor.py
|       |-- tls_parser.py
|-- tests/
|-- docs/
|   |-- architecture.md
|   |-- design.md
|   |-- rules.md
|   |-- pages.doc.md
|-- README.md
|-- requirements.txt
` 

## Technology Stack

| Technology | Purpose |
|---|---|
| Python | Core implementation |
| Scapy | Packet inspection and network parsing |
| Pytest | Automated testing |
| TCP/IP | Network protocol analysis |
| HTTP | Host inspection |
| TLS | SNI inspection |
| DNS | Domain extraction |
| PCAP | Offline packet analysis |

## Installation

Create a virtual environment:

`powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
` 

## PCAP Analysis

Run the included test PCAP:

`powershell
python -m src.dpi_engine.cli tests\data\test_dpi.pcap
` 

Expected validation:

`	ext
Total Packets : 3
Forwarded     : 2
Blocked       : 1
Flows         : 3

Applications:
  youtube      : 1
  github       : 1
  other        : 1
` 

## Live Monitoring

Start live monitoring with:

`powershell
python -m src.dpi_engine.cli --live
` 

On Windows, live packet capture may require Npcap and appropriate capture permissions.

## Testing

Run the automated test suite:

`powershell
python -m pytest -q
` 

Current validation:

`	ext
8 passed
` 

## Validation Results

### Offline PCAP

`	ext
Packets:   3
Forwarded: 2
Blocked:   1
Flows:     3
` 

### Live Monitoring

A live monitoring test captured:

`	ext
Packets:   69
Forwarded: 69
Blocked:   0
Flows:     19
` 

## Portfolio Highlights

This project demonstrates practical experience with:

- Network packet analysis
- Protocol-level inspection
- Python software architecture
- Rule-based traffic classification
- Flow tracking
- PCAP processing
- Real-time network monitoring
- Automated testing
- CLI application development

## Project Status

The DPI Engine currently supports offline PCAP analysis and live packet capture with application classification, configurable traffic rules, flow tracking, DNS inspection, TLS SNI detection, and traffic statistics.

## Disclaimer

This project is intended for educational, defensive, and authorized network-analysis purposes. Only capture or inspect network traffic on systems and networks you are authorized to monitor.
