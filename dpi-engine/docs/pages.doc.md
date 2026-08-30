# DPI Engine — Project Documentation

## Project Overview

DPI Engine is a modular Python-based Deep Packet Inspection system for authorized network traffic analysis.

It combines packet parsing, protocol inspection, application classification, configurable traffic rules, flow tracking, PCAP processing, and live monitoring.

## Core Components

### PCAP Analyzer
Processes captured PCAP files and reports packet counts, forwarding decisions, flows, and application statistics.

### Live Sniffer
Captures live network traffic and provides real-time inspection output.

### Protocol Inspection
Supports HTTP Host extraction, TLS ClientHello SNI extraction, and DNS query extraction.

### Application Classification
Detected domains can be mapped to application categories such as youtube, github, other, and unknown.

### Traffic Policy
Classified traffic can be evaluated using BLOCK, ALLOW, or UNKNOWN rules.

### Flow Tracking
Network flows are tracked using five-tuple information: source IP, destination IP, source port, destination port, and protocol.

## Validation

Automated test suite: 8 passed.

PCAP validation: 3 packets, 2 forwarded, 1 blocked, 3 flows.

Live validation: 69 packets captured, 69 forwarded, 0 blocked, 19 flows.

## Technology Stack

- Python
- Scapy
- Pytest
- TCP/IP
- HTTP
- TLS
- DNS
- PCAP

## Portfolio Value

This project demonstrates practical experience with network packet analysis, protocol inspection, modular Python architecture, rule-based classification, flow tracking, PCAP processing, live network monitoring, automated testing, and command-line application design.

## Intended Use

This project is intended for educational, defensive, and authorized network-analysis purposes. Only inspect traffic on systems and networks where you have permission to do so.
