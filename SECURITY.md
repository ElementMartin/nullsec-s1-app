# Security Policy

Nullsec S1 is a security project, so we hold our own disclosure process to a high
standard. Thank you for helping keep it and its users safe.

## Reporting a vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

Report privately through one of these channels:

1. **GitHub private vulnerability reporting (preferred).** On the repository, go
   to the **Security** tab → **Report a vulnerability**. This opens a private
   advisory visible only to maintainers. (Requires the maintainer to enable
   "Private vulnerability reporting" in repo settings.)
2. **Email.** Send details to the project's security contact.
   `security@nullsec.studio` is the intended placeholder address —
   **maintainers: replace this with a real, monitored inbox before relying on
   it.** Until confirmed, prefer channel 1.

Please include:

- a description of the issue and its impact,
- steps to reproduce or a proof of concept,
- affected component/version (commit SHA if possible),
- any suggested remediation.

## What to expect

- We aim to acknowledge a report within a few business days.
- We will work with you to validate, assess severity, and develop a fix.
- We will credit reporters who wish to be credited once a fix is released.
- Please allow a reasonable disclosure window before any public discussion
  (responsible disclosure).

## Rules for reporters (and for examples/corpus)

- **Never submit real secrets.** Use placeholders for any credential, key, token,
  or seed phrase (e.g. `sk-EXAMPLE...`, `PLACEHOLDER_NOT_A_REAL_KEY`). Reports or
  examples containing real credentials will be redacted, and you should rotate the
  exposed secret immediately.
- **No real CVE fabrication.** Do not attach invented CVE IDs, commit SHAs, or
  repository paths.
- Test only against systems and code you own or are authorized to test.

## Scope

This policy covers the Nullsec S1 framework in this repository: the reasoning
pipeline, the Security Alignment Layer and Nullsec Safety Layer, the serving
layer, the CLI, the training and benchmark code, and the release/claim-validation
scripts.

Note that Nullsec S1 is a security review aid, **not** a guarantee: a clean
verdict reduces but does not eliminate risk, and the project does not claim to
catch every vulnerability (see [`docs/NON_CLAIMS.md`](docs/NON_CLAIMS.md)).
