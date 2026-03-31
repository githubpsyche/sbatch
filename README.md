# CSD3 Notebook Runner

Submits prepared Jupyter notebooks to Slurm on CSD3, one notebook per task. Project-specific notebook preparation and render workflows belong upstream in the project that produced the notebooks.

## First-Time Setup

1. SSH to the cluster and complete the 2-factor step.

```bash
ssh <your_username>@<cluster_host>
```

2. Create a workspace directory in your home folder.

```bash
mkdir -p "$HOME/workspace"
cd "$HOME/workspace"
```

3. Install `uv`.

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

4. Add `uv` to your shell for the current session.

```bash
source "$HOME/.local/bin/env"
```

5. Add that line to `.bashrc` so future sessions see it.

```bash
echo 'source "$HOME/.local/bin/env"' >> "$HOME/.bashrc"
source "$HOME/.bashrc"
```

6. Clone the repos you need into `~/workspace`.

```bash
cd "$HOME/workspace"
git clone <jaxcmr_repo_url>
git clone <repfr_repo_url>
git clone <sbatch_repo_url>
```

7. Discover your CSD3 Slurm account.

```bash
mybalance
```

For the current setup, the relevant CPU account is:

```text
TALMI-SL3-CPU
```

The tracked `sbatch` scripts now assume that account and use the
`icelake-himem` partition by default.

8. Create one shared virtual environment outside the repos.

```bash
uv venv "$HOME/workspace/.venv" --python 3.12
source "$HOME/workspace/.venv/bin/activate"
```

9. Install packages into the shared environment.

```bash
cd "$HOME/workspace"
uv pip install -e "jaxcmr[dev]"
uv pip install jupyter nbclient pandas papermill
```

Run from `~/workspace/` (not from inside a project directory) to avoid
uv's project-mode detection creating unwanted project-local venvs.

Install any project packages that need to be importable (e.g. `lpp_ecmr`):

```bash
uv pip install -e lpp_ecmr
```

Notes:

- The shared environment lives outside the repos so it can serve multiple
  projects.
- `TALMI-SL3-CPU` is an SL3 account. On CSD3, SL3 CPU jobs cannot run longer
  than 12 hours, so treat very long fitting notebooks as follow-up work.

## Reusable Environment Script

Save one small activation script that can be sourced manually now and later from
Slurm jobs.

```bash
cat > "$HOME/workspace/cluster_env.sh" <<'EOF'
source "$HOME/.local/bin/env"
source "$HOME/workspace/.venv/bin/activate"
EOF

chmod +x "$HOME/workspace/cluster_env.sh"
```

## First Verification

Before using Slurm, verify the environment by hand.

1. Confirm `jaxcmr` imports from the shared environment.

```bash
source "$HOME/workspace/cluster_env.sh"
cd "$HOME/workspace/repfr"
python -c "import jaxcmr; print(jaxcmr.__file__)"
```

2. Run one rendered notebook manually.

```bash
source "$HOME/workspace/cluster_env.sh"
cd "$HOME/workspace/repfr/analyses/rendered"
papermill fitting_RepeatedRecallsGordonRanschburg2021_WeirdCMRNoStop_rerun_best_of_3_sub0.ipynb \
  fitting_RepeatedRecallsGordonRanschburg2021_WeirdCMRNoStop_rerun_best_of_3_sub0.ipynb \
  --progress-bar
```

For this first check, pick one per-subject fitting notebook. These are
self-contained: they load data, fit one subject, simulate, and optionally
generate figures. A single-subject fit with `best_of=3` typically takes
under a minute.

If that works, the main execution prerequisites are in place:

- the shared environment activates correctly
- `jaxcmr` imports
- a prepared notebook can execute on the cluster outside Slurm

## Next Step

Once the manual notebook run works, make the Slurm runner use the same
environment.

The tracked `sbatch/run_notebook.sbatch` file now does this directly. It
sources `cluster_env.sh`, sets `UV_NO_PROJECT=1` to prevent uv from
creating project-local venvs, and runs the notebook via papermill (which
writes cell outputs back to the file as each cell completes).

## First Slurm Smoke Test

Before trying a batch, submit one notebook as one Slurm job.

```bash
mkdir -p "$HOME/workspace/repfr/runs"
cd "$HOME/workspace/sbatch"

sbatch \
  --output "$HOME/workspace/repfr/runs/smoke_%j.out" \
  --error "$HOME/workspace/repfr/runs/smoke_%j.err" \
  run_notebook.sbatch \
  "$HOME/workspace/repfr/analyses/rendered/fitting_RepeatedRecallsGordonRanschburg2021_WeirdCMRNoStop_rerun_best_of_3_sub0.ipynb"
```

Then:

1. Note the job ID printed by `sbatch`.
2. Check that the job appears in the queue:

```bash
squeue -u "$USER"
```

3. After it finishes, inspect the logs:

```bash
ls "$HOME/workspace/repfr/runs"
cat "$HOME/workspace/repfr/runs/smoke_<jobid>.out"
cat "$HOME/workspace/repfr/runs/smoke_<jobid>.err"
```

If this works, you have shown that:

- Slurm can launch the job
- the job can activate the shared environment
- the job can execute one prepared notebook on a compute node
- the hardcoded CSD3 account and partition are valid for this workflow

## First Batch Submission

Once the single-job smoke test works, submit a tiny batch through the wrapper.

For a first batch, keep it very small. Start with one notebook or a narrow glob.

```bash
cd "$HOME/workspace/sbatch"
./submit_notebooks.sh \
  "$HOME/workspace/repfr/analyses/rendered" \
  "crp_*.ipynb"
```

Or, if you want a slightly larger first test:

```bash
cd "$HOME/workspace/sbatch"
./submit_notebooks.sh \
  "$HOME/workspace/repfr/analyses/rendered" \
  "spc_*.ipynb"
```

The runner targets per-subject fitting jobs on `icelake-himem`
(`1` CPU, `4G`, `12:00:00`). Submissions larger than 1000 notebooks are
automatically split into multiple array jobs.

After submission:

Check progress with:

```bash
cd ~/workspace/repfr && ~/workspace/sbatch/check_run.sh       # newest run in current project
~/workspace/sbatch/check_run.sh ~/workspace/repfr/runs/<run_id>  # specific run
```

This shows the Slurm job ID and task counts by state. Use `-v` for per-task detail with notebook paths. Inspect `runs/<run_id>/logs/` for per-task stdout/stderr.

At that point, the repo is working end-to-end:

- notebooks already exist
- the runner can submit them to Slurm
- one notebook runs per task
- logs are written under the project's `runs/` directory

## Email Notifications

To get emailed when jobs finish or fail, set `SBATCH_MAIL_USER` in your `~/.bashrc`:

```bash
export SBATCH_MAIL_USER="your_email@example.com"
```

`submit_notebooks.sh` picks this up automatically. If unset, no emails are sent.

You get one email when the entire batch finishes, plus immediate emails for any individual task failures.

## Custom Sentinel Jobs

By default, a lightweight sentinel job sends the completion email after the array finishes. To run a custom script instead (e.g. a post-processing pipeline), use `--sentinel`:

```bash
./submit_notebooks.sh --sentinel /path/to/post_process.sh /path/to/notebooks "fitting_*.ipynb"
```

The sentinel script receives the project directory as its first argument and runs only if all array tasks succeed (`afterok`). If omitted, the default email-only sentinel runs on `afterany`.

## Resubmitting Failed Tasks

If some tasks fail (e.g. transient kernel deaths), resubmit just the failures:

```bash
./resubmit_failed.sh ~/workspace/project/runs/<run_id>
```

This reads the run's manifest and sacct state, copies failed notebooks to `<run_dir>/resubmit/`, and submits them. Supports `--sentinel` for chaining post-processing:

```bash
./resubmit_failed.sh --sentinel /path/to/post_process.sh ~/workspace/project/runs/<run_id>
```
