---
name: Training issue
about: Report a problem with dataset prep, QLoRA training, preflight, or the training pipeline
title: "[training] "
labels: training
assignees: ''
---

## Stage

- [ ] `prepare_dataset.py`
- [ ] `release_threshold.py`
- [ ] `preflight_train.py`
- [ ] `train_qlora.py`
- [ ] `merge_adapter.py`
- [ ] `scripts/run_training_pipeline.sh`

## What happened

Describe the problem and paste the exact command and output.

```bash
# command
```

```
# output / traceback
```

## Hardware & environment

- GPU (model, VRAM) or "CPU only":
- `nvidia-smi` output (if applicable):
- Python version:
- Train deps installed (`pip install -e ".[train]"`)? yes / no
- Base model / config used:

## Preflight result

Paste `python training/preflight_train.py` output (it exits `2` when no CUDA GPU
is available — that is expected on a laptop).

## Notes

- [ ] This is **not** a claim that a trained model exists; it is a pipeline issue.
