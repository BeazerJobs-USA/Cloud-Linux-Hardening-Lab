# Security Decision Log

This file records the decisions that mattered during the hardening work and the reason each one was accepted.

## D001: Remove public SSH reachability

**Condition:** UFW allowed TCP/22 from anywhere.

**Decision:** Permit SSH on `tailscale0`, prove a second private SSH session works, then remove the generic IPv4 and IPv6 SSH rules.

**Reason:** Authentication controls reduce login risk, but they do not remove Internet exposure. The firewall change reduced the reachable attack surface.

**Validation:** Tailscale TCP/22 succeeded while public TCP/22 failed.

## D002: Keep SSH on port 22

**Decision:** Do not move SSH to a nonstandard port.

**Reason:** A port change can reduce background scanning noise, but it is not a substitute for access control. This project removed public reachability instead.

## D003: Disable unused SSH forwarding

**Decision:** Disable X11 forwarding, TCP forwarding, and agent forwarding.

**Reason:** The host does not require those features for administration. Removing unused capabilities reduces unnecessary session functionality.

**Validation:** `sshd -t` passed, `sshd -T` reported the expected values, and a new Tailscale SSH session still worked.

## D004: Tighten SSH authentication and session limits

**Decision:** Change `MaxAuthTries` from 6 to 3 and `MaxSessions` from 10 to 2.

**Reason:** The lower values better match the administrative use of this host while preserving legitimate access.

## D005: Increase SSH logging

**Decision:** Change `LogLevel` from INFO to VERBOSE.

**Reason:** More authentication context improves investigation and validation.

**Validation:** Wazuh Security Configuration Assessment recorded the SSH LogLevel control changing from failed to passed.

## D006: Apply selected sysctl hardening

**Decision:** Harden FIFO protection, setuid core dumps, kernel pointer exposure, SysRq, BPF JIT behavior, suspicious IPv4 logging, and ICMP redirect behavior.

**Reason:** These changes aligned with the role of the host and did not conflict with required administration or monitoring.

## D007: Retain `net.ipv4.conf.all.rp_filter=2`

**Decision:** Keep loose reverse path filtering instead of changing the value to the Lynis profile expectation of 1.

**Reason:** The host uses an overlay network. Loose reverse path filtering is less likely to interfere with asymmetric or overlay routing behavior.

**Validation:** Tailscale connectivity and a new SSH session succeeded after the sysctl changes.

## D008: Retain `kernel.unprivileged_bpf_disabled=2`

**Decision:** Do not change the value solely because Lynis expected 1.

**Reason:** Unprivileged BPF remains disabled at value 2 while preserving administrative reversibility.

## D009: Retain `kernel.modules_disabled=0`

**Decision:** Do not permanently disable kernel module loading.

**Reason:** Setting the value to 1 cannot be reversed until reboot and would reduce flexibility in this controlled learning environment.

## D010: Treat scanner output as advisory

**Decision:** Use Lynis and Wazuh SCA as evidence and prioritization tools, not as unquestioned compliance authorities.

**Reason:** Lynis reported version and OS database limitations, and Wazuh SCA referenced a CIS Ubuntu 24.04 benchmark while the endpoint ran Ubuntu 26.04.

The project therefore documents the scanner result, the operational context, the decision, and the validation outcome.
