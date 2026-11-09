# Sanitized Validation Evidence

This file records the observed commands and results used to validate the hardening work. Environment addresses and authentication material are intentionally omitted.

## 1. SSH authentication baseline

Command:

```bash
sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication|pubkeyauthentication'
```

Observed effective configuration:

```text
permitrootlogin no
pubkeyauthentication yes
passwordauthentication no
```

Assessment: root login and password authentication were already disabled. Public key authentication was enabled.

## 2. Fail2ban status

Command:

```bash
sudo fail2ban-client status sshd
```

Observed:

```text
Currently failed: 4
Total failed: 2147
Currently banned: 0
Total banned: 25
Journal matches: _SYSTEMD_UNIT=ssh.service + _COMM=sshd
```

Assessment: the SSH jail was active and had already processed real authentication failures.

## 3. auditd security watches

Command:

```bash
sudo auditctl -l
```

Observed rules:

```text
-w /etc/passwd -p wa -k identity_changes
-w /etc/group -p wa -k identity_changes
-w /etc/shadow -p wa -k identity_changes
-w /etc/sudoers -p wa -k privilege_changes
-w /etc/sudoers.d -p wa -k privilege_changes
-w /etc/ssh/sshd_config -p wa -k ssh_config_changes
-w /etc/ssh/sshd_config.d -p wa -k ssh_config_changes
```

## 4. Security service validation

Commands:

```bash
systemctl is-active ssh
systemctl is-active tailscaled
systemctl is-active fail2ban
systemctl is-active auditd
systemctl is-active wazuh-agent
```

Observed:

```text
active
active
active
active
active
```

## 5. Initial UFW exposure

Command:

```bash
sudo ufw status numbered
```

Relevant initial rules:

```text
22/tcp                     ALLOW IN    Anywhere
3389/tcp on tailscale0     ALLOW IN    Anywhere
22/tcp (v6)                ALLOW IN    Anywhere (v6)
3389/tcp (v6) on tailscale0 ALLOW IN   Anywhere (v6)
```

Assessment: SSH had strong authentication controls but was still reachable through a generic public firewall rule.

## 6. Private SSH path added

Command:

```bash
sudo ufw allow in on tailscale0 to any port 22 proto tcp
```

A second SSH session was established through Tailscale before removing the generic public rules.

## 7. Private versus public TCP/22 validation

From Windows PowerShell:

```powershell
Test-NetConnection <TAILSCALE_IP> -Port 22
Test-NetConnection <PUBLIC_IP> -Port 22
```

Observed:

```text
Tailscale interface:
TcpTestSucceeded : True

Public interface:
TcpTestSucceeded : False
```

Assessment: private administration remained reachable while direct public SSH was no longer reachable from the test workstation.

## 8. SSH baseline before additional hardening

Command:

```bash
sudo sshd -T | grep -E 'allowtcpforwarding|maxauthtries|maxsessions|loglevel|x11forwarding|allowagentforwarding'
```

Observed before remediation:

```text
maxauthtries 6
maxsessions 10
x11forwarding yes
allowtcpforwarding yes
allowagentforwarding yes
loglevel INFO
```

## 9. SSH configuration after remediation

Observed effective configuration after syntax validation and reload:

```text
maxauthtries 3
maxsessions 2
permitrootlogin no
pubkeyauthentication yes
passwordauthentication no
x11forwarding no
allowtcpforwarding no
allowagentforwarding no
loglevel VERBOSE
```

Assessment: unused forwarding features were removed, session and authentication limits were tightened, and logging detail increased without changing the existing key only authentication model.

## 10. Lynis audit

Initial audit:

```text
Hardening index : 69
Tests performed : 261
Plugins enabled : 1
Firewall         : present
Intrusion software: present
Malware scanner  : present
```

After the SSH remediation:

```text
Hardening index : 73
Tests performed : 261
Plugins enabled : 1
```

The score was treated as a measurement signal, not the goal of the project.

## 11. Kernel and network baseline

Observed before selected sysctl remediation:

```text
fs.protected_fifos = 1
fs.suid_dumpable = 2
kernel.kptr_restrict = 1
kernel.sysrq = 176
kernel.unprivileged_bpf_disabled = 2
net.core.bpf_jit_harden = 2
net.ipv4.conf.all.log_martians = 0
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.all.send_redirects = 1
net.ipv4.conf.default.log_martians = 0
```

## 12. Kernel and network hardening validation

Observed after remediation:

```text
fs.protected_fifos = 2
fs.suid_dumpable = 0
kernel.kptr_restrict = 2
kernel.sysrq = 0
kernel.unprivileged_bpf_disabled = 2
net.core.bpf_jit_harden = 2
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.rp_filter = 2
```

## 13. Residual Lynis KRNL-6000 differences

Observed:

```text
kernel.modules_disabled: expected 1, actual 0
kernel.unprivileged_bpf_disabled: expected 1, actual 2
net.ipv4.conf.all.rp_filter: expected 1, actual 2
```

These were reviewed rather than blindly changed. The rationale for retaining each value is documented in Case 003.

## Evidence handling

Raw screenshots were used during the lab but are not required to reproduce the claims above. Public documentation intentionally omits public IP addresses, Tailscale addresses, credentials, private keys, and unrelated desktop information.


## 14. Wazuh monitoring validation

The Wazuh manager continued receiving endpoint telemetry after the hardening changes.

Observed report evidence included:

```text
Rule 100100  SSH configuration file modified on       Level 8   Count 16
Rule 5715    sshd: authentication success             Level 3   Count 32
Rule 5758    Maximum authentication attempts exceeded Level 8   Count 21
```

Wazuh Security Configuration Assessment also showed several SSH controls changing from failed to passed, including `LogLevel`, which corresponds to the change from INFO to VERBOSE.

See [`wazuh-validation.md`](wazuh-validation.md) for the complete sanitized monitoring evidence and interpretation.
