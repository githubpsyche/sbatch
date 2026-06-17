# Focused Reruns

You rarely need to rerun everything. A focused rerun refreshes only one subset
of jobs and only the outputs that depend on them.

This usually comes after monitoring, log inspection, or local review has told
you which subset is stale, failed, or affected by a change.

It is useful after a code change, a failed subset, a new parameter setting, or a
corrected input file.

## Focus The Inputs

Create a narrow file pattern for prepared notebooks:

```bash
cd "$HOME/workspace/my_project"
find analyses/rendered -maxdepth 1 -type f -name "*target*.ipynb" | sort
```

For a manifest-based script workflow, create a narrow manifest instead:

```bash
mkdir -p jobs
find inputs -maxdepth 1 -type f -name "*target*.json" | sort > jobs/manifest_target.txt
```

## Clear Stale Target Outputs

Only remove outputs for the target subset:

```bash
cd "$HOME/workspace/my_project"
find outputs -type f -name "*target*" -delete
find figures -type f -name "*target*" -delete
```

Do not delete the prepared work units you are about to submit.

## Submit The Narrow Batch

For notebook jobs:

```bash
cd "$HOME/workspace/sbatch"
./submit_notebooks.sh \
  "$HOME/workspace/my_project/analyses/rendered" \
  "*target*.ipynb" \
  25
```

For a manifest-based script workflow:

```bash
COUNT="$(wc -l < "$HOME/workspace/my_project/jobs/manifest_target.txt")"

sbatch \
  --job-name=target \
  --array "0-$((COUNT - 1))%25" \
  --output "$HOME/workspace/my_project/runs/target_%A_%a.out" \
  --error "$HOME/workspace/my_project/runs/target_%A_%a.err" \
  "$HOME/workspace/my_project/scripts/run_from_manifest.sh" \
  "$HOME/workspace/my_project/jobs/manifest_target.txt"
```

## Bring Matching Outputs Back

```bash
cd "$HOME/workspace/my_project"
CLUSTER="<your-crsid-or-username>@login-cpu.hpc.cam.ac.uk"

rsync -av --progress --prune-empty-dirs \
  --include='*/' \
  --include='*target*' \
  --exclude='*' \
  "${CLUSTER}:~/workspace/my_project/outputs/" outputs/
```

## Restore Any Temporary Configuration

If you temporarily narrowed a config file, restore it before running aggregate
summaries:

```bash
git status --short
```

Then rerun any summaries that depend on the refreshed outputs.

## Restore The Full Workflow

A focused rerun is complete only when the temporary selection has been restored
or clearly recorded. Otherwise future summaries may accidentally use the narrow
configuration.

Focused reruns are easy to mix with stale outputs. Clear only the target
outputs, submit only the target jobs, and sync only matching results back.
