# Case 002: Private Administrative Access

## Objective

Remove direct Internet access to SSH without losing reliable remote administration.

## Design

Tailscale was already installed and connected on the Windows workstation and Ubuntu host. The remediation used the Tailscale interface as the permitted administrative path and kept the cloud provider console as the out of band recovery option.

## Implementation

First, SSH was explicitly allowed on the Tailscale interface:

```bash
sudo ufw allow in on tailscale0 to any port 22 proto tcp
```

A second SSH session was opened through the Tailscale address before removing any existing public rule. This reduced lockout risk.

After private access was confirmed, the generic IPv4 and IPv6 TCP/22 UFW rules were removed. Rule numbers were rechecked after each deletion because UFW renumbers entries.

## Validation

From Windows PowerShell, TCP/22 was tested against both paths:

```powershell
Test-NetConnection <TAILSCALE_IP> -Port 22
Test-NetConnection <PUBLIC_IP> -Port 22
```

Observed result:

```text
Tailscale TCP/22: True
Public TCP/22:    False
```

A fresh SSH session was then established through Tailscale and the host identity was verified.

## Evidence

- [`02_ufw_public_ssh_baseline.png`](../evidence/images/02_ufw_public_ssh_baseline.png)
- [`05_private_vs_public_ssh_validation.png`](../evidence/images/05_private_vs_public_ssh_validation.png)

## Tradeoff

OpenSSH continues to listen on port 22. The security boundary is the firewall and private overlay, not an alternate port number. This keeps the configuration conventional while eliminating direct public reachability.

## Outcome

Administrative SSH remained functional through the private overlay and public TCP/22 failed from the workstation. The change reduced exposed attack surface without sacrificing remote management.
