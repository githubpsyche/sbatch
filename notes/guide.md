# First-Time Cluster Setup

This note is for someone accessing the cluster for the first time and preparing to run
already-rendered notebooks with the `sbatch` runner.

The goal is to end with:

- a persistent workspace on the cluster
- a shared Python environment outside any single repo
- `jaxcmr` importable from that environment
- one rendered notebook runnable by hand before using Slurm

## One-Time Setup

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

5. Add that line to your shell startup file so future logins also see `uv`.

For `bash`:

```bash
echo 'source "$HOME/.local/bin/env"' >> "$HOME/.bashrc"
source "$HOME/.bashrc"
```

For `zsh`:

```bash
echo 'source "$HOME/.local/bin/env"' >> "$HOME/.zshrc"
source "$HOME/.zshrc"
```

6. Clone the repos you need into `~/workspace`.

```bash
cd "$HOME/workspace"
git clone <jaxcmr_repo_url>
git clone <repfr_repo_url>
git clone <sbatch_repo_url>
```

7. Create one shared virtual environment outside the repos.

```bash
mkdir -p "$HOME/workspace/.venvs"
uv venv "$HOME/workspace/.venvs/jaxcmr-cluster" --python 3.12
source "$HOME/workspace/.venvs/jaxcmr-cluster/bin/activate"
```

8. Install `jaxcmr` and the notebook/runtime dependencies into that shared
environment.

```bash
cd "$HOME/workspace/jaxcmr"
uv pip install -e '.[dev]'
uv pip install jupyter nbclient pandas
```

Notes:

- `jaxcmr` is the installable package here.
- `repfr` does not currently need to be installed as a package for this setup.
- The shared environment lives outside the repos so it can later serve multiple
  projects.

## Reusable Environment Script

Save one small activation script that can be sourced manually now and later from
Slurm jobs.

```bash
cat > "$HOME/workspace/cluster_env.sh" <<'EOF'
source "$HOME/.local/bin/env"
source "$HOME/workspace/.venvs/jaxcmr-cluster/bin/activate"
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
cd "$HOME/workspace/repfr/code/rendered"
jupyter execute crp_LohnasKahana2014_list_type_1234.ipynb
```

For this first check, choose a small prepared analysis notebook, not a fitting
notebook. Good first candidates usually have prefixes like:

- `crp_`
- `spc_`
- `pnr_`

Avoid `fitting_*.ipynb` for the first manual run. Those notebooks can take much
longer and may depend on pre-existing fit or simulation artifacts.

If that works, the main execution prerequisites are in place:

- the shared environment activates correctly
- `jaxcmr` imports
- a prepared notebook can execute on the cluster outside Slurm

## Next Step

Once the manual notebook run works, make the Slurm runner use the same
environment.

In `sbatch/run_notebook.sbatch`, source `~/workspace/cluster_env.sh` before the
final notebook execution command.

For a first pass, the execute section should look like this:

```bash
source "$HOME/workspace/cluster_env.sh"

echo "$(date): Starting $NOTEBOOK"
jupyter execute "$NOTEBOOK_NAME"
STATUS=$?
echo "$(date): Finished $NOTEBOOK (exit code $STATUS)"
exit $STATUS
```

That turns the manual environment setup into the Slurm job setup.

## First Slurm Smoke Test

Before trying a batch, submit one notebook as one Slurm job.

```bash
mkdir -p "$HOME/workspace/sbatch/runs"
cd "$HOME/workspace/sbatch"

sbatch \
  --output "$HOME/workspace/sbatch/runs/smoke_%j.out" \
  --error "$HOME/workspace/sbatch/runs/smoke_%j.err" \
  run_notebook.sbatch \
  "$HOME/workspace/repfr/code/rendered/crp_LohnasKahana2014_list_type_1234.ipynb"
```

Then:

1. Note the job ID printed by `sbatch`.
2. Check that the job appears in the queue:

```bash
squeue -u "$USER"
```

3. After it finishes, inspect the logs:

```bash
ls "$HOME/workspace/sbatch/runs"
cat "$HOME/workspace/sbatch/runs/smoke_<jobid>.out"
cat "$HOME/workspace/sbatch/runs/smoke_<jobid>.err"
```

If this works, you have shown that:

- Slurm can launch the job
- the job can activate the shared environment
- the job can execute one prepared notebook on a compute node

## First Batch Submission

Once the single-job smoke test works, submit a tiny batch through the wrapper.

For a first batch, keep it very small. Start with one notebook or a narrow glob.

```bash
cd "$HOME/workspace/sbatch"
./submit_notebooks.sh \
  "$HOME/workspace/repfr/code/rendered" \
  "crp_*.ipynb"
```

Or, if you want a slightly larger first test:

```bash
cd "$HOME/workspace/sbatch"
./submit_notebooks.sh \
  "$HOME/workspace/repfr/code/rendered" \
  "spc_*.ipynb"
```

Still avoid `fitting_*.ipynb` at this stage. The goal of the first batch is to
prove that the runner and environment work, not to launch long model-fitting
jobs.

After submission:

1. Find the newest run directory under `sbatch/runs/`.
2. Open `manifest.txt` to confirm the intended notebooks were selected.
3. Open `submission.txt` to get the Slurm job ID.
4. Inspect `logs/` after the tasks run.

At that point, the repo is working end-to-end:

- notebooks already exist
- the runner can submit them to Slurm
- one notebook runs per task
- logs are written under `sbatch/runs/`
