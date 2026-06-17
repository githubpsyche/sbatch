# Project-Side Script Examples

These are examples of scripts that live in a research project and use the root
helpers from this repo.

They are not general-purpose `sbatch` utilities. They show the project-side
pieces that often surround a notebook batch:

- merge per-unit outputs after the first array completes
- remove stale prepared notebooks before the next stage
- submit pooled, aggregate, or analysis notebooks
- keep the same environment activation path as the submitted jobs

The root reusable helpers remain:

- `run_notebook.sbatch`
- `submit_notebooks.sh`
- `check_run.sh`
- `resubmit_failed.sh`

## Example Files

`post_fit.sh` is a sentinel script intended to run after per-unit fitting jobs
complete. It merges partial JSON outputs, removes per-unit rendered notebooks,
and submits the next stage of prepared notebooks.

`post_model_fit.sh` is a second-stage sentinel. It submits analysis notebooks
after a prior notebook batch finishes.

`merge_partials.py` is example merge logic for per-unit JSON outputs. It assumes
a simple project convention:

- partial files live in `fits/`
- partial filenames contain `_unit<N>` or `_sub<N>`
- partial JSON files share the same keys
- list-like result fields can be concatenated across units

Adapt these files inside your own project before using them on CSD3.
