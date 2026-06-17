#!/bin/bash
# Example post-fit pipeline: merge per-unit partial outputs, clean up
# intermediate prepared notebooks, then submit next-stage notebooks.
# Intended to run as a sentinel job after per-unit notebook jobs complete.
#
# Usage: post_fit.sh <project_dir>

set -euo pipefail

PROJECT_DIR="${1:?Usage: post_fit.sh <project_dir>}"
cd "$PROJECT_DIR"

source "$HOME/workspace/cluster_env.sh"
export UV_NO_PROJECT=1

echo "$(date): Merging partial outputs in $PROJECT_DIR"
python scripts/merge_partials.py

echo "$(date): Cleaning up per-unit rendered notebooks"
rm -f "$PROJECT_DIR"/analyses/rendered/fitting_*_unit*.ipynb
rm -f "$PROJECT_DIR"/analyses/rendered/fitting_*_sub*.ipynb

echo "$(date): Submitting next-stage notebooks"
"$HOME/workspace/sbatch/submit_notebooks.sh" \
    "$PROJECT_DIR/analyses/rendered" \
    "fitting_*.ipynb"

echo "$(date): Post-fit pipeline complete"
