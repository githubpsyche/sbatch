#!/bin/bash

set -euo pipefail

usage() {
    echo "Usage: ./submit_notebooks.sh <notebook_dir> [glob]"
    echo
    echo "Examples:"
    echo "  ./submit_notebooks.sh /path/to/notebooks"
    echo "  ./submit_notebooks.sh /path/to/notebooks \"fitting_*.ipynb\""
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    usage
    exit 1
fi

NOTEBOOK_DIR_INPUT="$1"
PATTERN="${2:-*.ipynb}"

if [ ! -d "$NOTEBOOK_DIR_INPUT" ]; then
    echo "Error: notebook directory not found: $NOTEBOOK_DIR_INPUT"
    exit 1
fi

NOTEBOOK_DIR="$(cd "$NOTEBOOK_DIR_INPUT" && pwd)"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_ID="$(date +%Y%m%d-%H%M%S)-$$"
RUN_DIR="$REPO_ROOT/runs/$RUN_ID"
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

echo "Submitting $COUNT notebooks from $NOTEBOOK_DIR"
echo "Run directory: $RUN_DIR"
head -5 "$MANIFEST"
[ "$COUNT" -gt 5 ] && echo "  ... and $((COUNT - 5)) more"

SBATCH_OUTPUT="$(
    sbatch \
        --array=0-$((COUNT - 1)) \
        --output "$LOG_DIR/%x_%A_%a.out" \
        --error "$LOG_DIR/%x_%A_%a.err" \
        --export=ALL,MANIFEST="$MANIFEST" \
        "$REPO_ROOT/run_notebook.sbatch"
)"

printf '%s\n' "$SBATCH_OUTPUT" > "$RUN_DIR/submission.txt"
printf '%s\n' "$SBATCH_OUTPUT"
