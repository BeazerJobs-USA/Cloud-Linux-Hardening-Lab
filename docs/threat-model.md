# Threat Model

## Assets

The lab protects the following assets:

* administrative access to the Ubuntu cloud host
* SSH private key based authentication
* system and security configuration
* audit and monitoring telemetry
* availability of the remote administration path

## Trust boundaries

1. **Public Internet to cloud host**
   The public interface is untrusted. Administrative SSH should not be reachable through this boundary.

2. **Tailscale overlay to cloud host**
   This is the approved administrative path. The workstation must participate in the private overlay before reaching SSH.

3. **Authenticated SSH session to operating system**
   Authentication does not imply unlimited session capability. OpenSSH settings restrict forwarding, sessions, and authentication attempts.

4. **Operating system to monitoring stack**
   auditd and the Wazuh agent provide visibility into configuration, authentication, privilege, and file integrity activity.

## Primary threats considered

| Threat | Security concern | Control |
| --- | --- | --- |
| Internet SSH scanning | Unnecessary exposure of the administrative service | UFW removes generic public TCP/22 access |
| Password or root login abuse | Direct credential attack against privileged access | Password authentication and root login disabled |
| Repeated SSH authentication attempts | Credential guessing and noisy abuse | Fail2ban plus reduced `MaxAuthTries` |
| Unnecessary SSH session capability | Forwarding features can expand what an authenticated session can do | X11, TCP, and agent forwarding disabled |
| Configuration tampering | Security controls may be weakened without visibility | auditd watches and Wazuh monitoring |
| Weak kernel defaults | Local attack surface and information exposure | Selected sysctl hardening |
| Monitoring loss after hardening | A security change could break telemetry | Wazuh agent and security services revalidated after changes |
| Unsafe remediation | Remote hardening can lock out the administrator | Second private SSH session and provider console recovery path |

## Assumptions

* The administrative workstation and Tailscale account are trusted.
* The cloud provider account and recovery console are protected separately.
* Private SSH key material remains outside the repository.
* The host is a controlled lab system, not a production application server.

## Residual risk

The project does not eliminate all endpoint risk.

Important remaining dependencies include:

* compromise of the administrative workstation
* compromise of the Tailscale or cloud provider account
* software vulnerabilities outside the specific hardening scope
* future configuration drift
* kernel or application vulnerabilities not mitigated by the selected sysctl controls

## Out of scope

This project does not claim:

* formal CIS compliance
* full vulnerability remediation
* application security testing
* container security
* enterprise identity governance
* compromise detection beyond the monitoring evidence shown
* production high availability or disaster recovery
