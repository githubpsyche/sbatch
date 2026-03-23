Soon we'll switch to a default of fitting on the cluster.
The batch render setup is preparation for that.
Need to do a few things to standardize the full pipeline:

- Centralization of template notebooks so that new features aren't accidentally added to one and not the other. Involves discarding templates in satellite projects after migrating any of their interesting unique features to the central templates.

- From there, we need to standardize practices for the render notebooks themselves. Ideally they'd also depend on template notebooks with project-specific generation of model variants and analyses specified externally. This would allow us to use the same sbatch workflow across projects and make it easier to add new projects without needing to rewrite the render notebooks.

- Then I need to work on standardizing the sbatch workflow itself, which is currently isolated in workspace/scripts and based on the lpp_ecmr project. Ideally, these artifacts will live in the jaxcmr/ repo where I'll provide a standard sbatch workflow that can be used across projects. This will involve some refactoring of the current workflow to make it more modular and adaptable to different project needs simply by moving the same workflow to a different project and changing some parameters.

- Ideally, it'll be possible to re-render an entire project on the cluster by simply running a single command that points to the project and the workflow will take care of the rest. This will make it much easier to keep projects up to date with the latest features and improvements in the central templates and sbatch workflow.

- Scheme for eventual translation of templates and other jaxcmr artifacts back to projects once they're ready for archival so the projects can be more self-contained and less dependent on the central repo.
