# Remote Cluster Computing For Research Workflows

This site is a practical guide to using CSD3 for research work that can be split
into scheduled jobs.

The guide is for code-savvy researchers who are comfortable with files and a
terminal, but who may not yet have a working mental model for remote clusters,
Git, or moving files to and from CSD3. The examples use generic project names so
the pattern can be adapted to different projects.

## What This Guide Helps You Do

This guide helps you:

- explain where work happens on the local Mac, CSD3 login node, and CSD3 compute nodes
- use VS Code Remote-SSH as the main interface to CSD3
- recognize workloads that fit a cluster well
- prepare self-contained work units from scripts, manifests, notebooks, or command-line tools
- move source code, prepared inputs, and generated outputs deliberately
- run one Slurm job before scaling up
- submit batches and job arrays through Slurm
- inspect queues, logs, and failure states
- recover transient failures without masking structural problems
- sync generated results back for local inspection or summaries

## Suggested Path

Read the pages in order for a complete workflow:

- Orientation. Which workloads belong on a cluster.
- Tools and access. VS Code Remote-SSH, SSH, and Login-Web fallback.
- Environment setup. `~/workspace`, software environment, and allocation checks.
- Workflow map. Prepare, transfer, submit, monitor, recover, transfer back.
- Prepare work units. Rendered notebooks, scripts, and self-contained inputs.
- Transfer files. `rsync` for files, Git for source code.
- Run one Slurm job, then submit the batch.
- Monitor and recover. `squeue`, logs, stderr, and resubmission.
- Follow-up jobs. Sentinels, dependencies, and downstream work.
- Post-process or bring results back. Decide what stays on CSD3 and what comes home.
- Focused reruns. Rerun only the stale, failed, or changed subset.

The same sequence can support a quick walkthrough or self-guided reference.

## Use This Site

For the full guide path, read the pages in sidebar order starting with
[Orientation](workshop/00-orientation.md).

These pages are not a complete CSD3 manual. They give a working path through the
concepts and link out to official documentation where
details may change.

## Notebook Helper Scripts

This repo also contains a small notebook execution layer. These scripts are
useful when a project has already prepared concrete notebook work units, such as
files under `analyses/rendered/`.

- [`run_notebook.sbatch`](https://github.com/githubpsyche/sbatch/blob/master/run_notebook.sbatch):
  Slurm job script that runs one prepared notebook with Papermill. It can run a
  single notebook path directly, or read one notebook path from a manifest when
  used in an array.
- [`submit_notebooks.sh`](https://github.com/githubpsyche/sbatch/blob/master/submit_notebooks.sh):
  builds a manifest from a notebook directory and filename pattern, creates a
  `runs/<run_id>/` directory, submits the Slurm array, and can attach a
  project-specific sentinel script.
- [`check_run.sh`](https://github.com/githubpsyche/sbatch/blob/master/check_run.sh):
  summarizes a run directory using Slurm accounting state and can show per-task
  notebook and stderr paths with `-v`.
- [`resubmit_failed.sh`](https://github.com/githubpsyche/sbatch/blob/master/resubmit_failed.sh):
  finds failed notebook tasks from a run, copies them into a rerun directory,
  and resubmits only those failed tasks.

That is the complete set of reusable root helper scripts. Follow-up sentinel
scripts are project-specific and live in the project that needs them. The guide
also shows how the same Slurm pattern adapts to scripts, manifests, and other
command-line work.

For project-side examples, see
[examples/project-scripts](https://github.com/githubpsyche/sbatch/tree/master/examples/project-scripts).
Those files show how a project can merge per-unit outputs and submit downstream
notebook batches after the root helper scripts finish.

## Core Resources

[CSD3 Quick Start](https://docs.hpc.cam.ac.uk/hpc/user-guide/quickstart.html)
is the starting point for new users.

[Connecting to CSD3](https://docs.hpc.cam.ac.uk/hpc/user-guide/connecting.html)
covers SSH access and connection troubleshooting.

[Running Jobs on CSD3](https://docs.hpc.cam.ac.uk/hpc/user-guide/batch.html)
is the official CSD3 reference for batch jobs.

[Login-Web Interface](https://docs.hpc.cam.ac.uk/hpc/user-guide/login-web.html)
is the browser-based fallback for shell access.

[VS Code Remote Explorer](https://marketplace.visualstudio.com/items?itemName=ms-vscode.remote-explorer)
is the VS Code view that shows configured SSH targets.

[uv](https://docs.astral.sh/uv/)
is the Python environment and package tool used in the setup example.

[Python `venv`](https://docs.python.org/3/library/venv.html)
explains the standard-library virtual environment concept behind isolated
project environments.

[Python argparse tutorial](https://docs.python.org/3/howto/argparse.html)
is useful when turning a local script into a command that handles one unit of
work at a time.

[Papermill](https://papermill.readthedocs.io/)
is relevant for notebook-based workflows and the notebook helper scripts in this
repo.
