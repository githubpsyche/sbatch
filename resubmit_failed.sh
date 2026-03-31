#!/bin/bash
# Resubmit failed tasks from a previous run.
#
# Reads the manifest and sacct state from a run directory, copies failed
# notebooks to <run_dir>/resubmit/, and submits them via submit_notebooks.sh.
#
# Usage: ./resubmit_failed.sh [--sentinel <script>] <run_dir>

set -euo pipefail

SBATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse --sentinel flag
SENTINEL_ARGS=()
if [ "${1:-}" = "--sentinel" ]; then
    if [ "$#" -lt 2 ]; then
        echo "Error: --sentinel requires a script path"
        exit 1
    fi
    SENTINEL_ARGS=(--sentinel "$2")
    shift 2
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: ./resubmit_failed.sh [--sentinel <script>] <run_dir>"
    exit 1
fi

RUN_DIR="$1"

if [ ! -d "$RUN_DIR" ]; then
    echo "Error: run directory not found: $RUN_DIR"
    exit 1
fi

MANIFEST="$RUN_DIR/manifest.txt"
if [ ! -f "$MANIFEST" ]; then
    echo "Error: no manifest.txt in $RUN_DIR"
    exit 1
fi

SUBMISSION="$RUN_DIR/submission.txt"
if [ ! -f "$SUBMISSION" ]; then
    echo "Error: no submission.txt in $RUN_DIR"
    exit 1
fi

JOBID=$(grep -o '[0-9]\+' "$SUBMISSION" | head -1)
if [ -z "$JOBID" ]; then
    echo "Error: could not parse job ID from $SUBMISSION"
    exit 1
fi

# Get task states from sacct
declare -A TASK_STATE
while IFS='|' read -r taskid state; do
    idx="${taskid##*_}"
    [[ "$idx" == *"."* ]] && continue
    TASK_STATE["$idx"]="$state"
done < <(sacct -j "$JOBID" --format=JobID%-30,State%-15 --noheader --parsable2 2>/dev/null)

# Find failed notebooks
FAILED_NOTEBOOKS=()
TASK_INDEX=0
while IFS= read -r notebook; do
    [ -n "$notebook" ] || continue
    state="${TASK_STATE[$TASK_INDEX]:-UNKNOWN}"
    if [ "$state" = "FAILED" ]; then
        FAILED_NOTEBOOKS+=("$notebook")
    fi
    TASK_INDEX=$((TASK_INDEX + 1))
done < "$MANIFEST"

if [ "${#FAILED_NOTEBOOKS[@]}" -eq 0 ]; then
    echo "No failed tasks found in $RUN_DIR"
    exit 0
fi

echo "${#FAILED_NOTEBOOKS[@]} failed notebooks:"
for nb in "${FAILED_NOTEBOOKS[@]}"; do
    echo "  $nb"
done

# Copy failed notebooks to resubmit directory
RESUBMIT_DIR="$RUN_DIR/resubmit"
mkdir -p "$RESUBMIT_DIR"
for nb in "${FAILED_NOTEBOOKS[@]}"; do
    cp "$nb" "$RESUBMIT_DIR/"
done

# Submit
"$SBATCH_DIR/submit_notebooks.sh" \
    "${SENTINEL_ARGS[@]}" \
    "$RESUBMIT_DIR" \
    "*.ipynb"
