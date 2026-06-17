# Monitor And Recover

After submission, your job is to decide whether the run is progressing, done,
or failing in a way that needs intervention.

Use Slurm for queue state and logs for actual error details.

## CSD3: Queue State

```bash
squeue -u "$USER"
```

`squeue` shows jobs that are pending or running. Finished jobs usually
disappear from `squeue`.

For accounting state after jobs finish:

```bash
sacct -j <job_id> --format=JobID,JobName,State,Elapsed,ExitCode
```

## CSD3: Inspect Logs

```bash
cd "$HOME/workspace/my_project"
ls -lt runs | head
```

Inspect the start of a log:

```bash
sed -n '1,200p' runs/<log_file>.err
```

For array jobs, task logs often include the array job ID and task index:

```text
batch_<array_job_id>_<task_id>.err
```

## Notebook Helper Run Summary

If you submitted notebooks with this repo:

```bash
cd "$HOME/workspace/my_project"
"$HOME/workspace/sbatch/check_run.sh"
"$HOME/workspace/sbatch/check_run.sh" -v
```

For a specific run:

```bash
"$HOME/workspace/sbatch/check_run.sh" "$HOME/workspace/my_project/runs/<run_id>"
```

## Notebook Progress

For notebook jobs, the notebook itself is also a progress artifact. While a job
is running, you can open the prepared notebook on CSD3 and inspect which cells
have executed, what output has appeared, and whether a traceback has already
been written.

In VS Code Remote-SSH, open the notebook path shown by `check_run.sh -v`. Refresh
or reopen the notebook if the view does not update while the job is running.

You can also inspect the notebook file from the terminal:

```bash
NOTEBOOK="$HOME/workspace/my_project/analyses/rendered/fitting_example_unit0.ipynb"

python - "$NOTEBOOK" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
nb = json.loads(path.read_text())
code_cells = [cell for cell in nb["cells"] if cell.get("cell_type") == "code"]
executed = [cell for cell in code_cells if cell.get("execution_count") is not None]
errors = []
for index, cell in enumerate(code_cells, 1):
    for output in cell.get("outputs", []):
        if output.get("output_type") == "error":
            errors.append((index, output.get("ename", "error")))

print(f"{len(executed)}/{len(code_cells)} code cells executed")
for index, error in errors:
    print(f"cell {index}: {error}")
PY
```

Long-running jobs should also write progress output. In Python, `tqdm` is a good
default for loops. For other tools, use the equivalent progress meter or regular
stdout messages. Progress output makes the `.out` log and the executed notebook
more useful while the job is still running.

## Transient Vs Structural Failures

An isolated task failure can be transient. If one or two tasks fail and the
error does not point to source, data, or environment problems, resubmission may
be reasonable.

If many tasks fail the same way, treat it as structural. Fix the code, inputs,
paths, or environment before resubmitting.

## Notebook Helper Resubmission

For failed notebook tasks from the newest run:

```bash
cd "$HOME/workspace/my_project"
"$HOME/workspace/sbatch/resubmit_failed.sh"
```

With a follow-up script:

```bash
cd "$HOME/workspace/my_project"
"$HOME/workspace/sbatch/resubmit_failed.sh" \
  --sentinel "$HOME/workspace/my_project/scripts/after_jobs.sh"
```

## Before Resubmitting

Before resubmitting, you should be able to explain why resubmission is
appropriate. If the explanation is "the code was wrong," fix and retest first.

Do not repeatedly resubmit the same structural failure. The scheduler will keep
reproducing the same error because the job input and environment have not
changed.
