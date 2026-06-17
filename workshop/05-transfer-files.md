# Transfer Files With rsync And Git

Before a job can run on CSD3, CSD3 needs the files the job will read: source
code, prepared work units, data, and configuration.

Two tools are useful here:

`rsync` copies files between your local machine and CSD3.

Git synchronizes source-code history between machines.

In this guide, think of `rsync` as the direct file-transfer tool and Git as
the source-code tracking tool.

## File Transfer With rsync

Use `rsync` for files that need to move but should not necessarily become Git
history:

- rendered notebooks in `analyses/rendered/`
- input files
- generated outputs
- executed notebooks
- large or temporary files

`rsync` works in both directions. The direction is determined by which path is
first.

Local to CSD3:

```text
local_path/  cluster:path/
```

CSD3 to local:

```text
cluster:path/  local_path/
```

The trailing slash means "copy the contents of this directory."

## Local Machine: Transfer Prepared Inputs Up

```bash
cd "$HOME/workspace/my_project"
CLUSTER="<your-crsid-or-username>@login-cpu.hpc.cam.ac.uk"

rsync -av --progress analyses/rendered/ \
  "${CLUSTER}:~/workspace/my_project/analyses/rendered/"

rsync -av --progress inputs/ \
  "${CLUSTER}:~/workspace/my_project/inputs/"
```

If your prepared units live somewhere else, replace `analyses/rendered/` with
that directory.

## CSD3: Inspect The Transferred Files

```bash
cd "$HOME/workspace/my_project"
find analyses/rendered -maxdepth 1 -type f | sort | head
find inputs -maxdepth 1 -type f | sort | head
```

One prepared unit should be visible on CSD3 before you submit it:

```text
~/workspace/my_project/analyses/rendered/fitting_example_unit0.ipynb
```

## What Git Is For

Git is useful when the change is source code or a deliberate small project
change that you want recorded:

- Python, R, MATLAB, or shell scripts
- notebook sources or templates
- configuration files
- documentation
- helper scripts

The minimum Git habit for this guide is:

```bash
git status --short
```

Run it before pulling or pushing so you know whether there are local edits.

## Local Machine: Send Source Changes By Git

When source changes are ready to share with CSD3:

```bash
cd "$HOME/workspace/my_project"
git status --short
git add <changed-source-files>
git commit -m "Prepare cluster run"
git push
```

If you use the notebook helper scripts from this repo, keep that repo current
too.

## CSD3: Pull Source Changes

```bash
cd "$HOME/workspace/my_project"
git status --short
git pull
```

If you use the notebook helper scripts:

```bash
cd "$HOME/workspace/sbatch"
git status --short
git pull
```

Do not pull over remote edits you have not reviewed.

## Bring Files Back Later

Generated results usually come back with `rsync`, not Git. The result page uses
filtered `rsync` commands to retrieve only the generated files you need.
