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

- `4` CPUs
- `16G` memory
- `04:00:00` walltime

## Usage

Submit every notebook in a directory:

```bash
./submit_notebooks.sh /path/to/notebooks
```

Submit only notebooks matching a glob:

```bash
./submit_notebooks.sh /path/to/notebooks "fitting_*.ipynb"
```

Each submission creates a run directory under `runs/` containing:

- `manifest.txt`: the notebook list for that submission
- `submission.txt`: the `sbatch` submission output
- `logs/`: Slurm stdout/stderr logs

## Files

- `submit_notebooks.sh`: scans a notebook directory, writes a manifest, and submits one Slurm array job
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
- For first validation runs, prefer small prepared analysis notebooks such as
  `crp_*.ipynb`, `spc_*.ipynb`, or `pnr_*.ipynb`.
