# Presenter Script

This is a presenter runbook for a 60 minute walkthrough of the CSD3 workflow
guide. It is not a public handout. The public handout is the Quarto site.

The talk should feel like a guided tour through one real workflow. The site
provides the durable, project-agnostic explanation; your screen provides the
concrete example.

## Talk Goal

By the end, people should understand the shape of remote cluster work:

- decide whether work can be split into repeated units
- prepare one unit so it can run without interaction
- move source code, inputs, and prepared units deliberately
- run one scheduled job before scaling up
- submit the full batch through Slurm
- inspect queue state, logs, and outputs
- recover failures without blindly rerunning everything
- decide whether follow-up work should run on CSD3 or locally

Do not make the talk about reproducing your private project. Say explicitly
that your live example is a Python and notebook-heavy workflow, but the pattern
translates to R, MATLAB, shell scripts, compiled tools, simulations, data
processing, report generation, and model fitting.

## Placeholders To Fill Before Presenting

Replace these mentally or in a private scratch file before the talk:

```text
<project_dir>        ~/workspace/my_project
<local_project_dir>  ~/workspace/my_project
<single_notebook>    ~/workspace/my_project/analyses/rendered/fitting_example_unit0.ipynb
<notebook_glob>      fitting_*_unit*.ipynb
<run_dir>            ~/workspace/my_project/runs/<run_id>
<run_tag>            experiment_001
<cluster_login>      <your-crsid-or-username>@login-cpu.hpc.cam.ac.uk
<throttle>           25 or 50
```

If possible, prepare one successful run directory and one small failure example
before the talk. The failure example is optional, but useful because log
inspection is clearer when there is something real to inspect.

## Screen Setup

Have these windows ready before people arrive.

### Browser

Open the public guide:

```text
http://localhost:5361/
```

Keep the sidebar visible. This is the spine of the talk.

### Local VS Code Window

Open your local project. Useful files or folders to have visible:

- the maintained notebook or script that generates prepared units
- `analyses/rendered/`
- a small output folder, if safe to show
- any local summary or comparison notebook/script you might mention

Do not rely on showing private code internals. The useful thing to show is the
workflow shape: source file, rendered units, outputs, summaries.

### CSD3 VS Code Remote-SSH Window

Open a second VS Code window connected to CSD3 through Remote Explorer. Open
`~/workspace/` or the remote project folder.

Useful remote files or folders:

- `~/workspace/cluster_env.sh`
- `~/workspace/sbatch/run_notebook.sbatch`
- `~/workspace/sbatch/submit_notebooks.sh`
- `<project_dir>/analyses/rendered/`
- `<project_dir>/runs/<run_id>/manifest.txt`
- `<project_dir>/runs/<run_id>/logs/`
- one executed notebook, if using notebooks

### Terminals

Keep terminals visually distinct:

- local terminal: used for `rsync` and local files
- CSD3 Remote-SSH terminal: used for `source`, `sbatch`, `squeue`, `sacct`, and logs

At the start of the demo, explicitly say which terminal is local and which is
remote. This prevents a lot of later confusion.

## Timing Overview

This version assumes 55 minutes of walkthrough and 5 minutes of questions or
setup discussion.

```text
00:00-05:00  Start page and promise of the talk
05:00-11:00  Cluster mental model
11:00-17:00  Tools and access
17:00-23:00  CSD3 environment
23:00-32:00  Prepare work units
32:00-38:00  Transfer files
38:00-45:00  Run one Slurm job
45:00-51:00  Submit the batch
51:00-56:00  Monitor and recover
56:00-60:00  Follow-up work, results, focused reruns, resources
```

If the room asks many setup questions, protect the middle of the talk. Say:
"I want to park setup-specific debugging so we still get to the actual cluster
workflow. The guide links to the CSD3 connection docs, and we can look at
individual setup issues afterward."

## 00:00-05:00 Start Page

Show:

- [Start page](../index.qmd) in the browser
- the "What This Guide Helps You Do" section
- the "Notebook Helper Scripts" section

Say:

```text
This is a practical guide for using CSD3 for research work that can be split
into scheduled jobs.

The guide is not trying to be a complete CSD3 manual. It gives a working path:
prepare work, move files, run one job, scale up, monitor, recover, and decide
where results should go.

My live example uses a Python and notebook-heavy workflow because that is the
workflow I actually use. The transferable part is not Python, notebooks, or my
research code. The transferable part is the shape of the workflow.
```

Point out:

- the guide is public and project-agnostic
- the repo also contains notebook-oriented helper scripts
- people doing R, MATLAB, shell, compiled code, or simulations still use the
  same Slurm concepts

Do not spend time on every resource link. Say:

```text
The homepage and resources page give you the official CSD3 links for details
that change over time. Today I am going to focus on the workflow.
```

Transition:

```text
Before we touch commands, the most important thing is the mental model: where
the work happens, and what makes work suitable for a cluster.
```

## 05:00-11:00 Orientation And Mental Model

Show:

- [Orientation](../workshop/00-orientation.qmd)
- "The Three Places"
- "What A Job Needs"
- [Workflow Map](../workshop/03-workflow-map.md)

Say:

```text
The cluster is not one bigger laptop. It is a system for submitting jobs to
compute nodes.

There are three places to keep straight. My local machine is where I edit and
review. The login node is where I connect, move files, and submit jobs. The
compute node is where scheduled work actually runs.
```

For the "What A Job Needs" section, say:

```text
A common first instinct is to write one script with a for-loop that processes
every subject, input file, parameter setting, or report.

That can work locally, but it does not use the cluster well. For cluster work,
I usually want to define the single repeated unit: one subject, one input file,
one simulation seed, one parameter setting.

Then I make that unit runnable by itself. Slurm can run many of those units as
separate scheduled tasks.
```

Show the workflow map and say:

```text
This is the lifecycle we will walk through. Prepare the units, transfer the
needed files, run one scheduled job, submit the full batch, monitor and recover,
then decide what downstream work happens on CSD3 versus locally.
```

Point to the map briefly. Do not explain every page yet.

Transition:

```text
Now I want to show the interface I recommend for working this way, because it
makes the remote system much less mysterious.
```

## 11:00-17:00 Tools And Access

Show:

- [Tools And Access](../workshop/01-tools-and-access.md)
- VS Code Remote Explorer
- local VS Code window
- CSD3 Remote-SSH VS Code window

Say:

```text
The default interface I recommend is VS Code Remote-SSH. It still uses normal
SSH underneath, but it gives you a file browser, editor, and terminal on the
remote system.

Remote Explorer is the VS Code panel where the configured SSH targets appear.
Once I connect, this VS Code window is looking at files on CSD3, not files on my
Mac.
```

Show local terminal and say:

```bash
pwd
hostname
```

Show CSD3 Remote-SSH terminal and say:

```bash
pwd
hostname
```

Narrate the contrast:

```text
These commands look similar, but they are running in different places. The
local terminal is for local files and file transfer. The CSD3 terminal is for
checking the remote project, activating the environment, submitting jobs, and
looking at logs.
```

Mention other tools:

```text
For file movement, I use rsync heavily. For source code, Git is useful, but I
do not want to assume everyone is already comfortable with Git. The safe
distinction for today is: rsync moves files directly; Git records and syncs
source-code changes deliberately.
```

Mention other languages:

```text
My example uses Python. If your workflow is R, MATLAB, shell scripts, compiled
code, or a field-specific command-line tool, the interface and scheduler story
are the same. What changes is the command you run inside the job.
```

Transition:

```text
Once I can connect, the next question is whether the same environment can be
activated reliably when a job runs without me watching it.
```

## 17:00-23:00 Environment Setup

Show:

- [Environment Setup](../workshop/02-environment-setup.md)
- remote `~/workspace/`
- `cluster_env.sh`

In the CSD3 Remote-SSH terminal, show:

```bash
cd "$HOME/workspace"
pwd
ls
```

Say:

```text
I keep active project work under ~/workspace on CSD3. The exact layout can
vary, but the important thing is that I know where my project, helper scripts,
environment activation, inputs, outputs, and run logs live.
```

Show the activation script:

```bash
sed -n '1,120p' "$HOME/workspace/cluster_env.sh"
```

Say:

```text
The activation script is the bridge between interactive work and scheduled
work. If I need to source an environment by hand, the job script also needs to
source it.

This is why I prefer an explicit cluster_env.sh rather than relying on hidden
shell state.
```

Run simple checks if safe:

```bash
source "$HOME/workspace/cluster_env.sh"
python --version
which python
mybalance
```

Say:

```text
The goal here is not to teach every possible environment manager. The goal is
to make sure the command I submit later can find the same Python, R, MATLAB,
modules, compiled program, or other tool that I tested interactively.
```

Transition:

```text
Now we get to the most important design step: deciding what one unit of work is
and preparing those units before asking Slurm to run them.
```

## 23:00-32:00 Prepare Work Units

Show:

- [Prepare Work Units](../workshop/04-prepare-work-units.qmd)
- local project file that defines or renders units
- local or remote `analyses/rendered/`

Say:

```text
This is the step where cluster work becomes concrete. Before submission, I want
the batch to be explicit: what units exist, and how one scheduled task knows
which unit to run.
```

Explain the two representations:

```text
There are two common ways to represent the batch.

The cleaner general pattern is one parametrizable runner plus a manifest. The
runner knows how to process one unit. The manifest lists all units. Each array
task reads one row.

The notebook-heavy pattern I use here is more concrete: I render one notebook
per unit. That is a little heavy, but it makes each unit inspectable and easy
to resubmit. Then the helper script builds a manifest of those notebook paths.
```

Show rendered files:

```bash
cd "<local_project_dir>"
find analyses/rendered -maxdepth 1 -type f -name "*.ipynb" | sort | head
find analyses/rendered -maxdepth 1 -type f -name "*.ipynb" | wc -l
```

Say:

```text
At this point, I have not submitted anything. I have made the work visible. I
can inspect the filenames, count the units, and make sure the unit identity is
clear before I ask CSD3 to run anything.
```

If showing a notebook renderer, say:

```text
In this workflow, a maintained notebook or script creates rendered notebooks.
Sometimes I use a prepare-only mode: generate the notebooks that define each
unit, but do not run the expensive work locally.
```

Make the adaptation explicit:

```text
If this were R, MATLAB, shell, or compiled code, the prepared unit might be a
manifest row, a JSON file, a CSV row, or a command-line argument set. The same
question still applies: can one scheduled task run exactly one unit without
manual intervention?
```

Transition:

```text
Once the units exist locally, I need the right files on CSD3. This is where
rsync and Git have different roles.
```

## 32:00-38:00 Transfer Files

Show:

- [Transfer Files With rsync And Git](../workshop/05-transfer-files.md)
- local terminal for `rsync`
- CSD3 terminal for inspecting transferred files

Say:

```text
File movement is part of the workflow, not an afterthought. A job fails just as
quickly from missing files as from bad code.
```

Explain `rsync`:

```text
rsync is my default file-transfer tool. It can send a directory up, bring
outputs back, and only transfer changes.
```

Local terminal example:

```bash
cd "<local_project_dir>"
CLUSTER="<cluster_login>"

rsync -av --progress analyses/rendered/ \
  "${CLUSTER}:~/workspace/my_project/analyses/rendered/"
```

CSD3 terminal example:

```bash
cd "$HOME/workspace/my_project"
find analyses/rendered -maxdepth 1 -type f -name "*.ipynb" | sort | head
```

Explain Git without overassuming expertise:

```text
Git is for source-code changes I want to track deliberately. rsync is for
generated files, rendered notebooks, inputs, outputs, and other files that may
not belong in Git.

If your project already uses Git, the remote copy can pull source changes. If
not, the key idea today is still the same: know which files need to exist on
CSD3 before you submit.
```

Optional CSD3 Git commands:

```bash
cd "$HOME/workspace/my_project"
git status --short
git pull
```

Transition:

```text
Now that the prepared unit and environment are on CSD3, I do not jump straight
to the full batch. I run one scheduled job first.
```

## 38:00-45:00 Run One Slurm Job

Show:

- [Run One Slurm Job](../workshop/06-run-one-slurm-job.qmd)
- `run_notebook.sbatch`
- CSD3 terminal
- one log pair or executed notebook

Open `run_notebook.sbatch` and point to four regions:

1. `#SBATCH` resource settings
2. notebook path resolution
3. project root and environment activation
4. Papermill execution

Say:

```text
An sbatch file is a recipe for one scheduled job. The top tells Slurm what
resources to request. The body prepares the environment and runs the actual
work.
```

Point to the resource lines and say:

```text
These settings are not universal. The account, partition, time, memory, and CPU
count need to match the allocation and workload. The guide gives the idea, but
you check CSD3 documentation and your own allocation for the right values.
```

Point to the environment activation and say:

```text
This is why we made the activation script explicit. The job is not my
interactive shell. It needs to activate what it needs.
```

Point to Papermill and say:

```text
For this notebook helper, Papermill is the command-line tool that executes the
notebook. If this were another workflow, this line could be Rscript, matlab, a
shell script, or a compiled executable.
```

Submit one job if safe:

```bash
mkdir -p "$HOME/workspace/my_project/runs"
cd "$HOME/workspace/sbatch"

sbatch \
  --output "$HOME/workspace/my_project/runs/single_%j.out" \
  --error "$HOME/workspace/my_project/runs/single_%j.err" \
  run_notebook.sbatch \
  "<single_notebook>"
```

If not submitting live, say:

```text
I am going to show the command and then use a previously completed run so we do
not wait on the scheduler during the session.
```

Show queue and logs:

```bash
squeue -u "$USER"

SINGLE_OUT="$(ls -t "$HOME/workspace/my_project/runs"/single_*.out | head -1)"
SINGLE_ERR="${SINGLE_OUT%.out}.err"

sed -n '1,120p' "$SINGLE_OUT"
sed -n '1,120p' "$SINGLE_ERR"
```

Say:

```text
This one-job step is partly a smoke test, but it is also a teaching tool. One
job has a prepared unit, a submission command, resource settings, an
environment, stdout, stderr, and outputs. The full batch is the same structure
repeated many times.
```

Transition:

```text
Once one scheduled job works, the batch submission is not a new idea. It is the
same job shape repeated through an array.
```

## 45:00-51:00 Submit The Batch

Show:

- [Submit The Batch](../workshop/07-submit-the-batch.qmd)
- `submit_notebooks.sh`
- newest `runs/<run_id>/`
- `manifest.txt`
- `submission.txt`
- `logs/`

Say:

```text
The batch is a prepared directory, a filename pattern, and a Slurm array. The
array is the scheduler mechanism. The manifest is the list of units.
```

Show the command:

```bash
cd "$HOME/workspace/sbatch"

./submit_notebooks.sh \
  "$HOME/workspace/my_project/analyses/rendered" \
  "<notebook_glob>" \
  <throttle>
```

Explain throttle:

```text
The throttle does not change how many units are submitted. It limits how many
run at the same time. That matters for resource use and for being a good
cluster citizen.
```

Show run directory:

```bash
cd "$HOME/workspace/my_project"
RUN_DIR="$(ls -td runs/* | head -1)"

printf '%s\n' "$RUN_DIR"
sed -n '1,12p' "$RUN_DIR/manifest.txt"
cat "$RUN_DIR/submission.txt"
find "$RUN_DIR/logs" -maxdepth 1 -type f | sort | head
```

Say:

```text
This run directory is the audit trail. It tells me what I submitted, which job
IDs Slurm assigned, and where the logs are.
```

Explain array mapping:

```text
Task 0 reads line 1 of the manifest. Task 1 reads line 2. Each task runs the
same job script, but on a different prepared unit.
```

Transition:

```text
Submission is not the end. The next skill is knowing what happened after the
scheduler accepted the job.
```

## 51:00-56:00 Monitor And Recover

Show:

- [Monitor And Recover](../workshop/08-monitor-and-recover.md)
- CSD3 terminal
- `check_run.sh -v` output
- one `.err` file
- one executed notebook, if useful

Run:

```bash
squeue -u "$USER"
sacct -j <job_id> --format=JobID,JobName,State,Elapsed,ExitCode
```

Say:

```text
squeue tells me what is still pending or running. sacct is useful after jobs
finish. The scheduler state tells me whether Slurm thinks the task completed,
but the logs tell me what the code actually did.
```

Run the helper:

```bash
cd "$HOME/workspace/my_project"
"$HOME/workspace/sbatch/check_run.sh"
"$HOME/workspace/sbatch/check_run.sh" -v
```

Say:

```text
The verbose view is useful because it ties a task state back to the prepared
unit and the stderr path. That lets me inspect the specific failed unit instead
of treating the batch as one opaque thing.
```

Inspect stderr:

```bash
sed -n '1,160p' "<run_dir>/logs/<log_file>.err"
```

If showing notebook progress:

```text
For notebook jobs, the executed notebook is itself a progress artifact. I can
open it while or after it runs and see how many cells executed, what output
appeared, and whether a traceback was written.
```

Say:

```text
This is also why progress output matters. In Python I often use tqdm for loops.
In other workflows, use whatever progress meter or regular stdout messages make
sense. The point is that logs should tell you whether the job is alive and where
it was when it failed.
```

Explain recovery:

```text
I separate transient from structural failures. If one isolated task fails with
something that looks transient, resubmission may be reasonable. If many tasks
fail the same way, resubmitting just reproduces the same failure. Fix the code,
inputs, paths, or environment first.
```

Show resubmission command but do not necessarily run:

```bash
cd "$HOME/workspace/my_project"
"$HOME/workspace/sbatch/resubmit_failed.sh"
```

Transition:

```text
After I know the first batch succeeded or has been repaired, I can decide what
downstream work belongs on CSD3 and what should come back to my local machine.
```

## 56:00-60:00 Follow-Up Jobs, Results, Reruns, Resources

This is a fast closing section. Do not try to demo every command live unless
you are ahead of schedule.

Show:

- [Run Follow-Up Jobs](../workshop/09-follow-up-jobs.md)
- [Post-Process Or Bring Results Back](../workshop/10-post-process-or-bring-results-back.qmd)
- [Focused Reruns](../workshop/11-focused-reruns.md)
- [Resources](../workshop/12-resources.md)

### Follow-Up Jobs

Say:

```text
Some workflows need a second stage after the batch: merge per-unit outputs,
submit aggregate analyses, build reports, or clean intermediates.

The key concept is dependency. A follow-up job should run after the upstream
work reaches the state I intended.
```

Point out the sentinel option:

```text
The helper script calls this a sentinel. It is just a project-specific follow-up
script submitted with a Slurm dependency.
```

### Post-Process Or Bring Results Back

Say:

```text
There is a choice here. If the next step is still compute-heavy or reads many
large files, keep it on CSD3. If the next step is local inspection, writing,
figures, or comparison, bring back a filtered set of outputs with rsync.
```

Show the shape of the `rsync` command:

```bash
RUN_TAG="<run_tag>"
CLUSTER="<cluster_login>"

rsync -av --progress --prune-empty-dirs \
  --include='*/' \
  --include="*${RUN_TAG}*" \
  --exclude='*' \
  "${CLUSTER}:~/workspace/my_project/outputs/" outputs/
```

Say:

```text
The filter matters. I do not want to blindly copy every temporary file. I want
the files needed for inspection, summaries, reports, or the next local
comparison.
```

### Focused Reruns

Say:

```text
The last operational habit is focused reruns. After a code change, failed
subset, or corrected input, do not rerun everything by default. Narrow the
inputs, clear only stale target outputs, submit only the target jobs, and sync
only matching results back.
```

### Resources

Show the resources page and say:

```text
The guide is intentionally not a giant reference list. Use it as the workflow
path, and use these links for official CSD3 details, Remote Explorer, Python
environments, command-line arguments, Papermill, and progress output.
```

Closing line:

```text
The main thing I want you to leave with is not a memorized command. It is the
shape of the work: make one unit runnable, schedule it, inspect it, scale it,
and move only the files that need to move.
```

## Optional Cut Plan

If running behind, cut in this order:

1. Do not live-run `rsync`; show the command and inspect existing remote files.
2. Do not live-submit one Slurm job; show a completed single-job log.
3. Do not open `submit_notebooks.sh`; show the run directory and manifest.
4. Compress follow-up jobs, results, and reruns into a 3 minute summary.
5. Move participant setup debugging to after the talk.

Do not cut:

- local vs CSD3 vs compute-node distinction
- one repeated unit versus one giant loop
- environment activation
- one scheduled job before full batch
- logs and failure triage

## Files To Show

Public site:

- [Start page](../index.qmd)
- [Orientation](../workshop/00-orientation.qmd)
- [Tools And Access](../workshop/01-tools-and-access.md)
- [Environment Setup](../workshop/02-environment-setup.md)
- [Workflow Map](../workshop/03-workflow-map.md)
- [Prepare Work Units](../workshop/04-prepare-work-units.qmd)
- [Transfer Files](../workshop/05-transfer-files.md)
- [Run One Slurm Job](../workshop/06-run-one-slurm-job.qmd)
- [Submit The Batch](../workshop/07-submit-the-batch.qmd)
- [Monitor And Recover](../workshop/08-monitor-and-recover.md)
- [Run Follow-Up Jobs](../workshop/09-follow-up-jobs.md)
- [Post-Process Or Bring Results Back](../workshop/10-post-process-or-bring-results-back.qmd)
- [Focused Reruns](../workshop/11-focused-reruns.md)
- [Resources](../workshop/12-resources.md)

Helper scripts:

- [run_notebook.sbatch](../run_notebook.sbatch)
- [submit_notebooks.sh](../submit_notebooks.sh)
- [check_run.sh](../check_run.sh)
- [resubmit_failed.sh](../resubmit_failed.sh)

Project-side examples:

- [project script examples](../examples/project-scripts/README.md)
- [post_fit.sh](../examples/project-scripts/post_fit.sh)
- [post_model_fit.sh](../examples/project-scripts/post_model_fit.sh)
- [merge_partials.py](../examples/project-scripts/merge_partials.py)

Private live project:

- maintained notebook or script that defines units
- rendered notebook directory
- remote project directory
- `cluster_env.sh`
- a completed `runs/<run_id>/`
- `manifest.txt`
- `submission.txt`
- `logs/*.out` and `logs/*.err`
- one executed notebook or generated output artifact

## Commands To Keep Handy

Local machine:

```bash
pwd
hostname

cd "<local_project_dir>"
CLUSTER="<cluster_login>"

rsync -av --progress analyses/rendered/ \
  "${CLUSTER}:~/workspace/my_project/analyses/rendered/"
```

CSD3 Remote-SSH terminal:

```bash
pwd
hostname

cd "$HOME/workspace"
ls
source "$HOME/workspace/cluster_env.sh"
python --version
which python
mybalance
```

Prepared units:

```bash
cd "$HOME/workspace/my_project"
find analyses/rendered -maxdepth 1 -type f -name "*.ipynb" | sort | head
find analyses/rendered -maxdepth 1 -type f -name "*.ipynb" | wc -l
```

One scheduled job:

```bash
mkdir -p "$HOME/workspace/my_project/runs"
cd "$HOME/workspace/sbatch"

sbatch \
  --output "$HOME/workspace/my_project/runs/single_%j.out" \
  --error "$HOME/workspace/my_project/runs/single_%j.err" \
  run_notebook.sbatch \
  "<single_notebook>"
```

Batch submission:

```bash
cd "$HOME/workspace/sbatch"

./submit_notebooks.sh \
  "$HOME/workspace/my_project/analyses/rendered" \
  "<notebook_glob>" \
  <throttle>
```

Run directory:

```bash
cd "$HOME/workspace/my_project"
RUN_DIR="$(ls -td runs/* | head -1)"

printf '%s\n' "$RUN_DIR"
sed -n '1,12p' "$RUN_DIR/manifest.txt"
cat "$RUN_DIR/submission.txt"
find "$RUN_DIR/logs" -maxdepth 1 -type f | sort | head
```

Monitoring:

```bash
squeue -u "$USER"
sacct -j <job_id> --format=JobID,JobName,State,Elapsed,ExitCode

cd "$HOME/workspace/my_project"
"$HOME/workspace/sbatch/check_run.sh"
"$HOME/workspace/sbatch/check_run.sh" -v
```

Failure inspection and resubmission:

```bash
sed -n '1,160p' "<run_dir>/logs/<log_file>.err"

cd "$HOME/workspace/my_project"
"$HOME/workspace/sbatch/resubmit_failed.sh"
```

Filtered result retrieval:

```bash
cd "<local_project_dir>"
RUN_TAG="<run_tag>"
CLUSTER="<cluster_login>"

rsync -av --progress --prune-empty-dirs \
  --include='*/' \
  --include="*${RUN_TAG}*" \
  --exclude='*' \
  "${CLUSTER}:~/workspace/my_project/outputs/" outputs/
```

## Live Demo Guardrails

Use precomputed artifacts whenever waiting on CSD3 would slow the talk.

Good live actions:

- show Remote Explorer connection
- distinguish local and remote terminals
- inspect remote folders
- inspect `cluster_env.sh`
- inspect helper scripts
- inspect prepared units
- inspect a manifest and logs
- run `squeue`, `sacct`, and `check_run.sh`

Riskier live actions:

- first-time SSH setup
- package installation
- large `rsync`
- full batch submission
- debugging a structural failure from scratch

If a live command fails, say:

```text
This is exactly why I like having run directories and logs. For the talk, I am
going to switch to a completed example so we can keep following the workflow.
The debugging process would start from the stderr file and the prepared unit
for that task.
```

## Questions To Invite

Good questions during the talk:

- What is the repeated unit in your project?
- What files does one unit need?
- What command runs one unit without interaction?
- Which outputs need to come back locally?
- What would count as a transient failure versus a structural failure?

Questions to defer until after:

- individual MFA or SSH configuration problems
- package install problems in a specific environment
- choosing exact CSD3 partitions or accounts for someone else's allocation
- private project-specific debugging

## Presenter Checklist

Before presenting:

- confirm the guide opens at `http://localhost:5361/`
- confirm the local project window has safe files visible
- confirm VS Code Remote-SSH connects to CSD3
- confirm `~/workspace/cluster_env.sh` is safe to show
- confirm a completed `runs/<run_id>/` exists
- identify one prepared notebook or unit to show
- identify one `.out` and one `.err` file to show
- identify whether you will submit live or use precomputed output
- replace placeholders in any commands you plan to paste
- decide which private code or data should not be shown

After presenting:

- point people back to the start page and resources page
- invite setup-specific questions
- help participants translate "one prepared unit" into their own workflow
- avoid making your notebook helper sound like the only valid cluster pattern
