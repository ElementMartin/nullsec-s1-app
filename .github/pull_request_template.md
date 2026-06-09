# Pull request

## Summary

What does this PR change, and why?

## Type of change

- [ ] Corpus example(s)
- [ ] Taxonomy change
- [ ] Safety layer / enforcement
- [ ] Safety probe(s)
- [ ] Benchmark runner / metric
- [ ] Training pipeline
- [ ] Serving / CLI / API
- [ ] Docs
- [ ] Other:

## Verification

Paste the relevant command output:

```bash
pytest -q
python training/validate_corpus.py --include-ingested
python training/release_threshold.py --include-ingested
python scripts/validate_claims.py --check
python -m benchmarks.safety_probes
```

## Checklist

- [ ] **Tests pass** (`pytest -q`).
- [ ] **Corpus validation passes** (`validate_corpus.py --include-ingested`).
- [ ] **No fake claims** — `scripts/validate_claims.py --check` passes; nothing
      asserts trained/benchmarked/release-candidate/production-ready or
      first/only/best that the artifacts don't support.
- [ ] **No real secrets** — credentials are obvious placeholders only.
- [ ] **No unverified CVEs** — no invented CVE IDs, commit SHAs, or repo paths.
- [ ] **No weakened thresholds** — release/threshold gates were not lowered to pass.
- [ ] **Safety Layer consistency preserved** — `safety_probes` shows 0 bypassed and
      corpus Safety Layer consistency stays at 100%.

## Notes for reviewers

Anything reviewers should focus on (trade-offs, follow-ups, open questions).
