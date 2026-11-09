# Wazuh Monitoring Validation Evidence

This file summarizes the Wazuh evidence used to validate that the hardened endpoint remained observable.

## Agent state

During validation, the Wazuh overview showed:

```text
Active agents:       1
Disconnected agents: 0
Endpoint:             vultr-security-lab
```

## SSH configuration monitoring

The exported threat hunting report recorded the custom SSH configuration rule:

```text
Rule ID:     100100
Description: SSH configuration file modified on
Level:       8
Count:       16
```

This confirms that SSH configuration changes remained visible to the monitoring stack.

The count covers the report window and is not presented as 16 separate hardening actions.

## Authentication and host activity

The same report recorded:

```text
Rule 5710  sshd: Attempt to login using a non-existent user       6508
Rule 5715  sshd: authentication success                              32
Rule 5758  Maximum authentication attempts exceeded                  21
Rule 5402  Successful sudo to ROOT executed                          165
Rule 550   Integrity checksum changed                                273
Rule 554   File added to the system                                  153
Rule 553   File deleted                                              119
```

These values are environmental context from the report window. They are not used to claim a successful compromise or a controlled attack.

## Security Configuration Assessment changes

Wazuh SCA reported several SSH controls changing from failed to passed:

```text
GSSAPIAuthentication disabled
HostbasedAuthentication disabled
IgnoreRhosts enabled
LogLevel configured
MACs configured
```

The `LogLevel` result directly corresponds to the project change from INFO to VERBOSE.

## Interpretation

The monitoring evidence supports three claims:

1. the endpoint remained connected after hardening
2. SSH configuration changes were visible through Wazuh
3. authentication, privilege, file integrity, and audit telemetry continued to reach the monitoring stack

## Compatibility note

The Wazuh SCA results referenced a CIS Ubuntu 24.04 benchmark while the endpoint ran Ubuntu 26.04. The SCA output is therefore treated as advisory evidence rather than a formal compliance result.
