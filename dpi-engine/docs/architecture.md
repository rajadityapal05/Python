# DPI Engine — Architecture

## Overview

DPI Engine is a modular Python-based Deep Packet Inspection system designed to inspect authorized network traffic, identify applications, apply traffic rules, track network flows, and generate traffic statistics.

## High-Level Architecture

```text
Network Traffic
      |
      v
Packet Capture
  PCAP / Live
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
Domain Detection
      |
      v
Application Classifier
      |
      v
Rule Manager
      |
   +--+--+
   |     |
 BLOCK  ALLOW
   |     |
   +--+--+
      |
      v
Flow Tracking
      |
      v
Statistics
