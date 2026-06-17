# Run Follow-Up Jobs

Some workflows need a second stage after the first batch succeeds.

Examples:

- merge per-unit outputs
- clean up intermediate prepared units
- submit pooled or aggregate jobs
- run analysis notebooks
- build figures or reports

The key idea is ordering. The follow-up should run after the first batch reaches
the state you intended.

## Notebook Helper Sentinel

This repo calls the follow-up script a sentinel. It is submitted as a Slurm job
that depends on the notebook array finishing successfully.

```bash
cd "$HOME/workspace/sbatch"

./submit_notebooks.sh \
  --sentinel "$HOME/workspace/my_project/scripts/after_jobs.sh" \
  "$HOME/workspace/my_project/analyses/rendered" \
  "fitting_*_unit*.ipynb"
```

The sentinel script receives the project directory as its first argument.

## A Follow-Up Script

The repo includes documented project-side examples in
[examples/project-scripts](https://github.com/githubpsyche/sbatch/tree/master/examples/project-scripts).
A follow-up script for your own project should live with that project and be
adapted to its output folders and downstream stages.

```bash
cat > "$HOME/workspace/my_project/scripts/after_jobs.sh" <<'EOF'
#!/bin/bash
set -euo pipefail

PROJECT_DIR="${1:?Usage: after_jobs.sh <project_dir>}"
cd "$PROJECT_DIR"

source "$HOME/workspace/cluster_env.sh"

echo "$(date): merging per-unit outputs"
python scripts/merge_outputs.py

echo "$(date): submitting analysis notebooks"
"$HOME/workspace/sbatch/submit_notebooks.sh" \
  "$PROJECT_DIR/analyses/rendered" \
  "analysis_*.ipynb"
EOF

chmod +x "$HOME/workspace/my_project/scripts/after_jobs.sh"
```

This is only a pattern. Your follow-up script should contain the downstream work
your project actually needs.

## CSD3: Watch The Follow-Up

```bash
squeue -u "$USER" | grep post-fit
```

The helper uses the `post-fit` job name for the sentinel. If the first batch
fails, an `afterok` sentinel does not run. Inspect and repair the batch before
forcing downstream work.

## Generic Slurm Dependency

Outside the notebook helper, Slurm dependencies express the same idea:

```bash
FIRST_JOBID="$(
  sbatch --parsable \
    --job-name=batch \
    --wrap "source $HOME/workspace/cluster_env.sh && cd $HOME/workspace/my_project && bash scripts/run_batch.sh"
)"

sbatch \
  --dependency "afterok:$FIRST_JOBID" \
  --job-name=follow-up \
  --wrap "source $HOME/workspace/cluster_env.sh && cd $HOME/workspace/my_project && bash scripts/after_jobs.sh"
```

Use `afterok` when the follow-up should run only after success. Use `afterany`
when the follow-up should run after success or failure.
