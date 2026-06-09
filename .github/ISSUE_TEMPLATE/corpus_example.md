---
name: Corpus example proposal
about: Propose a new curated training example (vulnerable or secure)
title: "[corpus] "
labels: corpus
assignees: ''
---

Curated examples are the heart of Nullsec S1. Every proposed example must be
**complete, source-backed, and Safety-Layer-consistent**. See
[CONTRIBUTING.md](../../CONTRIBUTING.md) and [docs/CORPUS.md](../../docs/CORPUS.md).

## Vulnerable code

```text
# paste the vulnerable (or, for a clean example, secure) code
# NO REAL SECRETS — use obvious placeholders
```

## Exploit scenario

How is this actually exploited?

## Taxonomy category & severity

- Category (from [`taxonomy/taxonomy.json`](../../taxonomy/taxonomy.json)):
- Severity (INFO/LOW/MEDIUM/HIGH/CRITICAL):
- Language / framework:

## Secure patch

```text
# the real fix (unified diff or corrected snippet)
```

## checks_performed (all 8 dimensions)

Briefly state each: `auth`, `secrets`, `input_validation`, `rate_limits`,
`permissions`, `dangerous_exec`, `dependency_risk`, `environment_exposure`
(`pass` / `fail` / `not_applicable` / `not_checked`).

## Expected Safety Layer behavior

- Expected `production_ready`:
- Which rule(s) (R1–R6) should fire, if any:

## Provenance (auditable source)

- source_type: `cve` / `semgrep` / `sarif` / `codeql` / `owasp` / `vibecoded_failure` / `hand_authored`
- reference: real CVE ID + CWE / rule_id / OWASP category / case_id (no vague sources)

## Checklist

- [ ] No real secrets — placeholders only.
- [ ] No invented CVE IDs, commit SHAs, or repo paths.
- [ ] Secure patch is real and complete.
- [ ] `expected_production_ready` matches what the Safety Layer would compute.
