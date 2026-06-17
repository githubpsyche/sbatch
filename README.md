# CSD3 Notebook Runner and Workflow Guide

This repo has two parts:

1. Provide small shell scripts for running prepared Jupyter notebooks on CSD3 with Slurm.
2. Provide a project-agnostic guide for using CSD3 for research workflows.

The scripts are intentionally plain Bash. Project-specific notebook preparation,
simulation, analysis, and scientific logic belong in the project that produced
the notebooks.

## Guide Path

Start with the site landing page, [index.md](index.md), then read the guide
pages in sidebar order.

The guide is built around a transferable cluster workflow:

```text
prepare work units -> transfer files to CSD3 -> run one Slurm job -> submit the batch -> monitor -> recover failures -> run follow-up jobs -> bring results back
```

The pages are workflow sections. Each page explains what the step is, why it
exists, where the command runs, and what files or logs to inspect.

Begin with [workshop/00-orientation.md](workshop/00-orientation.md).

## Website

The guide can be rendered as a small Quarto website:

```bash
quarto render
```

The rendered site is written to `docs/`.

## Runner Scripts

The root scripts are the reusable execution layer.

- `run_notebook.sbatch`: execute one notebook, either directly or from a manifest line in a Slurm array.
- `submit_notebooks.sh`: build a manifest from a notebook directory and submit one or more Slurm arrays.
- `check_run.sh`: summarize the newest or specified run directory using Slurm accounting state.
- `resubmit_failed.sh`: copy failed notebooks from a previous run and resubmit only those notebooks.

Current CSD3 defaults live in `run_notebook.sbatch`:

```text
account:   TALMI-SL3-CPU
partition: icelake-himem
time:      12:00:00
memory:    16G
cpus:      1
```

Those defaults match the current tested CSD3 workflow. Change them deliberately
for a different account or resource profile.

## Minimal Use

On CSD3, after the project and environment are in place:

```bash
cd "$HOME/workspace/sbatch"
./submit_notebooks.sh \
  "$HOME/workspace/my_project/analyses/rendered" \
  "*.ipynb"
```

From the project directory, monitor the newest run:

```bash
cd "$HOME/workspace/my_project"
"$HOME/workspace/sbatch/check_run.sh"
"$HOME/workspace/sbatch/check_run.sh" -v | grep FAILED
```

Resubmit failed tasks from the newest run:

```bash
cd "$HOME/workspace/my_project"
"$HOME/workspace/sbatch/resubmit_failed.sh"
```

For a post-processing chain, pass a sentinel script:

```bash
cd "$HOME/workspace/sbatch"
./submit_notebooks.sh \
  --sentinel "$HOME/workspace/my_project/scripts/after_jobs.sh" \
  "$HOME/workspace/my_project/analyses/rendered" \
  "*.ipynb"
```

The sentinel receives the project directory as its first argument and runs only
after all array tasks succeed.

These scripts are notebook-oriented helpers. If your work uses shell scripts,
Python scripts, R scripts, compiled programs, or another command-line tool, the
same Slurm workflow still applies even if you do not use the notebook helper.

For the full repeated workflow, including file transfer, follow-up jobs, result
retrieval, and focused reruns, see
[workshop/03-workflow-map.md](workshop/03-workflow-map.md).

## Project-Side Examples

The [examples/project-scripts](examples/project-scripts) directory contains
reference scripts that would normally live inside a research project:

- `post_fit.sh`: sentinel script that merges per-unit outputs, removes stale
  rendered notebooks, and submits the next notebook batch.
- `post_model_fit.sh`: second-stage sentinel script that submits analysis
  notebooks.
- `merge_partials.py`: example merge logic for per-unit JSON outputs.

These examples are intentionally generic. Adapt them inside your own project
before using them on CSD3.

## Implementation Style

Future edits should stay close to the current style:

- direct Bash and Markdown
- explicit commands rather than hidden configuration
- simple guards and clear error messages
- concrete CSD3 examples
- no new imports, frameworks, generators, config layers, or abstraction layers

When in doubt, keep the scripts boring and put explanation in the guide
notes.
