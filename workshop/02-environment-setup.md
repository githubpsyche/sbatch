# Environment Setup

A submitted job starts in a fresh non-interactive shell. It will not
automatically inherit whatever worked in your local terminal.

Before submitting jobs, make the project, data, outputs, and software
environment explicit on CSD3.

## What The Environment Has To Provide

Every job needs the same basic pieces:

- source code or executable program
- input files or parameters for one unit of work
- output folders that already exist or can be created by the job
- software environment, such as Python, R, MATLAB, modules, or compiled tools
- allocation/account information for Slurm

The exact tools can differ. The important point is that the command can run from
a clean CSD3 shell without depending on hidden local state.

## Workspace Layout

A simple CSD3 layout is:

```text
~/workspace/
  my_project/
    analyses/
      rendered/
    inputs/
    outputs/
    scripts/
    runs/
  sbatch/
  .venv/
  cluster_env.sh
```

`my_project/` is the project you want to run.

`inputs/` contains data, parameter files, or other job inputs.

`analyses/rendered/` contains prepared work units, such as rendered notebooks.

`outputs/` contains generated results.

`scripts/` contains reusable commands.

`runs/` contains logs and submission records.

`cluster_env.sh` is one activation file that manual commands and Slurm jobs can
both source.

## CSD3: Create Or Update The Workspace

```bash
mkdir -p "$HOME/workspace"
cd "$HOME/workspace"
```

Clone or copy the project:

```bash
git clone <project-repo-url> my_project
```

If you want to use the notebook helper scripts from this repo:

```bash
git clone https://github.com/githubpsyche/sbatch.git sbatch
```

If the repos already exist, inspect before pulling:

```bash
cd "$HOME/workspace/my_project"
git status --short
git pull
```

Do not pull over remote edits you have not reviewed.

## Choose The Software Setup

Use the environment manager appropriate for the project. The examples use Python
because that is the main workflow shown here. Other projects might use R,
MATLAB, shell scripts, compiled programs, or CSD3 modules.

For a Python project using `uv`, one pattern is:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source "$HOME/.local/bin/env"
echo 'source "$HOME/.local/bin/env"' >> "$HOME/.bashrc"

cd "$HOME/workspace"
uv venv "$HOME/workspace/.venv" --python 3.12
source "$HOME/workspace/.venv/bin/activate"
uv pip install -e my_project
```

For a notebook workflow, install the tools that execute notebooks:

```bash
uv pip install jupyter nbclient papermill
```

For other workflows, replace the Python setup with the setup your command
actually needs. Examples might start like:

```bash
module avail
module load <module-name>
Rscript scripts/run_case.R inputs/case001.csv outputs/case001/
matlab -batch "run_case('inputs/case001.mat', 'outputs/case001')"
```

## CSD3: Create The Activation Script

Create one activation script that manual commands and Slurm jobs can both
source.

For the Python example:

```bash
cat > "$HOME/workspace/cluster_env.sh" <<'EOF'
source "$HOME/.local/bin/env"
source "$HOME/workspace/.venv/bin/activate"
EOF

chmod +x "$HOME/workspace/cluster_env.sh"
```

For a module-based workflow, the same file might contain:

```bash
module purge
module load <module-name>
```

The point is not the filename. The point is to keep activation commands in one
place so the terminal test and the submitted job use the same setup.

## CSD3: Verify Before Submitting

Activate the environment from a clean terminal:

```bash
source "$HOME/workspace/cluster_env.sh"
cd "$HOME/workspace/my_project"
```

Check the tool your jobs will use:

```bash
python --version
python -c "import my_project; print(my_project.__file__)"
```

For a non-Python project, replace those checks with the command layer your jobs
will use, such as `Rscript`, `matlab`, or a compiled executable.

Check your available CSD3 allocation:

```bash
mybalance
```

If an `sbatch` script contains an account line such as `#SBATCH -A <account>`,
use the account for your CSD3 project.
