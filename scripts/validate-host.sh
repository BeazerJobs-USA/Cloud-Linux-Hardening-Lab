#!/usr/bin/env bash
set -u

echo "== Cloud Linux Hardening Lab validation =="
echo

echo "[1] Effective SSH security settings"
sudo sshd -T | grep -E 'permitrootlogin|passwordauthentication|pubkeyauthentication|maxauthtries|maxsessions|x11forwarding|allowtcpforwarding|allowagentforwarding|loglevel'
echo

echo "[2] Security service state"
for svc in ssh tailscaled fail2ban auditd wazuh-agent; do
  printf "%-14s " "$svc"
  systemctl is-active "$svc" || true
done
echo

echo "[3] Selected kernel and network settings"
for key in   fs.protected_fifos   fs.suid_dumpable   kernel.kptr_restrict   kernel.sysrq   kernel.unprivileged_bpf_disabled   net.core.bpf_jit_harden   net.ipv4.conf.all.log_martians   net.ipv4.conf.default.log_martians   net.ipv4.conf.all.send_redirects   net.ipv4.conf.default.send_redirects   net.ipv4.conf.all.rp_filter
do
  sudo sysctl "$key"
done
echo

echo "[4] UFW policy"
sudo ufw status numbered
echo

echo "[5] Fail2ban SSH jail"
sudo fail2ban-client status sshd
echo

echo "[6] auditd watches"
sudo auditctl -l
echo

echo "Validation complete."
