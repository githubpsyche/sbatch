# Orientation

This guide is about using CSD3 for research work that is too large, too slow, or
too repetitive for a local machine.

The examples use generic project names. The main path uses a Python and
notebook-oriented workflow to make the steps concrete, but the same pattern can
be adapted to other tools.

## What CSD3 Adds

CSD3 helps when work can be split into independent jobs. Common examples:

- simulations with many parameter settings
- model fitting across subjects, datasets, or hyperparameters
- batch data processing
- report or figure generation
- notebook execution
- repeated command-line analyses

The common pattern is:

```text
prepare inputs -> submit jobs -> monitor logs -> collect outputs
```

This is different from using the cluster as one bigger laptop. The strongest
cluster workflows are designed as batches of self-contained jobs.

## The Three Places

Keep these places separate while reading the commands:

```text
local machine
  write code, prepare inputs, inspect final results

CSD3 login node
  edit files, pull repos, submit jobs, inspect logs

CSD3 compute node
  runs the scheduled job after Slurm starts it
```

You usually do not log into a compute node yourself. You submit a job from the
login node, and Slurm starts it later on a compute node.

## What A Job Needs

A common local pattern is to write one script that loops over every unit of
work: run this analysis for every subject, every input file, every simulation
seed, or every parameter setting.

That can be fine on a laptop, but it hides the parallelism from the scheduler.
From Slurm's point of view, that script is just one long job.

A local script often looks like this:

```text
for each input:
  run the analysis
```

The cluster version usually looks more like this:

```text
run the analysis for this one input
```

For cluster work, the better pattern is usually to make one unit of work
explicit. Instead of "run everything," the job should mean something like "run
case 001," "fit subject 17," "simulate seed 42," or "process this one input
file."

Then Slurm can run many copies of the same command with different inputs.

A good cluster job needs:

- a command that runs one unit of work
- parameters or input files that identify that unit
- a working directory and software environment
- predictable output paths for that unit
- stdout and stderr logs for that unit
- resource requests that fit one unit, such as time, memory, CPUs, and account

The important design choice is that the job should not contain the whole outer
loop. The job should handle one unit cleanly, and the scheduler should handle
the repetition.

## Vocabulary

`Slurm` is the scheduler on CSD3. It decides when and where jobs run.

`sbatch` is the command that submits a job to Slurm.

A `job` is one scheduled piece of work.

A `job array` is a group of similar jobs submitted together.

A `login node` is where you connect, edit, pull code, and submit jobs.

A `compute node` is where the job actually runs.

`stdout` and `stderr` logs are the text files that show normal output and error
output from a job.

## Main Point

The login node is not where large computations should run. Treat it as a
control room for editing, submitting, and inspecting work. Compute-heavy work
should run as scheduled jobs.
