# DPI Engine — Traffic Rules

## Overview

The DPI Engine uses configurable traffic rules to determine how classified applications are handled.

## Rule Categories

| Rule | Meaning |
|---|---|
| BLOCK | Traffic identified as a blocked application |
| ALLOW | Traffic identified as an allowed application |
| UNKNOWN | Traffic that cannot be confidently classified |

## Example Rules

BLOCK: youtube, tiktok, netflix

ALLOW: google, github, reddit, facebook, instagram

## Decision Flow

Detected Domain -> Application Classifier -> Rule Manager -> BLOCK / ALLOW / UNKNOWN -> Flow Tracking -> Statistics

## Security Note

This project should only be used to inspect or control network traffic that the operator is authorized to monitor.
