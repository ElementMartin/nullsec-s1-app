# Contributing to Nullsec S1

Thank you for helping build a security-native LLM system for AI-generated
software. This project earns trust by being **rigorous, not by exaggerating** —
contributions are held to that same standard.

The reference implementation is the `nullsec1` package/CLI; the model release
identity is `Nullsec-1.0`.

---

## Ground rules (read first)

- **No fake anything.** No fabricated benchmark numbers, no invented CVE IDs or
  commit SHAs, no real-looking-but-fake metrics, no claims the artifacts don't
  support. The honesty gate (`scripts/validate_claims.py`) enforces this in CI.
- **No real secrets.** Use obvious placeholders for any credential.
- **Don't weaken gates.** Never lower a threshold (`release_threshold.py`),
  loosen the Safety Layer, or relax claim validation just to make something pass.
- **Keep one enforcement path.** All verdicts must flow through the same
  alignment + safety layers; don't add a side path that bypasses them.

---

## Development setup

```bash
python3.11 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip setuptools wheel
python -m pip install -e ".[dev]"     # no GPU stack needed for most work
```

Run the local checks before opening a PR:

```bash
pytest -q
python training/prepare_dataset.py --include-ingested --out data/processed
python training/validate_corpus.py --include-ingested
python training/release_threshold.py --include-ingested
python scripts/validate_claims.py --check
python -m benchmarks.safety_probes
```

CI additionally greps source for prohibited words and runs the honesty check, so
keep `nullsec/`, `serving/`, `cli/`, `benchmarks/`, `training/`, and `scripts/`
free of `demo`/`mock`/`toy`/`placeholder`/`simulated`/`fake` in `.py` files.

---

## What to contribute

### 1. Corpus examples

The highest-leverage contribution. Each curated example **must** include:

1. **Vulnerable code** (or clean code, for a `production_ready: true` example) —
   real and self-contained, **no real secrets**.
2. **Exploit scenario** — how it is actually abused.
3. **Category** — from [`taxonomy/taxonomy.json`](taxonomy/taxonomy.json).
4. **Severity** — INFO/LOW/MEDIUM/HIGH/CRITICAL (will be floored to the category
   default by the alignment layer if you under-rate it).
5. **Secure patch** — a real, complete fix (unified diff or corrected snippet).
6. **`checks_performed`** — an explicit status for **all 8 dimensions**.
7. **Expected Safety Layer behavior** — the `expected_production_ready` value,
   which must equal what `align_and_enforce` computes for the verdict.
8. **Provenance / source reference** — an auditable source (real CVE ID + CWE,
   Semgrep/SARIF `rule_id`, OWASP category, or a `vibecoded_failure` `case_id`
   with reviewer notes). Vague sources are rejected by `training/provenance.py`.

Workflow and schema are documented in [`docs/CORPUS.md`](docs/CORPUS.md). Ingested
data goes through staging → review → `curated_ingested` and only counts after it
passes `validate_corpus.py --include-ingested`. **Synthetic variants never count
toward curated thresholds.**

### 2. Taxonomy improvements

Propose new categories, dimension mappings, severities, CWE references, or
detection signals. The taxonomy is the single source of truth and ripples into
the schema, prompts, and Safety Layer — open a `[taxonomy]` issue first to discuss
impact, and add corpus coverage for any new category.

### 3. Safety probes

New adversarial probes in [`benchmarks/safety_probes.py`](benchmarks/safety_probes.py)
that try to obtain `production_ready: true` for unsafe input make the Safety Layer
stronger. A good probe is deterministic and asserts the pipeline **blocks** it.

### 4. Benchmark runners & metrics

Improvements to `benchmarks/runners/` and `benchmarks/metrics.py`. Numbers must
come only from real runs; a case with no output is a real miss.

### 5. Docs

Architecture, system overview, corpus, safety layer, roadmap, examples — clarity
and correctness improvements are very welcome.

### 6. CLI / API improvements

Enhancements to `cli/nullsec1.py` and `serving/server.py` (e.g. output formats, CI
ergonomics) that preserve the single enforcement path.

---

## Pull request expectations

Open PRs against `main`. Fill out the [PR template](.github/pull_request_template.md)
checklist honestly:

- tests pass · corpus validation passes · no fake claims · no real secrets ·
  no unverified CVEs · no weakened thresholds · Safety Layer consistency preserved.

Small, focused PRs review fastest. For larger changes (taxonomy, safety layer,
schema), open an issue first.

---

## Code of conduct

Be respectful and constructive. Security work attracts strong opinions; keep
discussion technical and evidence-based.
