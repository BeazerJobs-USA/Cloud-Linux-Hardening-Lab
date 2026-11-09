# Cloud Linux Hardening Lab

A hands on Ubuntu cloud security project focused on reducing attack surface, restricting administrative access, validating host protections, and using security audit findings to drive targeted remediation.

## Project summary

The system already had several strong controls in place: root SSH login was disabled, password authentication was disabled, public key authentication was enabled, Fail2ban was active, auditd was collecting security relevant changes, and the Wazuh agent was running.

The main weakness was architectural rather than authentication related: SSH was still reachable from the public Internet because UFW allowed port 22 from anywhere.

This project moved administrative SSH access behind Tailscale, removed the generic public SSH rules, validated that private SSH still worked while public TCP/22 failed, then used Lynis to prioritize additional SSH and kernel hardening. Every major change was followed by connectivity and service validation.

## Results

| Area | Initial state | Final validated state |
| --- | --- | --- |
| SSH network exposure | TCP/22 allowed from anywhere | TCP/22 reachable through \`tailscale0\`; public TCP/22 blocked |
| Root SSH login | Disabled | Disabled |
| Password SSH login | Disabled | Disabled |
| Public key SSH | Enabled | Enabled |
| Max authentication attempts | 6 | 3 |
| SSH sessions per connection | 10 | 2 |
| X11 forwarding | Enabled | Disabled |
| TCP forwarding | Enabled | Disabled |
| Agent forwarding | Enabled | Disabled |
| SSH logging | INFO | VERBOSE |
| Lynis hardening index | 69 | 73 after SSH remediation |
| Kernel/network audit | Multiple tunables differed from profile | Targeted controls remediated; three deviations reviewed and intentionally retained |
| Security services | SSH, Tailscale, Fail2ban, auditd, Wazuh active | All five validated active after hardening |

The Lynis score was used as a measurement signal, not as the objective. Settings were evaluated against the actual role of the host and the requirements of Tailscale networking.

## Architecture

\`\`\`mermaid
flowchart LR
    A[Windows admin workstation] -->|Tailscale encrypted overlay| T[Tailscale network]
    T -->|Private SSH administration| U[UFW on Ubuntu cloud VM]
    I[Public Internet] -. TCP 22 blocked .-> U
    U --> S[OpenSSH]
    U --> R[XRDP restricted to tailscale0]
    S --> H[Hardened Ubuntu host]
    H --> F[Fail2ban]
    H --> D[auditd]
    H --> K[sysctl kernel and network hardening]
    H --> W[Wazuh agent]
    W --> M[AWS Wazuh manager]
\`\`\`

The design separates Internet reachability from administrative reachability. SSH still listens locally on port 22, but UFW controls which interface can reach it.

## Key security decisions

| Decision | Reason | Validation |
| --- | --- | --- |
| Keep SSH on port 22 | Port changes do not replace access control. Public reachability was removed at the firewall layer instead. | Public TCP/22 failed while Tailscale TCP/22 succeeded. |
| Restrict SSH to Tailscale | Removes direct Internet exposure while preserving remote administration. | Fresh SSH login completed through the Tailscale interface. |
| Disable SSH forwarding features not used by the host | Reduces unnecessary SSH functionality available to authenticated sessions. | \`sshd -T\` confirmed effective settings after reload. |
| Increase SSH logging to VERBOSE | Improves authentication context for investigation. | Effective configuration validated with \`sshd -T\`. |
| Keep \`rp_filter=2\` | Loose reverse path filtering is compatible with overlay and asymmetric networking behavior. | Tailscale remained reachable after sysctl hardening. |
| Keep \`kernel.unprivileged_bpf_disabled=2\` | Unprivileged BPF remains disabled while preserving administrative reversibility. | Value validated after remediation. |
| Keep \`kernel.modules_disabled=0\` | Setting it to \`1\` prevents additional module loading until reboot and would reduce flexibility in this lab environment. | Documented as an accepted Lynis deviation. |

## Evidence

The public repository uses a sanitized command and results record rather than raw desktop screenshots. This keeps the technical proof reviewable without exposing public IP addresses, Tailscale addresses, credentials, or unrelated workstation content.

See [`evidence/validation-evidence.md`](evidence/validation-evidence.md) for the observed before and after outputs covering:

- SSH authentication baseline
- Fail2ban activity
- auditd watches
- active security services
- initial UFW exposure
- Tailscale only SSH validation
- SSH hardening before and after
- Lynis hardening index change from 69 to 73
- kernel and network hardening
- residual Lynis findings and accepted deviations

## Investigation and remediation cases

1. [Case 001: Secure Linux Baseline and Host Controls](cases/case-001-secure-linux-baseline.md)
2. [Case 002: Private Administrative Access](cases/case-002-private-administrative-access.md)
3. [Case 003: Security Audit and Remediation](cases/case-003-security-audit-and-remediation.md)

Each case documents the initial condition, security concern, implementation, validation, and tradeoffs. No simulated compromise or fabricated intrusion is presented.

## Configuration artifacts

The repository includes the configuration changes used for the remediation:

- [\`configs/99-ssh-security-hardening.conf\`](configs/99-ssh-security-hardening.conf)
- [\`configs/99-security-hardening.conf\`](configs/99-security-hardening.conf)

These files are examples from this lab environment. They should be reviewed against the requirements of another host before reuse.

## Reproduction and validation

See [docs/reproduction.md](docs/reproduction.md) for the implementation and validation sequence using placeholder addresses rather than environment specific IPs.

For the trust boundaries and control placement, see [docs/architecture.md](docs/architecture.md).

## Repository structure

\`\`\`text
Cloud-Linux-Hardening-Lab/
├── README.md
├── SECURITY.md
├── cases/
│   ├── case-001-secure-linux-baseline.md
│   ├── case-002-private-administrative-access.md
│   └── case-003-security-audit-and-remediation.md
├── configs/
│   ├── 99-security-hardening.conf
│   └── 99-ssh-security-hardening.conf
├── docs/
│   ├── architecture.md
│   └── reproduction.md
└── evidence/
    ├── README.md
    ├── images/
    └── lynis/
        ├── README.md
        └── lynis_baseline_audit.txt
\`\`\`

## Controls and tools demonstrated

Ubuntu Linux administration, OpenSSH hardening, Tailscale private access, UFW host firewalling, Fail2ban, auditd, Wazuh endpoint monitoring, Lynis auditing, sysctl hardening, service validation, connectivity testing, evidence handling, and risk based configuration decisions.

## Scope and limitations

This is a controlled cloud lab, not a claim of a production deployment. The evidence shows configuration and validation performed on the lab host. Lynis 3.1.6 reported that its version was more than six months old and did not have an end of life database entry for Ubuntu 26.04, so scanner output was treated as advisory rather than authoritative.

The project focuses on host hardening and administrative access. It does not claim exploitation, compromise, malware activity, or incident containment that did not occur.
