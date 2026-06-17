# Bring Results Back

Generated outputs normally come back from CSD3 with `rsync`, not Git.

The goal is to retrieve the outputs you need for local inspection, summaries,
figures, or reports without copying every temporary file.

## Choose A Filter

Use a run tag or filename pattern when you only want one batch:

```bash
RUN_TAG="experiment_001"
```

Common generated folders include:

```text
outputs/
fits/
figures/
reports/
analyses/rendered/
runs/
```

The exact folders depend on your project. The important decision is which
generated files are needed locally.

## Local Machine: Open One SSH Connection For Transfers

```bash
cd "$HOME/workspace/my_project"
CLUSTER="<your-crsid-or-username>@login-cpu.hpc.cam.ac.uk"
SOCK="$HOME/.ssh/csd3-rsync-sock"

rm -f "$SOCK"
ssh -M -S "$SOCK" -fN "$CLUSTER"
```

The control socket lets repeated `rsync` commands reuse one SSH connection.

## Local Machine: Retrieve Generated Outputs

```bash
rsync -av --progress --rsh="ssh -S $SOCK" --prune-empty-dirs \
  --include='*/' \
  --include="*${RUN_TAG}*" \
  --exclude='*' \
  "${CLUSTER}:~/workspace/my_project/outputs/" outputs/
```

Retrieve figures or reports the same way:

```bash
rsync -av --progress --rsh="ssh -S $SOCK" --prune-empty-dirs \
  --include='*/' \
  --include="*${RUN_TAG}*" \
  --exclude='*' \
  "${CLUSTER}:~/workspace/my_project/figures/" figures/
```

For notebook workflows, you may also want executed notebooks:

```bash
rsync -av --progress --rsh="ssh -S $SOCK" --prune-empty-dirs \
  --include='*/' \
  --include="*${RUN_TAG}*.ipynb" \
  --include='analysis_*.ipynb' \
  --exclude='*' \
  "${CLUSTER}:~/workspace/my_project/analyses/rendered/" analyses/rendered/
```

Close the control socket:

```bash
ssh -S "$SOCK" -O exit "$CLUSTER"
```

## Local Machine: Inspect And Summarize

After generated files are local, run the local checks or summaries for your
project:

```bash
cd "$HOME/workspace/my_project"
find outputs -type f | head
bash scripts/check_outputs.sh
```

For a notebook workflow, a local comparison or report notebook might be rerun
after the cluster outputs are back:

```bash
papermill analyses/render_summary.ipynb analyses/render_summary.ipynb --progress-bar
```

If nothing copies, inspect the run tag and include patterns first. Filtered
`rsync` commands only copy files that match the include rules.
