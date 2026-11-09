# Evidence Index

The public repository uses sanitized text evidence instead of raw desktop screenshots. This preserves the commands and observed results while avoiding disclosure of public IP addresses, Tailscale addresses, credentials, private keys, or unrelated workstation content.

## Primary validation record

[`validation-evidence.md`](validation-evidence.md) documents:

* key only SSH authentication and disabled root login
* Fail2ban SSH activity
* auditd watch rules
* security service state
* the initial public SSH firewall exposure
* Tailscale only SSH validation
* effective SSH settings before and after hardening
* Lynis hardening index improvement from 69 to 73
* kernel and network hardening values
* residual Lynis findings that were reviewed and intentionally retained

## Wazuh monitoring evidence

[`wazuh-validation.md`](wazuh-validation.md) documents:

* active Wazuh agent state
* custom SSH configuration change detections
* authentication, sudo, file integrity, and audit telemetry
* Wazuh SCA SSH controls that changed from failed to passed
* the Ubuntu 24.04 benchmark versus Ubuntu 26.04 compatibility caveat

## Lynis notes

[`lynis/README.md`](lynis/README.md) records the Lynis version, baseline score, post SSH remediation score, and scanner limitations observed during the lab.

## Evidence handling

The original screenshots and exported report were used during analysis but are not required to reproduce the public claims. The repository intentionally favors sanitized, reviewable evidence over raw screenshots containing environment identifiers.
