# Nullsec-1 serving image (GPU). For a CPU-only image that runs just the
# Security Alignment + Safety Layers, swap the base for python:3.11-slim and
# install requirements.txt instead of requirements-train.txt.
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    NULLSEC_BASE_MODEL=Qwen/Qwen2.5-Coder-7B-Instruct \
    NULLSEC_4BIT=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 python3-pip git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt requirements-train.txt ./
RUN pip3 install --upgrade pip && pip3 install -r requirements-train.txt

COPY . .
RUN pip3 install -e .

EXPOSE 8000
# Mount a trained adapter at /adapter and set NULLSEC_ADAPTER_PATH=/adapter
HEALTHCHECK --interval=30s --timeout=5s --start-period=120s \
    CMD curl -fsS http://localhost:8000/health || exit 1

CMD ["uvicorn", "serving.server:app", "--host", "0.0.0.0", "--port", "8000"]
