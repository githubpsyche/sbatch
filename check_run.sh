#!/bin/bash

set -euo pipefail

usage() {
    echo "Usage: ./check_run.sh <run_dir>"
    echo
    echo "Shows status and notebook path for each task in a submission run."
    echo
    echo "Examples:"
    echo "  ./check_run.sh ~/workspace/lpp_ecmr/runs/20260329-143000-12345"
    echo "  ./check_run.sh runs/20260329-143000-12345  # relative path"
}

if [ "$#" -ne 1 ]; then
    usage
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

# Extract job ID(s) from submission.txt
JOBID=$(grep -o '[0-9]\+' "$SUBMISSION" | head -1)

if [ -z "$JOBID" ]; then
    echo "Error: could not parse job ID from $SUBMISSION"
    exit 1
fi

# Get task states from sacct
declare -A TASK_STATE
while IFS='|' read -r taskid state; do
    # taskid looks like "26507282_0" — extract the array index
    idx="${taskid##*_}"
    # Skip the batch step entries (e.g. "26507282_0.batch")
    [[ "$idx" == *"."* ]] && continue
    TASK_STATE["$idx"]="$state"
done < <(sacct -j "$JOBID" --format=JobID%-30,State%-15 --noheader --parsable2 2>/dev/null)

# Display
TASK_INDEX=0
while IFS= read -r notebook; do
    [ -n "$notebook" ] || continue
    state="${TASK_STATE[$TASK_INDEX]:-UNKNOWN}"
    # Show path relative to $HOME
    display_path="~${notebook#"$HOME"}"
    printf "%-4s  %-12s  %s\n" "$TASK_INDEX" "$state" "$display_path"
    TASK_INDEX=$((TASK_INDEX + 1))
done < "$MANIFEST"
