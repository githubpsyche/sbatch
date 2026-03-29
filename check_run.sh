#!/bin/bash

set -euo pipefail

VERBOSE=false

usage() {
    echo "Usage: ./check_run.sh [-v] [run_dir]"
    echo
    echo "Shows summary for a submission run. Use -v for per-task detail."
    echo "If run_dir is omitted, uses the most recent run under the current directory's project."
    echo
    echo "Examples:"
    echo "  ./check_run.sh                    # summary of newest run"
    echo "  ./check_run.sh -v                 # summary + per-task detail"
    echo "  ./check_run.sh ~/workspace/lpp_ecmr/runs/20260329-143000-12345"
}

# Parse flags
while [ "$#" -gt 0 ]; do
    case "$1" in
        -v|--verbose) VERBOSE=true; shift ;;
        -h|--help) usage; exit 0 ;;
        -*) echo "Unknown flag: $1"; usage; exit 1 ;;
        *) break ;;
    esac
done

if [ "$#" -gt 1 ]; then
    usage
    exit 1
fi

# If no argument, find newest run directory by walking up to .git
if [ "$#" -eq 0 ]; then
    PROJECT_DIR="$(pwd)"
    while [ "$PROJECT_DIR" != "/" ] && [ ! -d "$PROJECT_DIR/.git" ]; do
        PROJECT_DIR="$(dirname "$PROJECT_DIR")"
    done
    if [ ! -d "$PROJECT_DIR/runs" ]; then
        echo "Error: no runs/ directory found under $PROJECT_DIR"
        exit 1
    fi
    RUN_DIR="$PROJECT_DIR/runs/$(ls -t "$PROJECT_DIR/runs" | head -1)"
else
    RUN_DIR="$1"
fi

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

TOTAL=$(wc -l < "$MANIFEST")

# Get task states from sacct
declare -A TASK_STATE
while IFS='|' read -r taskid state; do
    idx="${taskid##*_}"
    [[ "$idx" == *"."* ]] && continue
    TASK_STATE["$idx"]="$state"
done < <(sacct -j "$JOBID" --format=JobID%-30,State%-15 --noheader --parsable2 2>/dev/null)

# Count by state
declare -A STATE_COUNT
for state in "${TASK_STATE[@]}"; do
    STATE_COUNT["$state"]=$(( ${STATE_COUNT["$state"]:-0} + 1 ))
done

# Summary
echo "Run:  $RUN_DIR"
echo "Job:  $JOBID"
echo -n "Tasks: $TOTAL total"
for state in COMPLETED RUNNING PENDING FAILED; do
    count="${STATE_COUNT[$state]:-0}"
    [ "$count" -gt 0 ] && echo -n "  $count $state"
done
unknown=$(( TOTAL - ${#TASK_STATE[@]} ))
[ "$unknown" -gt 0 ] && echo -n "  $unknown UNKNOWN"
echo
echo

# Per-task detail (only with -v)
if [ "$VERBOSE" = true ]; then
    echo
    TASK_INDEX=0
    while IFS= read -r notebook; do
        [ -n "$notebook" ] || continue
        state="${TASK_STATE[$TASK_INDEX]:-UNKNOWN}"
        display_path="~${notebook#"$HOME"}"
        printf "%-4s  %-12s  %s\n" "$TASK_INDEX" "$state" "$display_path"
        TASK_INDEX=$((TASK_INDEX + 1))
    done < "$MANIFEST"
fi
