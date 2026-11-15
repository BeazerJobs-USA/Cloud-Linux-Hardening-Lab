# Evidence Index

Sanitized command records plus six cropped, annotated screenshots under [`../assets/evidence/`](../assets/evidence/). Public IPs, Tailscale (CGNAT) IPs, LAN IPs, and the Wazuh manager hostname are redacted in the images. Raw captures and the full Wazuh PDF export are not published.

## Annotated Screenshot Gallery (`assets/evidence/`)

| File | What It Shows | Redaction |
| --- | --- | --- |
| [`01-ufw-exposure-baseline.png`](../assets/evidence/01-ufw-exposure-baseline.png) | Initial `ufw status numbered`, `ss -tulpn`, and `iptables -S` showing public `22/tcp` rules alongside `3389/tcp` on `tailscale0` | Cropped to command block; no sensitive IPs present |
| [`02-ufw-private-ssh-cutover.png`](../assets/evidence/02-ufw-private-ssh-cutover.png) | Tailscale session check, removal of generic IPv4/IPv6 `22/tcp` rules, and final `ufw status verbose` policy | Tailscale workstation IP redacted to `[TS_ADMIN_IP]` |
| [`03-private-vs-public-ssh-validation.png`](../assets/evidence/03-private-vs-public-ssh-validation.png) | PowerShell `Test-NetConnection` to the public address: TCP/22 failed (`False`) while ICMP succeeded (`True`). Cropped to the public-path test; the Tailscale-path result is in [`validation-evidence.md`](validation-evidence.md#7-private-versus-public-tcp22-validation) | Public VM IP and workstation LAN IP redacted |
| [`04-openssh-hardening-validation.png`](../assets/evidence/04-openssh-hardening-validation.png) | Pre-hardening `sshd -T`, `/etc/ssh` backup, drop-in config, `sshd -t` check, hardened `sshd -T`, and `ssh` reload (`active`) | Cropped to command block; no sensitive IPs present |
| [`05-lynis-krnl-and-sysctl-validation.png`](../assets/evidence/05-lynis-krnl-and-sysctl-validation.png) | Lynis `KRNL-6000` check output, 3 retained exceptions in `/var/log/lynis.log`, and live `sysctl` runtime readout | Cropped to relevant terminal lines; no sensitive IPs present |
| [`06-wazuh-monitoring-validation.png`](../assets/evidence/06-wazuh-monitoring-validation.png) | One-month Wazuh Threat Hunting dashboard for `vultr-security-lab` with `0` Level 12+ alerts | Internal AWS manager hostname redacted to `[WAZUH_MGR]` |

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

Uncropped screenshots and the full exported Wazuh PDF report are kept out of the repo. Only sanitized text records and redacted visual captures are published here.
