# Reproduction and Validation Guide

This guide uses placeholders. Do not copy private addresses, public addresses, credentials, or private keys into a repository.

## 1. Establish the SSH baseline

```bash
sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication|pubkeyauthentication'
sudo fail2ban-client status sshd
sudo auditctl -l
sudo ufw status numbered
```

Expected security baseline for this lab:

```text
permitrootlogin no
pubkeyauthentication yes
passwordauthentication no
```

## 2. Validate Tailscale before changing firewall rules

```bash
systemctl is-active tailscaled
tailscale status
```

From the administrative workstation, confirm TCP/22 is reachable on the Tailscale address.

```powershell
Test-NetConnection <TAILSCALE_IP> -Port 22
```

## 3. Permit SSH on the Tailscale interface

```bash
sudo ufw allow in on tailscale0 to any port 22 proto tcp
sudo ufw status numbered
```

Open a second SSH session through Tailscale before removing any existing public rule.

## 4. Remove generic public SSH rules

Use `sudo ufw status numbered` and remove only the generic IPv4 and IPv6 TCP/22 entries. Recheck numbering after every deletion.

```bash
sudo ufw status numbered
sudo ufw delete <RULE_NUMBER>
```

## 5. Validate network behavior

From Windows PowerShell:

```powershell
Test-NetConnection <TAILSCALE_IP> -Port 22
Test-NetConnection <PUBLIC_IP> -Port 22
```

Expected result:

```text
Private Tailscale path: True
Public path:            False
```

## 6. Apply SSH hardening

Back up the SSH configuration first:

```bash
sudo cp -a /etc/ssh /etc/ssh.backup-before-hardening
```

Place the repository SSH settings in `/etc/ssh/sshd_config.d/99-security-hardening.conf`, then validate before reload:

```bash
sudo sshd -t
sudo sshd -T | grep -E 'allowtcpforwarding|maxauthtries|maxsessions|loglevel|x11forwarding|allowagentforwarding'
sudo systemctl reload ssh
sudo systemctl is-active ssh
```

Open another SSH session to prove that administration still works.

## 7. Run the Lynis audit

```bash
sudo lynis audit system
```

Review findings before applying changes. Do not treat the hardening index as a target that overrides system requirements.

## 8. Apply selected sysctl hardening

Back up the current configuration:

```bash
sudo cp -a /etc/sysctl.conf /etc/sysctl.conf.backup-before-hardening
sudo cp -a /etc/sysctl.d /etc/sysctl.d.backup-before-hardening
```

Copy the repository sysctl values to `/etc/sysctl.d/99-security-hardening.conf`, then apply and verify:

```bash
sudo sysctl -p /etc/sysctl.d/99-security-hardening.conf
sysctl fs.protected_fifos
sysctl fs.suid_dumpable
sysctl kernel.kptr_restrict
sysctl kernel.sysrq
sudo sysctl net.core.bpf_jit_harden
sysctl net.ipv4.conf.all.log_martians
sysctl net.ipv4.conf.all.send_redirects
sysctl net.ipv4.conf.all.rp_filter
```

## 9. Validate services and connectivity again

```bash
systemctl is-active ssh
systemctl is-active tailscaled
systemctl is-active fail2ban
systemctl is-active auditd
systemctl is-active wazuh-agent
```

Confirm a new SSH session still succeeds through Tailscale.

## 10. Review residual findings

```bash
sudo grep -E 'different value than expected|KRNL-6000' /var/log/lynis.log
```

Document any retained deviation with the operational reason for keeping it.
