# Run One Slurm Job

Before submitting a whole batch, run one scheduled job. This is sometimes called
a smoke test, but the teaching goal here is more specific: understand what one
Slurm job is made of.

The main example uses one prepared notebook and this repo's notebook runner.

## The Files In One Job

One notebook-helper job involves these files:

- one prepared notebook, such as `analyses/rendered/fitting_example_unit0.ipynb`
- `run_notebook.sbatch`, the Slurm job script
- `cluster_env.sh`, the environment activation script
- a `runs/` directory for stdout and stderr logs
- whatever output files the notebook writes

The prepared notebook is the unit of work. The `sbatch` file tells Slurm how to
run that unit on a compute node.

## What The Notebook Runner Provides

`run_notebook.sbatch` is the notebook runner for this repo. The top of the file
contains the Slurm resource settings:

```bash
#SBATCH --job-name=nb
#SBATCH -A TALMI-SL3-CPU
#SBATCH -p icelake-himem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=12:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=1
```

Those lines choose the job name, account, partition, walltime, memory, and CPU
count. For your own project, the account and resource requests need to match the
allocation and workload you are using.

The rest of the script does the repeatable setup:

- resolves the notebook path
- finds the project root by walking up to the nearest `.git` directory
- changes into the project directory
- sources `$HOME/workspace/cluster_env.sh`
- sets thread-related environment variables from the Slurm CPU request
- runs Papermill on the notebook

For a single job, the notebook path is passed as an argument. For an array job
later, the script reads the notebook path from a manifest line.

## CSD3: Submit One Prepared Notebook

Run this from a CSD3 terminal:

```bash
mkdir -p "$HOME/workspace/my_project/runs"
cd "$HOME/workspace/sbatch"

sbatch \
  --output "$HOME/workspace/my_project/runs/single_%j.out" \
  --error "$HOME/workspace/my_project/runs/single_%j.err" \
  run_notebook.sbatch \
  "$HOME/workspace/my_project/analyses/rendered/fitting_example_unit0.ipynb"
```

The `sbatch` command prints a job ID. Slurm queues the work and later runs it on
a compute node.

The `%j` in the log paths is replaced by the Slurm job ID.

## CSD3: Watch Queue State

```bash
squeue -u "$USER"
```

Jobs usually disappear from `squeue` after they finish. That does not mean the
job failed; it means you should inspect the logs and outputs.

## CSD3: Inspect The Logs

```bash
SINGLE_OUT="$(ls -t "$HOME/workspace/my_project/runs"/single_*.out | head -1)"
SINGLE_ERR="${SINGLE_OUT%.out}.err"

sed -n '1,200p' "$SINGLE_OUT"
sed -n '1,200p' "$SINGLE_ERR"
```

The `.out` file should show the script starting and finishing the notebook. The
`.err` file is where missing files, missing commands, import errors, and
tracebacks usually appear.

## CSD3: Inspect The Output Artifact

For this notebook runner, Papermill writes the executed notebook back to the
same path:

```text
~/workspace/my_project/analyses/rendered/fitting_example_unit0.ipynb
```

Your notebook may also write generated files to folders such as `outputs/`,
`fits/`, `figures/`, or `reports/`.

## Adaptation Notes

For R, MATLAB, shell, or compiled workflows, the prepared unit may be a script,
manifest row, or input file instead of a notebook. The one-job anatomy is still
the same:

- one prepared unit
- one `sbatch` script or `sbatch --wrap` command
- resource settings
- environment activation
- stdout and stderr logs
- generated output files

Once one scheduled job is understandable, the next step is scaling the same
shape to the full batch.
