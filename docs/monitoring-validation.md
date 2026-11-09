# Monitoring Validation with Wazuh

## Purpose

Wazuh is used here as an independent observability layer to confirm that hardening activity remained visible after remediation. This section does not duplicate the separate SOC investigation project and does not claim that the hardening work stopped every hostile connection attempt.

## Agent health

The Wazuh overview showed one active agent and no disconnected agents during validation. The monitored endpoint was `vultr-security-lab`.

## Configuration change visibility

The exported Wazuh threat hunting report recorded:

```text
Rule 100100
SSH configuration file modified on
Level 8
Count 16
```

This is significant because it shows that changes to the SSH security configuration were not only performed locally, but also remained observable through the monitoring stack.

The same report recorded file integrity activity including checksum changes, file additions, and file deletions. Those counts represent the full reporting window and are not presented as all being caused by this hardening exercise.

## SSH security assessment change

Wazuh Security Configuration Assessment recorded several SSH controls changing from failed to passed, including:

```text
GSSAPIAuthentication disabled
HostbasedAuthentication disabled
IgnoreRhosts enabled
LogLevel configured
MACs configured
```

For this lab, the most directly relevant result is `LogLevel`, which was intentionally changed from INFO to VERBOSE during the SSH remediation.

## Authentication telemetry

The 30 day report also contained SSH authentication telemetry:

```text
Non existent user attempts: 6508
Authentication successes: 32
Maximum authentication attempts exceeded: 21
```

These values provide environmental context only. They are not used to claim a successful intrusion, compromise, or a controlled brute force exercise.

## Why this matters

The hardening workflow preserved three things at the same time:

1. legitimate private administration through Tailscale
2. reduced public exposure through UFW
3. endpoint visibility through Wazuh

That combination is more useful than a configuration change that improves a scanner score but breaks access or monitoring.

## Evidence selection

The following Wazuh views are useful supporting evidence:

- agent overview showing the endpoint active
- threat hunting events showing SSH authentication, PAM, sudo, and auditd telemetry
- the threat hunting report showing Rule 100100 SSH configuration change detections
- Security Configuration Assessment results showing relevant SSH controls changing from failed to passed

The MITRE brute force view is supporting context, but it is intentionally not the center of this repository because brute force analysis belongs in the separate SOC investigation project.

The vulnerability dashboard is also not used as a headline metric. Raw vulnerability counts are time sensitive, feed dependent, and can distract from the host hardening objective unless each finding is individually validated.

## Compatibility caveat

Wazuh's Security Configuration Assessment in this environment references a CIS Ubuntu 24.04 benchmark while the host is Ubuntu 26.04. Those SCA results are therefore treated as advisory evidence rather than a claim of formal CIS compliance.
