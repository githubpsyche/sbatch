# CSD3 Notebook Runner

This repository submits already-prepared notebooks to Slurm on CSD3 and executes
one notebook per task. It does not prepare notebooks or manage project-specific
render workflows.

## Current Contract

- input: a directory containing executable `.ipynb` notebooks
- scheduler: Slurm on CSD3
- account: `TALMI-SL3-CPU`
- default partition: `icelake-himem`
- execution environment: `~/workspace/cluster_env.sh`
- execution command: `jupyter execute`

The batch script currently targets CPU notebook jobs with:

- `1` CPU
- `4G` memory
- `04:00:00` walltime

### CSD3 SL3 constraints

- Maximum walltime: **12 hours**
- Maximum concurrent CPUs per user: **448** on icelake
- With 1 CPU per job and the default throttle of 100, submissions use at most
  100 CPUs concurrently.

## Usage

Submit every notebook in a directory:

```bash
./submit_notebooks.sh /path/to/notebooks
```

Submit only notebooks matching a glob:

```bash
./submit_notebooks.sh /path/to/notebooks "fitting_*.ipynb"
```

Override the concurrent task throttle (default 100):

```bash
./submit_notebooks.sh /path/to/notebooks "fitting_*.ipynb" 200
```

### Large submissions

Manifests larger than 1000 notebooks are automatically split into multiple
array jobs (one per chunk). Each chunk gets its own manifest file in the run
directory. All chunks share the same log directory. This avoids hitting
Slurm's `MaxArraySize` limit (default 1001).

### Run directory

Each submission creates a run directory under `runs/` containing:

- `manifest.txt`: the full notebook list for that submission
- `manifest_N.txt`: per-chunk manifests (only for large submissions)
- `submission.txt`: the `sbatch` submission output(s)
- `logs/`: Slurm stdout/stderr logs

## Files

- `submit_notebooks.sh`: scans a notebook directory, writes a manifest, and submits one or more Slurm array jobs
- `run_notebook.sbatch`: executes one notebook from the manifest or a direct path on CSD3
- `notes/guide.md`: first-time cluster setup and smoke-test notes
- `notes/`: older planning and reference notes kept out of the tool surface

## Scope

This repo is intentionally narrow. Notebook preparation, `papermill`
workflows, and project-specific `render_*` notebook design belong upstream in
the project that produced the notebooks.

## Notes

- The batch script assumes `~/workspace/cluster_env.sh` exists and activates the
  shared notebook environment.
- `TALMI-SL3-CPU` is an SL3 account, so CPU jobs are subject to the SL3
  walltime rules. On CSD3, that means a practical 12-hour ceiling for a single
  job.
