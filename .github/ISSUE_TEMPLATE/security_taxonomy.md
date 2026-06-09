---
name: Security taxonomy proposal
about: Propose a new category, dimension mapping, or change to the security taxonomy
title: "[taxonomy] "
labels: taxonomy
assignees: ''
---

The taxonomy (`taxonomy/taxonomy.json`) is the single source of truth for
categories and their mapping to the 8 check dimensions. Changes here ripple
through the schema, prompts, corpus validation, and the Safety Layer — propose
carefully.

## Proposal type

- [ ] New category
- [ ] Change to an existing category (severity, signals, CWE, description)
- [ ] Change to a category → check-dimension mapping
- [ ] New / changed check dimension (high impact — explain thoroughly)

## Details

### Proposed `id` and `title`

### Default severity

INFO / LOW / MEDIUM / HIGH / CRITICAL — with justification.

### Primary `check_dimension`

One of: `auth`, `secrets`, `input_validation`, `rate_limits`, `permissions`,
`dangerous_exec`, `dependency_risk`, `environment_exposure`.

### CWE reference(s)

### Description & detection signals

### Why the existing taxonomy is insufficient

Especially relevant for AI-generated / agent / MCP / Web3 failure modes.

## Impact

- [ ] Requires new corpus coverage (≥ minimum per-category examples).
- [ ] Affects the verdict schema or required dimensions.
- [ ] Affects Safety Layer enforcement rules.
