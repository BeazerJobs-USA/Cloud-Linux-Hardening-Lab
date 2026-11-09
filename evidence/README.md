# Evidence Index

Only evidence that supports a specific technical claim is included. Environment addresses are redacted where they are not needed to validate the result.

| File | What it proves |
| --- | --- |
| `images/01_baseline_security_controls.png` | Key only SSH baseline, Fail2ban activity, auditd watches, and active security services |
| `images/02_ufw_public_ssh_baseline.png` | Initial UFW rule allowed TCP/22 from anywhere |
| `images/03_ssh_before_hardening.png` | Effective OpenSSH values before Lynis driven remediation |
| `images/04_ssh_after_hardening.png` | Effective OpenSSH values after remediation |
| `images/05_private_vs_public_ssh_validation.png` | Private Tailscale TCP/22 succeeded while public TCP/22 failed |
| `images/06_kernel_network_baseline.png` | Pre remediation sysctl values |
| `images/07_kernel_hardening_and_exceptions.png` | Hardened sysctl values and remaining reviewed Lynis deviations |

Raw screenshots that exposed unnecessary addresses, unrelated desktop content, or repeated the same evidence were intentionally not published.
