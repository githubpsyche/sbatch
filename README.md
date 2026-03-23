# Slurm Notebook Runner

This repository submits already-prepared notebooks to Slurm and executes one notebook per task.
It does not prepare notebooks or manage project-specific render workflows.

## What It Expects

- A directory containing executable `.ipynb` notebooks
- Slurm available on the system
- `uv` and `jupyter` available in the execution environment

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
- `run_notebook.sbatch`: executes one notebook from the manifest with `uv run jupyter execute`
- `notes/`: older planning and reference notes kept out of the tool surface

## Scope

This repo is intentionally narrow.
Notebook preparation, `papermill` workflows, and project-specific `render_*` notebook design belong upstream in the project that produced the notebooks.

## Customization

Default Slurm resources live in `run_notebook.sbatch`.
Adjust the `#SBATCH` header there to match your cluster.

# Setup Firsts:

One-time setup

install uv
create ~/workspace
clone jaxcmr and repfr
create the shared venv