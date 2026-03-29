#!/bin/bash

set -euo pipefail

CHUNK_SIZE=1000
DEFAULT_THROTTLE=100

usage() {
    echo "Usage: ./submit_notebooks.sh <notebook_dir> [glob] [throttle]"
    echo
    echo "Examples:"
    echo "  ./submit_notebooks.sh /path/to/notebooks"
    echo "  ./submit_notebooks.sh /path/to/notebooks \"fitting_*.ipynb\""
    echo "  ./submit_notebooks.sh /path/to/notebooks \"fitting_*.ipynb\" 200"
    echo
    echo "Throttle limits concurrent array tasks (default: $DEFAULT_THROTTLE)."
    echo "Manifests larger than $CHUNK_SIZE are split into multiple array jobs."
}

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
    usage
    exit 1
fi

NOTEBOOK_DIR_INPUT="$1"
PATTERN="${2:-*.ipynb}"
THROTTLE="${3:-$DEFAULT_THROTTLE}"

if [ ! -d "$NOTEBOOK_DIR_INPUT" ]; then
    echo "Error: notebook directory not found: $NOTEBOOK_DIR_INPUT"
    exit 1
fi

NOTEBOOK_DIR="$(cd "$NOTEBOOK_DIR_INPUT" && pwd)"
SBATCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find project root (nearest .git ancestor of the notebook directory)
PROJECT_DIR="$NOTEBOOK_DIR"
while [ "$PROJECT_DIR" != "/" ] && [ ! -d "$PROJECT_DIR/.git" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
if [ ! -d "$PROJECT_DIR/.git" ]; then
    echo "Error: could not find project root for $NOTEBOOK_DIR"
    exit 1
fi

RUN_ID="$(date +%Y%m%d-%H%M%S)-$$"
RUN_DIR="$PROJECT_DIR/runs/$RUN_ID"
LOG_DIR="$RUN_DIR/logs"
MANIFEST="$RUN_DIR/manifest.txt"

mkdir -p "$LOG_DIR"

COUNT=0
: > "$MANIFEST"
while IFS= read -r nb; do
    [ -n "$nb" ] || continue
    printf '%s\n' "$nb" >> "$MANIFEST"
    COUNT=$((COUNT + 1))
done < <(find "$NOTEBOOK_DIR" -maxdepth 1 -type f -name "$PATTERN" | sort)

if [ "$COUNT" -eq 0 ]; then
    echo "No notebooks matched pattern '$PATTERN' in $NOTEBOOK_DIR"
    exit 1
fi

# Optional email notifications (set SBATCH_MAIL_USER in your shell config).
# Array tasks get FAIL-only emails. A sentinel job fires one END email
# after the entire array completes.
FAIL_MAIL_FLAGS=()
END_MAIL_FLAGS=()
if [ -n "${SBATCH_MAIL_USER:-}" ]; then
    FAIL_MAIL_FLAGS=(--mail-type=FAIL --mail-user="$SBATCH_MAIL_USER")
    END_MAIL_FLAGS=(--mail-type=END --mail-user="$SBATCH_MAIL_USER")
fi

echo "Submitting $COUNT notebooks from $NOTEBOOK_DIR"
echo "Run directory: $RUN_DIR"
head -5 "$MANIFEST"
[ "$COUNT" -gt 5 ] && echo "  ... and $((COUNT - 5)) more"

# Split into chunks if the manifest exceeds CHUNK_SIZE
if [ "$COUNT" -le "$CHUNK_SIZE" ]; then
    SBATCH_OUTPUT="$(
        sbatch \
            --array=0-$((COUNT - 1))%"$THROTTLE" \
            --output "$LOG_DIR/%x_%A_%a.out" \
            --error "$LOG_DIR/%x_%A_%a.err" \
            --export=ALL,MANIFEST="$MANIFEST" \
            "${FAIL_MAIL_FLAGS[@]}" \
            "$SBATCH_DIR/run_notebook.sbatch"
    )"
    printf '%s\n' "$SBATCH_OUTPUT" > "$RUN_DIR/submission.txt"
    printf '%s\n' "$SBATCH_OUTPUT"

    # Submit sentinel job that emails when the array finishes
    if [ "${#END_MAIL_FLAGS[@]}" -gt 0 ]; then
        ARRAY_JOBID=$(echo "$SBATCH_OUTPUT" | grep -o '[0-9]\+')
        sbatch --dependency=afterany:"$ARRAY_JOBID" \
            --job-name=done \
            --output "$LOG_DIR/sentinel_%j.out" \
            "${END_MAIL_FLAGS[@]}" \
            --wrap="echo 'All $COUNT notebooks finished (array $ARRAY_JOBID).'"
    fi
else
    CHUNK_INDEX=0
    OFFSET=0
    ALL_JOBIDS=""
    while [ "$OFFSET" -lt "$COUNT" ]; do
        REMAINING=$((COUNT - OFFSET))
        THIS_CHUNK=$CHUNK_SIZE
        [ "$REMAINING" -lt "$THIS_CHUNK" ] && THIS_CHUNK=$REMAINING

        CHUNK_MANIFEST="$RUN_DIR/manifest_${CHUNK_INDEX}.txt"
        sed -n "$((OFFSET + 1)),$((OFFSET + THIS_CHUNK))p" "$MANIFEST" > "$CHUNK_MANIFEST"

        echo "Chunk $CHUNK_INDEX: $THIS_CHUNK notebooks (offset $OFFSET)"

        SBATCH_OUTPUT="$(
            sbatch \
                --array=0-$((THIS_CHUNK - 1))%"$THROTTLE" \
                --output "$LOG_DIR/%x_%A_%a.out" \
                --error "$LOG_DIR/%x_%A_%a.err" \
                --export=ALL,MANIFEST="$CHUNK_MANIFEST" \
                "${FAIL_MAIL_FLAGS[@]}" \
                "$SBATCH_DIR/run_notebook.sbatch"
        )"
        printf '%s\n' "$SBATCH_OUTPUT" >> "$RUN_DIR/submission.txt"
        printf '%s\n' "$SBATCH_OUTPUT"

        JOBID=$(echo "$SBATCH_OUTPUT" | grep -o '[0-9]\+')
        ALL_JOBIDS="${ALL_JOBIDS:+$ALL_JOBIDS:}afterany:$JOBID"

        OFFSET=$((OFFSET + THIS_CHUNK))
        CHUNK_INDEX=$((CHUNK_INDEX + 1))
    done
    echo "Submitted $CHUNK_INDEX chunks"

    # Submit sentinel job that emails when all chunks finish
    if [ "${#END_MAIL_FLAGS[@]}" -gt 0 ] && [ -n "$ALL_JOBIDS" ]; then
        sbatch --dependency="$ALL_JOBIDS" \
            --job-name=done \
            --output "$LOG_DIR/sentinel_%j.out" \
            "${END_MAIL_FLAGS[@]}" \
            --wrap="echo 'All $COUNT notebooks finished ($CHUNK_INDEX chunks).'"
    fi
fi
