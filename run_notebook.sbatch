#!/bin/bash
#SBATCH --job-name=nb
#SBATCH --time=04:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4

set -euo pipefail

# --- Customize these for your cluster ---
# module load python/3.12
# module load cuda/12  # uncomment for GPU jobs

# ── Resolve notebook path ────────────────────────────────────────────
# Two modes:
#   1. Job array:  reads line $SLURM_ARRAY_TASK_ID from $MANIFEST
#   2. Single job: pass the notebook path as $1
MANIFEST="${MANIFEST:-}"

if [ -n "${SLURM_ARRAY_TASK_ID:-}" ] && [ -n "$MANIFEST" ] && [ -f "$MANIFEST" ]; then
    NOTEBOOK=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1))p" "$MANIFEST")
else
    NOTEBOOK="${1:-}"
fi

if [ -z "$NOTEBOOK" ]; then
    echo "Error: no notebook specified."
    echo "Usage (single): sbatch run_notebook.sbatch <notebook.ipynb>"
    echo "Usage (array):  submit_notebooks.sh /path/to/notebooks"
    exit 1
fi

if [ ! -f "$NOTEBOOK" ]; then
    echo "Error: notebook not found: $NOTEBOOK"
    exit 1
fi

NOTEBOOK_DIR="$(cd "$(dirname "$NOTEBOOK")" && pwd)"
NOTEBOOK_NAME="$(basename "$NOTEBOOK")"

# ── Environment ──────────────────────────────────────────────────────
cd "$NOTEBOOK_DIR" || exit 1

# Prevent matplotlib from trying to open display windows
export MPLBACKEND=Agg

# JAX: default to CPU; uncomment the gpu line and comment the cpu line for GPU
export JAX_PLATFORM_NAME=cpu
# export JAX_PLATFORM_NAME=gpu

# Optional: limit JAX memory preallocation (useful on shared nodes)
# export XLA_PYTHON_CLIENT_MEM_FRACTION=0.5

# ── Execute ──────────────────────────────────────────────────────────
echo "$(date): Starting $NOTEBOOK"
uv run jupyter execute "$NOTEBOOK_NAME"
STATUS=$?
echo "$(date): Finished $NOTEBOOK (exit code $STATUS)"
exit $STATUS
