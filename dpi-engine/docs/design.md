# DPI Engine — Design Document

## Purpose

DPI Engine is a modular Python-based Deep Packet Inspection system designed for authorized network traffic analysis.

## Design Principles

- Modular architecture
- Separation of responsibilities
- Testable components
- Configurable traffic policies
- Offline and live analysis
- Clear command-line interface

## Processing Pipeline

Network Traffic
|
v
Packet Capture
|
v
Packet Parser
|
+-- HTTP Host
+-- TLS SNI
+-- DNS Query
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
+-- BLOCK
+-- ALLOW
+-- UNKNOWN
|
v
Flow Tracking
|
v
Statistics
|
v
CLI

## Components

- Packet Parser
- DNS Extractor
- TLS/SNI Extractor
- HTTP Host Extractor
- Application Classifier
- Rule Manager
- Flow Tracker
- PCAP Processor
- Live Sniffer
- Command-Line Interface

## Testing

The automated Pytest suite currently passes 8 tests.

## Responsible Use

DPI Engine should only be used to inspect network traffic that the operator is authorized to monitor.
