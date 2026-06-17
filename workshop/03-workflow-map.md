# Workflow Map

This page is the bridge from the setup concepts to the hands-on workflow. The
rest of the guide follows the same lifecycle in order.

The goal is to get from local research code to a full batch of scheduled jobs
that run on CSD3 compute nodes, leave inspectable logs, and produce outputs you
can bring back for local review.

## What Makes Work Batchable

Good cluster work usually has many units that can run independently:

- one simulation seed
- one input file
- one subject or dataset
- one parameter setting
- one report or figure

The unit should be small enough to run as one scheduled job and clear enough
that you can rerun just that unit if it fails.

## The Run Lifecycle

### 1. Define The Repeating Unit

Where: local machine.

Artifact: a repeating unit type, plus a list of all units to run, such as all
subjects, all input files, all simulation seeds, or all parameter settings.

Example:

```text
Overall goal: fit all subjects.
Repeating unit: fit one subject.
Batch run: submit one task per subject.
```

Next: [Prepare Work Units](04-prepare-work-units.md).

### 2. Prepare The Work Units

Where: usually local machine.

Artifact: a script, command, notebook, manifest, glob, or parameter set that
makes every unit in the batch explicit and runnable without interaction.

Next: [Prepare Work Units](04-prepare-work-units.md).

### 3. Transfer Files To CSD3

Where: local machine and CSD3 login node.

Artifact: current source code, prepared inputs, and project folders available
under `~/workspace/` on CSD3.

Next: [Transfer Files](05-transfer-files.md).

### 4. Run One Slurm Job

Where: CSD3 login node for submission; CSD3 compute node for execution.

Artifact: one submitted job ID, one prepared work unit, one pair of stdout/stderr
logs, and one output artifact to inspect.

Next: [Run One Slurm Job](06-run-one-slurm-job.md).

### 5. Submit The Batch

Where: CSD3 login node for submission; CSD3 compute nodes for execution.

Artifact: Slurm job IDs, run directory, manifests or submitted scripts, and logs
for each unit.

Next: [Submit The Batch](07-submit-the-batch.md).

### 6. Monitor And Recover

Where: CSD3 login node.

Artifact: queue state, accounting state, logs, executed notebooks if relevant,
and a decision about whether a failure is transient or structural.

Next: [Monitor And Recover](08-monitor-and-recover.md).

### 7. Run Follow-Up Jobs If Needed

Where: CSD3, after the first jobs finish.

Artifact: merged outputs, pooled summaries, downstream reports, or any other
generated files that depend on earlier jobs.

Next: [Run Follow-Up Jobs](09-follow-up-jobs.md).

### 8. Post-Process Or Bring Results Back

Where: CSD3 for compute-heavy post-processing; local machine for transfer and
local inspection.

Artifact: reduced outputs produced on CSD3, or generated outputs copied back
without committing large or derived files to Git by accident.

Next: [Post-Process Or Bring Results Back](10-post-process-or-bring-results-back.md).

### 9. Rerun Narrowly When Needed

Where: local machine and CSD3.

Artifact: a focused rerun that targets only stale, failed, or changed units.

Next: [Focused Reruns](11-focused-reruns.md).

## Project Shape

The examples use this generic layout:

```text
my_project/
  analyses/
    rendered/
  inputs/
  outputs/
  scripts/
  runs/
```

The exact folder names can change. The useful habit is to know where source
notebooks or scripts, prepared work units, generated outputs, reusable scripts,
and logs live before scaling up.
