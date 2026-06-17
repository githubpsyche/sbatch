# Resources

This page keeps the reference list small. The guide explains the needed Slurm
ideas through local examples and CSD3 commands, so the links below are for
checking official details later.

## CSD3 Ground Truth

[CSD3 Quick Start](https://docs.hpc.cam.ac.uk/hpc/user-guide/quickstart.html)
is the starting point for new users. Use it to confirm account basics and the
official CSD3 orientation.

[Connecting to CSD3](https://docs.hpc.cam.ac.uk/hpc/user-guide/connecting.html)
covers SSH access. Use it when local SSH or Remote-SSH cannot connect.

[Running Jobs on CSD3](https://docs.hpc.cam.ac.uk/hpc/user-guide/batch.html)
is the official reference for CSD3 batch jobs. Use it to check scheduler terms,
partitions, and job submission behavior.

[Login-Web Interface](https://docs.hpc.cam.ac.uk/hpc/user-guide/login-web.html)
is the fallback path when you need browser-based shell access.

## VS Code Remote Work

[Remote Explorer](https://marketplace.visualstudio.com/items?itemName=ms-vscode.remote-explorer)
is the VS Code view that shows configured SSH targets.

## Python Workflow References

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

[tqdm](https://tqdm.github.io/)
is useful for progress output in long Python loops. Progress output makes Slurm
logs and executed notebooks easier to monitor while jobs are still running.

## Local Project References

Use the pages in this site as the first reference for the workflow:

- [Orientation](00-orientation.qmd)
- [Workflow Map](03-workflow-map.md)
- [Submit The Batch](07-submit-the-batch.qmd)
- [Monitor And Recover](08-monitor-and-recover.md)
- [Post-Process Or Bring Results Back](10-post-process-or-bring-results-back.qmd)
- [Project-Side Script Examples](https://github.com/githubpsyche/sbatch/tree/master/examples/project-scripts)

Use the root scripts when you need exact behavior for the notebook helper:

- `run_notebook.sbatch`
- `submit_notebooks.sh`
- `check_run.sh`
- `resubmit_failed.sh`

## How To Use This Page

Use these links to answer specific questions after using the guide: connection
problems, CSD3 account details, batch-job behavior, VS Code remote access,
Python environments, command-line arguments, or notebook execution.

Do not turn the resource page into a broad Slurm bibliography. Keep the resource
list focused on the CSD3, VS Code, and Python docs readers are most likely to
need.
