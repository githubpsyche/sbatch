# Narrow Sbatch Plan

## Goal

The immediate goal is to make it easy to prepare a project's rendered notebooks and then run all of them on the cluster.

## Minimal Contract

Projects keep project-local prepare entrypoints, typically `render_*.ipynb` notebooks.
Those entrypoints must support a non-executing prepare step, usually `pm.execute_notebook(..., prepare_only=True)`.
That prepare step must write executable notebooks into a known rendered or staging directory.
The shared runner only needs to execute all prepared notebooks in a specified directory or manifest.

For the near term, `lpp_ecmr` and `repfr` are just example active projects that should satisfy this contract.

## Boundary

Project orchestration stays project-local.
Reusable one-job execution notebooks may live in `jaxcmr/templates` when they are genuinely shared.
The earlier idea that `render_*` notebooks themselves should be centralized in `jaxcmr` is too constricted and should be rejected.
The shared `sbatch` layer should only prepare, enumerate, submit, and execute prepared notebooks without needing project-specific scientific logic.

## Deferred Work

This note does not settle full template centralization across projects.
It does not require one exact shared project layout.
It does not yet define richer manifests, resource-profile handling, or a one-command full-project rerender workflow.
It also does not address archival or vendor mode for finished projects.

Broader architecture can stay in `project_standards.md` or future notes rather than being folded into this narrow planning note.
