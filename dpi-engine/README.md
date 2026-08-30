# DPI Engine

A Python-based Deep Packet Inspection (DPI) engine built with Scapy for packet analysis, application classification, traffic filtering, flow tracking, PCAP analysis, DNS inspection, TLS SNI detection, and live network monitoring.

## Features

- Packet parsing with Scapy
- Five-tuple flow tracking
- HTTP Host extraction
- TLS SNI extraction
- DNS query extraction
- Application classification
- BLOCK / ALLOW / UNKNOWN rules
- Offline PCAP processing
- Live packet sniffing
- Traffic statistics
- Command-line interface
- Automated test suite

## Detection Pipeline

Network Packet
    |
    v
Packet Parser
    |
    +---- HTTP Host
    |
    +---- TLS SNI
    |
    +---- DNS Query
    |
    v
Application Classifier
    |
    v
Rule Manager
    |
    +---- BLOCK
    |
    +---- ALLOW
    |
    v
Flow Tracking
    |
    v
Statistics

## Installation

Create a virtual environment:

    python -m venv .venv

Activate it on Windows:

    .\.venv\Scripts\Activate.ps1

Install dependencies:

    pip install -r requirements.txt

## PCAP Analysis

Run the included test PCAP:

    python -m src.dpi_engine.cli tests\data\test_dpi.pcap

Expected result:

    Total Packets : 3
    Forwarded     : 2
    Blocked       : 1
    Flows         : 3

    youtube : 1
    github  : 1
    other   : 1

## Live Monitoring

Start the live sniffer:

    python -m src.dpi_engine.cli --live

Press Ctrl+C to stop.

On Windows, live packet capture may require Npcap.

## Testing

Run:

    python -m pytest -q

Current validation:

    8 passed

## Example Detection

    www.youtube.com  -> BLOCK
    github.com       -> ALLOW
    example.com      -> UNKNOWN

## Technologies

- Python
- Scapy
- Pytest
- TCP/IP
- HTTP
- TLS
- DNS
- PCAP
- Deep Packet Inspection

## Project Status

The DPI Engine supports offline PCAP analysis and live packet capture with application classification, traffic rules, flow tracking, DNS inspection, TLS SNI detection, and traffic statistics.

## Disclaimer

This project is intended for educational, defensive, and authorized network-analysis purposes. Only capture or inspect network traffic on systems and networks you are authorized to monitor.
