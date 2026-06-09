# Producing Nullsec-1.0 — Training to Release

This is the exact path from the current repo (a real training, serving, and
safety framework) to a trained Nullsec-1.0 artifact with real benchmark numbers.
Every step is runnable; the release pipeline refuses to produce a bundle unless
each prior step really happened.

> **RC1 has already run this path** on a RunPod **A100 80GB** box with the
> hardened CUDA 12.1 stack (`torch==2.5.1+cu121`). RC1's adapter, real-model
> benchmark report, and safety-probe results are published as a **GitHub Release**,
> not committed to this source repo (trained weights ship as release assets; the
> repo stays lightweight). RC1's reported metrics are in
> [`docs/ROADMAP.md`](docs/ROADMAP.md). **RC2 / v1.1** re-runs this path on a larger
> corpus and the expanded 111-case benchmark; see the RC2 gate
> (`training/release_threshold.py --profile rc2`).

## 0. Environment

Install the known-good CUDA 12.1 stack (the build that completed RC1). Install the
pinned torch first so nothing replaces it:

```bash
python -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
pip install torch==2.5.1+cu121 --index-url https://download.pytorch.org/whl/cu121
pip install -r requirements-train-cu121.txt
python -c "import torch; print(torch.__version__, torch.version.cuda, torch.cuda.is_available())"  # 2.5.1+cu121 12.1 True
python -m nullsec.core.version # sanity: prints identity + fingerprint
```

A CUDA 13 / Torch 2.12 wheel failed on the RunPod driver during RC1; if
`torch.cuda.is_available()` is `False` while `nvidia-smi` shows a GPU, reinstall
the cu121 line. `python training/preflight_train.py` detects this mismatch.

Target hardware for v1: a single 24GB GPU (QLoRA, 4-bit). The 14B config in
`training/config.yaml` targets A100/40GB+ and is a config-only swap.

## 1. Prepare the dataset

```bash
python training/prepare_dataset.py --out data/processed
```

Reads the curated corpus (`corpus/`, the single source of truth), validates every
verdict through the Security Alignment Layer and Nullsec Safety Layer, and writes
`data/processed/train.jsonl` and `eval.jsonl`. The record count matches
`dataset_stats.py` for the same flags. **Scale the corpus before relying on the
model** — ingest into a staging area, curate, then land validated records in
`corpus/ingested/` (included with `--include-ingested`):

```bash
python -m nullsec.ingest.import_cve --help       # CVE/NVD -> verdicts
python -m nullsec.ingest.import_scanners --help   # Semgrep / SARIF / CodeQL -> verdicts
# curate the NEEDS_CURATION patch/check fields, then re-run prepare_dataset.py
```

## 2. Train the QLoRA adapter

```bash
python training/train_qlora.py --config training/config.yaml
```

Fine-tunes the base (Qwen2.5-Coder-7B-Instruct by default) with 4-bit NF4 QLoRA
and completion-only loss. The adapter is written to the output dir in
`config.yaml` (e.g. `outputs/nullsec-s1-qlora/`), containing `adapter_config.json`
and `adapter_model.safetensors`.

## 3. (Optional) Merge the adapter

```bash
python training/merge_adapter.py \
    --base Qwen/Qwen2.5-Coder-7B-Instruct \
    --adapter outputs/nullsec-s1-qlora \
    --out outputs/nullsec-s1-merged
```

Use the merged model for high-throughput serving (vLLM/TGI). The Safety Layer
runs in front of either form.

## 4. Fingerprint

```bash
NULLSEC_ADAPTER_PATH=outputs/nullsec-s1-qlora python -m nullsec.core.version
```

The fingerprint now folds in the trained `adapter_config.json`, so the release
identity reflects the actual weights.

## 5. Evaluate (real model)

```bash
python benchmarks/run_all.py --mode model --adapter outputs/nullsec-s1-qlora
```

Produces real numbers in `benchmarks/reports/SUITE.json`. Numbers come only from
real model outputs — a case with no output is a real miss, never a synthetic
pass.

## 6. Build the release bundle

```bash
python scripts/release_candidate.py \
    --adapter outputs/nullsec-s1-qlora \
    --dataset benchmarks/datasets/detection.json
```

This re-runs the benchmarks against the live model, runs the adversarial Safety
Layer probes, and writes `releases/nullsec-1.0/` with the adapter config,
tokenizer files, fingerprint, benchmark report, captured raw outputs, model/
dataset card snapshots, version files, and a `RELEASE_SUMMARY.md` generated from
the measured numbers. It aborts (writing nothing) if the adapter is missing, the
model fails to load, no outputs are produced, a report section is empty, or any
Safety Layer probe is bypassed.

## 7. Validate public claims

```bash
python scripts/validate_claims.py \
    --adapter outputs/nullsec-s1-qlora \
    --report releases/nullsec-1.0/benchmark/SUITE.json --check
```

Prints which public claims the artifacts now support and fails if README.md or
RELEASE_SUMMARY.md asserts anything they don't. Only after this passes with a
trained adapter and a real-model report may the repo describe Nullsec-1.0 as a
trained, evaluated model. Novelty claims ("first", "only") are never granted by
the pipeline and must be supported independently.

## Definition of done for Nullsec-1.0

- `outputs/nullsec-s1-qlora/adapter_config.json` + weights exist.
- `releases/nullsec-1.0/benchmark/SUITE.json` has `run_mode: "model"` and non-empty results.
- `releases/nullsec-1.0/safety_probes.json` has `passed: true`.
- `scripts/validate_claims.py --check` passes.
