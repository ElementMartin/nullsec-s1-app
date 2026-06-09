# GPU Quickstart — Training Nullsec S1

This is the beginner-friendly, end-to-end guide to running a real Nullsec S1
(`Nullsec-1.0`) QLoRA training run on a GPU. If you have never rented a GPU
before, start here.

If you only want to run the released model, download the `v1.0.0-rc25` GitHub
Release artifact, unpack it, set `NULLSEC_ADAPTER_PATH=outputs/nullsec-s1-qlora`,
and run `python inference.py --file examples/unsafe-next-admin-route.ts`. The GPU
training flow below is for reproducing or continuing the release, not for normal
release consumption.

> **Why a GPU?** Your laptop can verify the corpus, the deterministic safety
> layers, and the adversarial probes (that is what `pytest` and the validators
> do). It **cannot** realistically fine-tune a 7B model. QLoRA training needs a
> CUDA-capable NVIDIA GPU with enough VRAM to hold a 4-bit base model plus LoRA
> optimizer state.

> **Using RunPod?** Follow the dedicated, copy-paste **[RunPod guide:
> `RUNPOD.md`](RUNPOD.md)** — it covers GPU/storage selection, the web terminal,
> and artifact packaging step by step. This file is the provider-agnostic version.

---

## 1. What a "GPU box" is

A GPU box is just a Linux machine with an NVIDIA GPU attached. You can:

- **Rent one by the hour** from a cloud provider (RunPod, Lambda, Vast.ai,
  Paperspace, AWS/GCP/Azure). This is the cheapest way to do a one-off run.
- **Use your own** desktop if it has an NVIDIA GPU (e.g. RTX 3090/4090).

You connect over SSH (or a web terminal/notebook the provider gives you), run
the pipeline, download the resulting adapter, and shut the box down so you stop
paying.

---

## 2. Recommended GPUs

| GPU | VRAM | Nullsec S1 config | Notes |
|-----|------|-------------------|-------|
| RTX 3090 / 4090 | 24 GB | 7B (default) | The target configuration. 4-bit QLoRA, batch 1 × grad-accum 16. |
| A5000 / A6000 | 24–48 GB | 7B comfortably, 14B on 48 GB | More headroom for longer context. |
| A100 40GB / 80GB | 40–80 GB | 14B (config swap) | Uncomment the 14B override block in `training/config.yaml`. |

A **single 24 GB GPU is enough** for the default 7B run. You do not need a
multi-GPU cluster.

---

## 3. Disk requirements

Budget roughly:

- **~16 GB** for the `Qwen2.5-Coder-7B-Instruct` base model download.
- **~1 GB** for the trained adapter and tokenizer outputs.
- **~10 GB** headroom for the Python/CUDA environment and caches.

**Provision at least 60 GB** of disk on the box to be safe (more for 14B, which
downloads a larger base and, if you merge, writes dense weights).

---

## 4. Clone the repo

On the GPU box:

```bash
git clone https://github.com/<your-org>/nullsec-s1.git
cd nullsec-s1
```

(Replace the URL with wherever this repo lives. If you uploaded a tarball, just
`cd` into the extracted directory.)

---

## 5. Set up the environment

Use Python 3.11 (the version this project is developed and tested on):

```bash
python3.11 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip setuptools wheel
```

---

## 6. Install the training dependencies

The base install (`.[dev]`) has no GPU stack. RC2/v1.1 was finalized on B200 /
CUDA 12.8. Earlier A100/RC1 runs used the CUDA 12.1 stack below; choose the torch
build that matches your GPU image/driver, then install the rest of the stack:

```bash
python -m pip install -e ".[dev]"
python -m pip install torch==2.5.1+cu121 --index-url https://download.pytorch.org/whl/cu121
python -m pip install -r requirements-train-cu121.txt
```

Then **verify CUDA is usable**:

```bash
python -c "import torch; print(torch.__version__, torch.version.cuda, torch.cuda.is_available())"
# expect e.g.  2.5.1+cu121 12.1 True
```

> **B200 / CUDA 12.8 note.** The final RC2/v1.1 run used a B200 setup with a
> CUDA 12.8-compatible torch build. If `torch.cuda.is_available()` is `False`
> while `nvidia-smi` shows a GPU, that is a Torch/CUDA mismatch. Use a torch
> wheel matching the host driver, then rerun `training/preflight_train.py`.
> If `datasets` raises an fsspec error, pin `pip install "fsspec==2024.6.1"`.

If `bitsandbytes` complains, make sure the box actually has an NVIDIA driver and
CUDA runtime (`nvidia-smi` should print your GPU). Most rented GPU images ship
with these preinstalled.

---

## 7. Prepare the dataset

Build the chat-formatted train/eval JSONL from the curated corpus. Every record
is validated through the same alignment + safety layers used at serving time:

```bash
python training/prepare_dataset.py --include-ingested --out data/processed
```

You should see `1393 -> train.jsonl` and `348 -> eval.jsonl` (1,741 total, current corpus).

---

## 8. Run preflight

Before spending GPU time, run the preflight check. It verifies the GPU, the
dependencies, the dataset, the corpus threshold, and the safety probes:

```bash
python training/preflight_train.py
```

- On a laptop with **no GPU**, this prints a clear table and **exits with code
  `2`** — that is expected, and it is telling you to move to a GPU box.
- On a properly set-up GPU box, every row should read `OK` and it exits `0`
  (`RESULT: READY`).

---

## 9. Run the training pipeline

The simplest path is the one-shot pipeline script, which runs
prepare → validate → threshold → preflight → train → benchmark → release →
claim-validation in order:

```bash
bash scripts/run_training_pipeline.sh
```

Or do it step by step:

```bash
python training/train_qlora.py --config training/config.yaml
```

Training the 7B default for 3 epochs on the current corpus is a short run on a
24 GB card (minutes-to-low-hours depending on the GPU). Progress logs print
every few steps.

Useful environment overrides for the pipeline script:

```bash
ADAPTER_OUT=outputs/nullsec-s1-qlora \
DATASET=detection.json \
MERGE=1 \
bash scripts/run_training_pipeline.sh
```

(`MERGE=1` additionally merges the adapter into dense weights for high-throughput
serving — optional.)

---

## 10. Collect the outputs

After a successful run you will have:

```
outputs/nullsec-s1-qlora/
  adapter_config.json
  adapter_model.safetensors
  tokenizer.json / tokenizer_config.json / ...
```

Download this directory to your own machine (or push it to your model storage):

```bash
# from your laptop:
scp -r user@gpu-box:~/nullsec-s1/outputs/nullsec-s1-qlora ./
```

If you ran the full pipeline, you will also have:

- `benchmarks/reports/SUITE.json` — real benchmark numbers from your model.
- `releases/nullsec-1.0/` — a release bundle (only if every release gate passed).

---

## 11. Stop the GPU machine

**This is the step people forget.** Rented GPUs bill by the second.

- On a cloud provider: **terminate/stop the instance** from their dashboard once
  your outputs are downloaded.
- Confirm it is actually stopped — a "paused" box may still incur storage costs.

Your trained adapter lives in the files you downloaded; you do not need the box
anymore.

---

## 12. Expected artifacts checklist

A complete run produces:

- [ ] `data/processed/train.jsonl` and `eval.jsonl` (1,393 / 348 records, current corpus)
- [ ] `outputs/nullsec-s1-qlora/adapter_config.json` + `adapter_model.safetensors`
- [ ] tokenizer files alongside the adapter
- [ ] `benchmarks/reports/SUITE.json` with `run_mode: "model"` and non-empty results
- [ ] `releases/nullsec-1.0/` with `safety_probes.json` showing `passed: true`
- [ ] `python scripts/validate_claims.py --adapter outputs/nullsec-s1-qlora --report releases/nullsec-1.0/benchmark/SUITE.json --check` passes

Only once those artifacts exist locally will the claim validator permit the
release-backed trained/benchmarked wording for that checkout. The published
RC2/v1.1 artifacts are available from the `v1.0.0-rc25` GitHub Release.

For the conceptual flow and the meaning of each gate, see
[`RELEASE_TRAINING.md`](RELEASE_TRAINING.md) and
[`docs/SYSTEM_OVERVIEW.md`](docs/SYSTEM_OVERVIEW.md).
