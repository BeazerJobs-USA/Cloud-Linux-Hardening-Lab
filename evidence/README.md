# Evidence Index

The public repo uses a sanitized text evidence record instead of raw desktop screenshots. This preserves the exact commands and observed results while avoiding disclosure of public IP addresses, Tailscale addresses, credentials, private keys, or unrelated workstation content.

## Primary evidence

[`validation-evidence.md`](validation-evidence.md) documents:

- key only SSH authentication and disabled root login
- Fail2ban SSH activity
- auditd watch rules
- security service status
- the initial public SSH firewall exposure
- Tailscale only SSH validation
- effective SSH settings before and after hardening
- Lynis hardening index improvement from 69 to 73
- kernel and network hardening values
- residual Lynis findings that were reviewed and intentionally retained

## Supporting audit notes

[`lynis/README.md`](lynis/README.md) records the Lynis version, baseline score, post remediation score, and scanner limitations observed during the lab.

The original screenshots remain private supporting evidence and can be reproduced by following [`../docs/reproduction.md`](../docs/reproduction.md).
