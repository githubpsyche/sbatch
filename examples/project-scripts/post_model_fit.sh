#!/bin/bash
# Example post-model-fit pipeline: submit analysis notebooks after a prior
# notebook batch completes.
# Intended to run as a sentinel job after pooled or aggregate jobs complete.
#
# Usage: post_model_fit.sh <project_dir>

set -euo pipefail

PROJECT_DIR="${1:?Usage: post_model_fit.sh <project_dir>}"
cd "$PROJECT_DIR"

source "$HOME/workspace/cluster_env.sh"
export UV_NO_PROJECT=1

echo "$(date): Submitting analysis notebooks"
"$HOME/workspace/sbatch/submit_notebooks.sh" \
    "$PROJECT_DIR/analyses/rendered" \
    "analysis_*.ipynb"

echo "$(date): Post-model-fit pipeline complete"
