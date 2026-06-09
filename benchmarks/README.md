# Nullsec-1 Benchmarks

The benchmark suite measures Nullsec-1 across six metric families. It is built on one rule:

> **No invented numbers.** A report is produced only after obtaining real Nullsec-1 outputs for a labeled dataset. The repository ships no precomputed results.

## Modes

Every runner takes `--mode`:

- `--mode model` — run the live Nullsec-1 reasoning pipeline over each case (needs the GPU stack and, normally, a trained adapter via `--adapter`).
- `--mode replay --replay <file.jsonl>` — score previously captured **real** Nullsec-1 outputs. The replay file is JSONL of `{"id": <case_id>, "raw": <raw model output>}`.

A case with no available output is scored as a **real miss**, never as a synthetic pass. Datasets in `datasets/` contain ground-truth labels only — never results.

## Metric families

| Runner | Measures |
|--------|----------|
| `run_detection_accuracy.py` | precision / recall / F1 of findings vs. labeled categories |
| `run_false_safe_rate.py` | fraction of unsafe cases marked `production_ready` after the Safety Layer (primary safety metric; target 0) |
| `run_hallucination_rate.py` | fraction of clean cases on which Nullsec-1 invents findings |
| `run_owasp_coverage.py` | per-category detection recall against OWASP Top 10 (2021) / OWASP LLM Top 10 (2025) tags |
| `run_patch_correctness.py` | structural correctness of generated patches (runtime verification is future work) |
| `run_secure_generation.py` | fraction of generated patches free of known-insecure signal tokens |

## Running

```bash
# everything at once -> benchmarks/reports/SUITE.json
python benchmarks/run_all.py --mode model --adapter outputs/nullsec-s1-qlora

# a single family
python benchmarks/runners/run_false_safe_rate.py --mode model --adapter outputs/nullsec-s1-qlora

# against captured outputs, no GPU
python benchmarks/run_all.py --mode replay --replay captured.jsonl
```

## Reports

Reports are written to `benchmarks/reports/` (git-ignored). Every report carries a `provenance` block: model name, version, fingerprint, taxonomy version, run mode, adapter, dataset, and UTC timestamp — so any number can be traced to the exact Nullsec-1 release and dataset that produced it.

## Baselines

Baseline runners live under `benchmarks/baselines/`:

```bash
# Base model, no Nullsec adapter (GPU required)
python benchmarks/baselines/base_qwen.py --mode model

# Semgrep static-analysis baseline (CPU; requires semgrep)
python -m pip install semgrep
python benchmarks/baselines/semgrep_baseline.py

# Markdown comparison from generated reports
python benchmarks/compare_baselines.py \
  --nullsec benchmarks/reports/SUITE.json \
  --base benchmarks/reports/baselines/qwen2_5_coder_7b/SUITE.json \
  --semgrep benchmarks/reports/baselines/semgrep/SUITE.json
```

Generated baseline reports are written under `benchmarks/reports/baselines/` and
are not committed by default. See [`docs/EVALS.md`](../docs/EVALS.md).

## Datasets

`datasets/detection.json` is the labeled corpus: each case has `code`, `expected_categories`, `expected_min_severity`, `expected_production_ready`, and (where applicable) an `owasp` tag. It is part of the initial seed and is meant to grow with the ingestion pipeline; benchmark strength scales with corpus breadth.
