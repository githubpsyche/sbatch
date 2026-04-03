#!/bin/bash

set -euo pipefail

VERBOSE=false
CHUNK_SIZE=1000

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
JOBIDS=()
while IFS= read -r jobid; do
    JOBIDS+=("$jobid")
done < <(grep -o '[0-9]\+' "$SUBMISSION")

if [ "${#JOBIDS[@]}" -eq 0 ]; then
    echo "Error: could not parse job IDs from $SUBMISSION"
    exit 1
fi

JOBID_LIST="$(IFS=,; echo "${JOBIDS[*]}")"
JOB_DISPLAY="$JOBID_LIST"

TOTAL=$(wc -l < "$MANIFEST")

# Get task states from sacct
declare -A TASK_STATE
declare -A JOB_OFFSET
for chunk_index in "${!JOBIDS[@]}"; do
    JOB_OFFSET["${JOBIDS[$chunk_index]}"]=$((chunk_index * CHUNK_SIZE))
done

while IFS='|' read -r taskid state; do
    [[ "$taskid" != *_* ]] && continue
    jobid="${taskid%%_*}"
    idx="${taskid##*_}"
    [[ "$idx" == *"."* ]] && continue
    offset="${JOB_OFFSET[$jobid]:-}"
    [ -n "$offset" ] || continue
    idx=$((offset + idx))
    TASK_STATE["$idx"]="$state"
done < <(sacct -j "$JOBID_LIST" --format=JobID%-30,State%-15 --noheader --parsable2 2>/dev/null)

# Count by state
declare -A STATE_COUNT
for state in "${TASK_STATE[@]}"; do
    STATE_COUNT["$state"]=$(( ${STATE_COUNT["$state"]:-0} + 1 ))
done

# Summary
echo "Run:  $RUN_DIR"
echo "Job:  $JOB_DISPLAY"
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
        chunk_index=$((TASK_INDEX / CHUNK_SIZE))
        local_index=$((TASK_INDEX % CHUNK_SIZE))
        err_path=""
        if [ "$chunk_index" -lt "${#JOBIDS[@]}" ]; then
            err_path="$RUN_DIR/logs/nb_${JOBIDS[$chunk_index]}_${local_index}.err"
        fi
        if [ -n "$err_path" ]; then
            display_err="~${err_path#"$HOME"}"
            printf "%-4s  %-12s  %s  %s\n" "$TASK_INDEX" "$state" "$display_path" "$display_err"
        else
            printf "%-4s  %-12s  %s\n" "$TASK_INDEX" "$state" "$display_path"
        fi
        TASK_INDEX=$((TASK_INDEX + 1))
    done < "$MANIFEST"
fi
