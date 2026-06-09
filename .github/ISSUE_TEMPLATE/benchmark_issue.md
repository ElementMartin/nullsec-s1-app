---
name: Benchmark issue
about: Report a problem with the benchmark suite, metrics, runners, or safety probes
title: "[benchmark] "
labels: benchmark
assignees: ''
---

## Area

- [ ] `benchmarks/run_all.py` / suite
- [ ] A metric family (detection, false-safe, hallucination, OWASP, patch, secure-gen)
- [ ] A runner in `benchmarks/runners/`
- [ ] Adversarial safety probes (`benchmarks/safety_probes.py`)
- [ ] Benchmark dataset (`benchmarks/datasets/`)

## Run mode

- [ ] `--mode model` (live GPU)
- [ ] `--mode replay` (captured real outputs)

## What happened

```bash
# command
```

```
# output
```

## Expected vs actual

What metric/behavior did you expect, and what did you observe?

## Honesty note

Remember: numbers come **only** from real runs. A case with no model output is a
real miss, never a synthetic pass. If you believe a number is fabricated or a
probe is bypassable, please describe exactly how to reproduce it.

- [ ] I am **not** attaching or claiming precomputed/real-model benchmark numbers
      that did not come from an actual run.
