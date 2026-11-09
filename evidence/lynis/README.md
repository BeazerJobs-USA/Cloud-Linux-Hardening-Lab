# Lynis Evidence

## Baseline

Lynis 3.1.6 completed 261 tests and reported:

```text
Hardening index: 69
Warnings: 0
Suggestions: 42
```

## Measured remediation

After the selected SSH remediation, the hardening index increased to 73.

The project does not treat the hardening index as a compliance score or a substitute for engineering judgment. Remaining kernel findings were reviewed against the host's operational requirements and Tailscale networking before deciding whether to change them.

## Tool limitations observed

The audit itself reported that Lynis 3.1.6 was more than six months old and that Ubuntu 26.04 did not have an entry in the tool's end of life database. Those limitations are part of the reason findings were evaluated manually.
