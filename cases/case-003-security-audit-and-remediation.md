# Case 003: Security Audit and Remediation

## Objective

Use a host security audit to identify meaningful hardening opportunities, remediate selected findings, and document exceptions where the scanner profile did not match the operational design.

## Baseline audit

Lynis 3.1.6 completed 261 tests with:

```text
Hardening index: 69
Warnings: 0
Suggestions: 42
```

The audit confirmed several existing controls including an active firewall, Fail2ban, auditd, AppArmor, Wazuh file integrity monitoring, and the Wazuh agent.

## SSH findings

Effective SSH values before remediation were:

```text
maxauthtries 6
maxsessions 10
x11forwarding yes
allowtcpforwarding yes
allowagentforwarding yes
loglevel INFO
```

The selected remediation was:

```text
MaxAuthTries 3
MaxSessions 2
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
LogLevel VERBOSE
```

The change was placed in a dedicated OpenSSH drop in file, syntax checked with `sshd -t`, applied with a reload, and validated with `sshd -T`. A second SSH session confirmed that legitimate administration still worked.

After the SSH remediation, the Lynis hardening index increased from **69 to 73**.

## Kernel and network findings

The initial review identified these values among the relevant differences:

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

Selected hardening changes:

```text
fs.protected_fifos = 2
fs.suid_dumpable = 0
kernel.kptr_restrict = 2
kernel.sysrq = 0
net.core.bpf_jit_harden = 2
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
```

`net.core.bpf_jit_harden` was already at the desired value and was validated rather than changed.

## Accepted deviations

The subsequent Lynis kernel check reported three remaining profile differences:

```text
kernel.modules_disabled: expected 1, actual 0
kernel.unprivileged_bpf_disabled: expected 1, actual 2
net.ipv4.conf.all.rp_filter: expected 1, actual 2
```

These were not changed solely to improve the scanner score.

### `kernel.modules_disabled = 0`

Setting this value to `1` prevents additional kernel module loading until reboot. The lab retains module loading capability for controlled experimentation and future tooling.

### `kernel.unprivileged_bpf_disabled = 2`

Unprivileged BPF remains disabled. Value `2` preserves administrative reversibility, so the difference from the Lynis profile was accepted.

### `net.ipv4.conf.all.rp_filter = 2`

Loose reverse path filtering was retained to avoid unnecessarily interfering with overlay or asymmetric networking behavior. Tailscale connectivity was explicitly tested after the sysctl changes.

## Post change validation

The following services were all active after hardening:

```text
ssh
tailscaled
fail2ban
auditd
wazuh-agent
```

A new SSH session through Tailscale also succeeded after the kernel changes.

## Evidence

See [`../evidence/validation-evidence.md`](../evidence/validation-evidence.md) for the effective SSH values before and after remediation, Lynis index change, sysctl values, active services, and the remaining KRNL-6000 deviations.

## Assessment

The value of the audit was not the score alone. The useful work was separating findings into controls that reduced realistic attack surface, settings that were already secure, and recommendations that conflicted with operational requirements. The resulting configuration is therefore documented as a set of deliberate security decisions rather than a checklist optimized for a scanner score.
