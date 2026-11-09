# Case 001: Secure Linux Baseline and Host Controls

## Objective

Establish the effective security state of the Ubuntu cloud host before making additional changes.

## Initial findings

The host was not an unsecured default system. Several controls were already active and working:

- `PermitRootLogin no`
- `PasswordAuthentication no`
- `PubkeyAuthentication yes`
- Fail2ban SSH jail active
- auditd active with watches on identity, privilege, and SSH configuration files
- Tailscale active
- Wazuh agent active
- UFW active with a default deny inbound posture

The important gap was that UFW still allowed TCP/22 from anywhere. Strong SSH authentication reduced credential risk, but the service remained directly reachable from the Internet.

## Validation commands

```bash
sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication|pubkeyauthentication'
sudo fail2ban-client status sshd
sudo auditctl -l
systemctl is-active ssh
systemctl is-active fail2ban
systemctl is-active auditd
systemctl is-active tailscaled
systemctl is-active wazuh-agent
sudo ufw status numbered
sudo ss -tulpn | grep -E ':22|:3389'
```

## Evidence

The observed baseline commands and outputs are recorded in [`../evidence/validation-evidence.md`](../evidence/validation-evidence.md), including SSH authentication controls, Fail2ban status, auditd watches, service state, and the initial UFW rules.

## Analyst assessment

The host already had a strong authentication baseline, but authentication controls and network exposure are separate security layers. The public SSH rule created unnecessary Internet reachability even though password and root logins were disabled.

The next remediation therefore targeted exposure first rather than changing ports or adding more authentication mechanisms.
