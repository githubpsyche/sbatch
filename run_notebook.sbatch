#!/bin/bash
#SBATCH --job-name=nb
#SBATCH -A TALMI-SL3-CPU
#SBATCH -p icelake-himem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=04:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4

set -euo pipefail

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

ENV_SCRIPT="$HOME/workspace/cluster_env.sh"
if [ ! -f "$ENV_SCRIPT" ]; then
    echo "Error: missing environment script: $ENV_SCRIPT"
    exit 1
fi

source "$ENV_SCRIPT"

# Prevent matplotlib from trying to open display windows
export MPLBACKEND=Agg

# Match thread-aware libraries to the Slurm CPU request.
export OMP_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"
export MKL_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"
export OPENBLAS_NUM_THREADS="${SLURM_CPUS_PER_TASK:-1}"

# JAX: run on CPU by default for current CSD3 notebook jobs.
export JAX_PLATFORM_NAME=cpu

# ── Execute ──────────────────────────────────────────────────────────
echo "$(date): Starting $NOTEBOOK"
jupyter execute "$NOTEBOOK_NAME"
STATUS=$?
echo "$(date): Finished $NOTEBOOK (exit code $STATUS)"
exit $STATUS
