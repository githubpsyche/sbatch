# Template Notebook Map

## Overview

This file is a point-in-time audit of template notebooks currently distributed across the workspace.
It maps each template once, groups same-purpose templates where the role match is clear, and summarizes the main behavioral differences between those peers.

Source directories in scope:

-   `jaxcmr/templates`
-   `lpp_ecmr/analyses/templates`
-   `cru_to_cmr/analyses/templates`
-   `selective_interference/analyses/simulations/templates`

Current template counts:

| Project | Source directory | Template count |
|----------------------|----------------------|---------------------------:|
| `jaxcmr` | `jaxcmr/templates` | 28 |
| `lpp_ecmr` | `lpp_ecmr/analyses/templates` | 7 |
| `cru_to_cmr` | `cru_to_cmr/analyses/templates` | 3 |
| `selective_interference` | `selective_interference/analyses/simulations/templates` | 1 |
| Total | — | 39 |

Current exact-name overlaps:

-   `fitting.ipynb` appears in `jaxcmr/templates` and `lpp_ecmr/analyses/templates`.
-   `parameter_shifting.ipynb` appears in `jaxcmr/templates`, `lpp_ecmr/analyses/templates`, and `cru_to_cmr/analyses/templates`.

## Inventory

| Project | Relative path | Notebook | Purpose label | Same-purpose group |
|---------------|---------------|---------------|---------------|---------------|
| `cru_to_cmr` | `cru_to_cmr/analyses/templates/free_recall_fitting.ipynb` | `free_recall_fitting.ipynb` | Free-recall single-model fit, simulation, and benchmark figures | `Fitting` |
| `cru_to_cmr` | `cru_to_cmr/analyses/templates/parameter_shifting.ipynb` | `parameter_shifting.ipynb` | Sweep one fitted parameter and plot SPC/CRP/PNR benchmarks | `Parameter shifting` |
| `cru_to_cmr` | `cru_to_cmr/analyses/templates/serial_recall_fitting.ipynb` | `serial_recall_fitting.ipynb` | Serial-recall confusable-model fit, simulation, and per-list-length figures | `Fitting` |
| `jaxcmr` | `jaxcmr/templates/backrepcrp.ipynb` | `backrepcrp.ipynb` | Repetition-centered backward-neighbour CRP analysis | — |
| `jaxcmr` | `jaxcmr/templates/catcrp.ipynb` | `catcrp.ipynb` | Category-conditioned distance-binned CRP analysis | — |
| `jaxcmr` | `jaxcmr/templates/compare_simulation_loss.ipynb` | `compare_simulation_loss.ipynb` | Monte Carlo bag-likelihood inspection and loss diagnostics | — |
| `jaxcmr` | `jaxcmr/templates/compound_cueing.ipynb` | `compound_cueing.ipynb` | Compound-cueing CRP analysis | — |
| `jaxcmr` | `jaxcmr/templates/conditional_corec_by_cat.ipynb` | `conditional_corec_by_cat.ipynb` | Conditional co-recall by category | — |
| `jaxcmr` | `jaxcmr/templates/conditional_corec_by_lag.ipynb` | `conditional_corec_by_lag.ipynb` | Conditional co-recall by lag | — |
| `jaxcmr` | `jaxcmr/templates/context.ipynb` | `context.ipynb` | Temporal context trajectory analysis | — |
| `jaxcmr` | `jaxcmr/templates/crp.ipynb` | `crp.ipynb` | Lag-CRP analysis | — |
| `jaxcmr` | `jaxcmr/templates/distcrp.ipynb` | `distcrp.ipynb` | Distance-conditioned CRP using embeddings | — |
| `jaxcmr` | `jaxcmr/templates/fitting.ipynb` | `fitting.ipynb` | Single-model fit, simulation, and benchmark diagnostics | `Fitting` |
| `jaxcmr` | `jaxcmr/templates/intrusion_error_rate.ipynb` | `intrusion_error_rate.ipynb` | Intrusion error-rate analysis | — |
| `jaxcmr` | `jaxcmr/templates/joint_corec_by_lag.ipynb` | `joint_corec_by_lag.ipynb` | Joint co-recall by lag | — |
| `jaxcmr` | `jaxcmr/templates/linear_memory.ipynb` | `linear_memory.ipynb` | Linear-memory diagnostic | — |
| `jaxcmr` | `jaxcmr/templates/log_odds_crp.ipynb` | `log_odds_crp.ipynb` | Lag-CRP log-odds contrast analysis | — |
| `jaxcmr` | `jaxcmr/templates/model_comparison.ipynb` | `model_comparison.ipynb` | Fitted-model comparison and summary metrics | — |
| `jaxcmr` | `jaxcmr/templates/nth_item_recall.ipynb` | `nth_item_recall.ipynb` | Nth-item recall probability analysis | — |
| `jaxcmr` | `jaxcmr/templates/omission_error_rate.ipynb` | `omission_error_rate.ipynb` | Omission error-rate analysis | — |
| `jaxcmr` | `jaxcmr/templates/order_error_rate.ipynb` | `order_error_rate.ipynb` | Order error-rate analysis | — |
| `jaxcmr` | `jaxcmr/templates/parameter_shifting.ipynb` | `parameter_shifting.ipynb` | Parameter sweep over fitted model behavior | `Parameter shifting` |
| `jaxcmr` | `jaxcmr/templates/pnr.ipynb` | `pnr.ipynb` | Probability-of-nth-recall analysis | — |
| `jaxcmr` | `jaxcmr/templates/relative_srac.ipynb` | `relative_srac.ipynb` | Relative serial-recall accuracy analysis | — |
| `jaxcmr` | `jaxcmr/templates/repcrp.ipynb` | `repcrp.ipynb` | Repetition-centered CRP with control comparison | — |
| `jaxcmr` | `jaxcmr/templates/repneighborcrp.ipynb` | `repneighborcrp.ipynb` | Repeated-item neighbour-transition analysis | — |
| `jaxcmr` | `jaxcmr/templates/rpl.ipynb` | `rpl.ipynb` | Recall probability by lag | — |
| `jaxcmr` | `jaxcmr/templates/serialrepcrp.ipynb` | `serialrepcrp.ipynb` | Serial repetition CRP analysis | — |
| `jaxcmr` | `jaxcmr/templates/spc.ipynb` | `spc.ipynb` | Serial position curve analysis | — |
| `jaxcmr` | `jaxcmr/templates/srac.ipynb` | `srac.ipynb` | Serial-recall accuracy analysis | — |
| `jaxcmr` | `jaxcmr/templates/termination_probability.ipynb` | `termination_probability.ipynb` | Recall termination-probability curve analysis | — |
| `lpp_ecmr` | `lpp_ecmr/analyses/templates/cat_lpp_by_recall.ipynb` | `cat_lpp_by_recall.ipynb` | Category-filtered LPP split by later recall status | `LPP/category analyses` |
| `lpp_ecmr` | `lpp_ecmr/analyses/templates/cat_lpp_spc.ipynb` | `cat_lpp_spc.ipynb` | LPP amplitude by study position and category | `LPP/category analyses` |
| `lpp_ecmr` | `lpp_ecmr/analyses/templates/cat_recall_by_lpp.ipynb` | `cat_recall_by_lpp.ipynb` | Recall rate by binned LPP amplitude and category | `LPP/category analyses` |
| `lpp_ecmr` | `lpp_ecmr/analyses/templates/cat_spc.ipynb` | `cat_spc.ipynb` | Category-conditioned serial position curve | `LPP/category analyses` |
| `lpp_ecmr` | `lpp_ecmr/analyses/templates/cross_validation.ipynb` | `cross_validation.ipynb` | Leave-one-list-out cross-validation fit/evaluate workflow | — |
| `lpp_ecmr` | `lpp_ecmr/analyses/templates/fitting.ipynb` | `fitting.ipynb` | Single-model fit, simulation, and benchmark diagnostics | `Fitting` |
| `lpp_ecmr` | `lpp_ecmr/analyses/templates/parameter_shifting.ipynb` | `parameter_shifting.ipynb` | Parameter sweep over fitted model behavior | `Parameter shifting` |
| `selective_interference` | `selective_interference/analyses/simulations/templates/interference_sweep.ipynb` | `interference_sweep.ipynb` | Selective-interference paradigm sweep with cached phase execution | `Selective-interference sweep` |

## Same-Purpose Comparisons

### Fitting

Templates in this group:

-   `jaxcmr/templates/fitting.ipynb`
-   `lpp_ecmr/analyses/templates/fitting.ipynb`
-   `cru_to_cmr/analyses/templates/free_recall_fitting.ipynb`
-   `cru_to_cmr/analyses/templates/serial_recall_fitting.ipynb`

Behavioral comparison:

-   Data/model assumptions: `jaxcmr` and `lpp_ecmr` share the same broad shape: fit one model, simulate from the fitted parameters, and generate benchmark analyses. The two `cru_to_cmr` templates play the same control-plane role, but they are split by dataset and recall paradigm: one targets free recall on `HealeyKahana2014`, the other targets serial recall on `Gordon2021`.
-   Project-specific imports or factories: `jaxcmr` and `lpp_ecmr` import model factories and algorithms through string parameters (`make_factory_path`, `component_paths`, `loss_fn_path`, `fit_alg_path`). `cru_to_cmr` imports project-local base and compterm factories directly and switches between them via `factory_type`.
-   Parameter surface / papermill inputs: `jaxcmr` and `lpp_ecmr` expose a broader parameter surface, including feature paths, component paths, free/fixed parameter dictionaries, and analysis config lists. The `cru_to_cmr` templates accept a narrower injected surface centered on `bounds`, `base_params`, `factory_type`, and a short `analysis_paths` list.
-   Outputs produced and output directory conventions: `jaxcmr` writes to `fits`, `figures/fitting`, and `simulations` beneath a configurable `target_directory`, plus a separate `figure_dir`/`figure_str` path for figure export. `lpp_ecmr` keeps the same three product directories but defaults `target_directory` to the project root. `cru_to_cmr` writes directly to `fits`, `figures/png`, `figures/tif`, and `simulations`.
-   Analysis hooks or downstream expectations: `jaxcmr` and `lpp_ecmr` support richer single-analysis and comparison-analysis config lists. `cru_to_cmr` expects a smaller benchmark set and resolves analyses from `analysis_paths`, typically SPC/CRP/PNR.

### Parameter shifting

Templates in this group:

-   `jaxcmr/templates/parameter_shifting.ipynb`
-   `lpp_ecmr/analyses/templates/parameter_shifting.ipynb`
-   `cru_to_cmr/analyses/templates/parameter_shifting.ipynb`

Behavioral comparison:

-   Data/model assumptions: `jaxcmr` and `lpp_ecmr` both wrap a fit-or-load workflow around a parameter sweep and then run benchmark analyses on the shifted simulations. The `cru_to_cmr` notebook is narrower: it assumes a pre-fit result file and performs only the parameter sweep and plotting stages.
-   Project-specific imports or factories: `jaxcmr` and `lpp_ecmr` resolve factories and algorithms through string parameters in the same general pattern as their fitting templates. `cru_to_cmr` imports the model factory from a single injected `model_factory_path` and does not expose the same generalized component-path surface.
-   Parameter surface / papermill inputs: `jaxcmr` and `lpp_ecmr` accept broad configuration dictionaries, analysis config lists, and run metadata. `lpp_ecmr` specializes the defaults for the TalmiEEG workflow. `cru_to_cmr` exposes a smaller sweep-specific surface: `varied_parameter`, `sweep_min`, `sweep_max`, `fit_result_name`, `model_factory_path`, and `analysis_paths`.
-   Outputs produced and output directory conventions: `jaxcmr` and `lpp_ecmr` write fits, figures under `figures/shifting`, and simulations beneath `target_directory`, while also supporting a separate `figure_dir`. `cru_to_cmr` writes figures directly from `target_directory` using per-analysis filenames and does not stage outputs in the same subdirectory layout.
-   Analysis hooks or downstream expectations: `jaxcmr` and `lpp_ecmr` support the same generalized comparison-analysis machinery used by their fitting templates. `cru_to_cmr` expects a fixed benchmark family and renders greyscale SPC/CRP/PNR figures from a simple `analysis_paths` list.

### LPP/category analyses

Templates in this group:

-   `lpp_ecmr/analyses/templates/cat_spc.ipynb`
-   `lpp_ecmr/analyses/templates/cat_lpp_spc.ipynb`
-   `lpp_ecmr/analyses/templates/cat_recall_by_lpp.ipynb`
-   `lpp_ecmr/analyses/templates/cat_lpp_by_recall.ipynb`

Behavioral comparison:

-   Data/model assumptions: All four notebooks operate on observed TalmiEEG data rather than on fitted model simulations. They are descriptive analysis templates rather than fit/simulate workflows.
-   Project-specific imports or factories: Each notebook imports a specialized analysis function from `jaxcmr.analyses` (for example `plot_cat_spc`, `plot_cat_lpp_spc`, `plot_cat_recall_by_lpp`, or `plot_cat_lpp_by_recall`) and wraps it in a small project-local template.
-   Parameter surface / papermill inputs: The shared surface centers on dataset name, trial query, category field or values, labels, colors, and an `output_path`. The LPP-specific notebooks add `lpp_field`; `cat_lpp_by_recall.ipynb` also varies `category_value`, `exclude_ci`, and contrast labels.
-   Outputs produced and output directory conventions: Each template writes a single figure to an explicit `output_path`. None of these notebooks manage fit caches or simulation directories.
-   Analysis hooks or downstream expectations: These notebooks are thin wrappers over specialized category/LPP analysis functions. They are closest in role to descriptive analysis notebooks in `jaxcmr/templates`, but there is no current one-to-one template peer for any of the four notebooks.

### Selective-interference sweep

Templates in this group:

-   `selective_interference/analyses/simulations/templates/interference_sweep.ipynb`

Behavioral summary:

-   Data/model assumptions: This notebook models a multi-phase selective-interference paradigm with film, break, reminder, interference, filler, and recall phases. It supports both scale sweeps and count sweeps and can load or refit parameters before sweeping.
-   Project-specific imports or factories: The notebook depends on a large project-local helper surface from the `selective_interference` package, including paradigm construction, cached sweep preparation, remapping utilities, and custom summary statistics.
-   Parameter surface / papermill inputs: The input surface is centered on paradigm geometry, cache boundaries, fixed and pre-cache parameter scales, sweep mode/value arrays, emotional flags, fit cache paths, and figure metadata.
-   Outputs produced and output directory conventions: The notebook can write summary CSV files and figure sidecars to `FIGURE_DIR` and can reuse or create fit caches beneath `FIT_DIR`.
-   Analysis hooks or downstream expectations: The downstream products are paradigm-specific SPC and summary-statistic views rather than the generic benchmark families used by the fitting and shifting templates.

## Unique Templates

Templates below have no direct current peer in another project template set.

### `jaxcmr`

| Notebook | Role |
|------------------------------------|------------------------------------|
| `backrepcrp.ipynb` | Repetition-centered backward-neighbour CRP analysis |
| `catcrp.ipynb` | Category-conditioned distance-binned CRP analysis |
| `compare_simulation_loss.ipynb` | Monte Carlo bag-likelihood inspection and loss diagnostics |
| `compound_cueing.ipynb` | Compound-cueing CRP analysis |
| `conditional_corec_by_cat.ipynb` | Conditional co-recall by category |
| `conditional_corec_by_lag.ipynb` | Conditional co-recall by lag |
| `context.ipynb` | Temporal context trajectory analysis |
| `crp.ipynb` | Lag-CRP analysis |
| `distcrp.ipynb` | Distance-conditioned CRP using embeddings |
| `intrusion_error_rate.ipynb` | Intrusion error-rate analysis |
| `joint_corec_by_lag.ipynb` | Joint co-recall by lag |
| `linear_memory.ipynb` | Linear-memory diagnostic |
| `log_odds_crp.ipynb` | Lag-CRP log-odds contrast analysis |
| `model_comparison.ipynb` | Fitted-model comparison and summary metrics |
| `nth_item_recall.ipynb` | Nth-item recall probability analysis |
| `omission_error_rate.ipynb` | Omission error-rate analysis |
| `order_error_rate.ipynb` | Order error-rate analysis |
| `pnr.ipynb` | Probability-of-nth-recall analysis |
| `relative_srac.ipynb` | Relative serial-recall accuracy analysis |
| `repcrp.ipynb` | Repetition-centered CRP with control comparison |
| `repneighborcrp.ipynb` | Repeated-item neighbour-transition analysis |
| `rpl.ipynb` | Recall probability by lag |
| `serialrepcrp.ipynb` | Serial repetition CRP analysis |
| `spc.ipynb` | Serial position curve analysis |
| `srac.ipynb` | Serial-recall accuracy analysis |
| `termination_probability.ipynb` | Recall termination-probability curve analysis |

### `lpp_ecmr`

| Notebook | Role |
|------------------------------------|------------------------------------|
| `cat_lpp_by_recall.ipynb` | Category-filtered LPP split by later recall status |
| `cat_lpp_spc.ipynb` | LPP amplitude by study position and category |
| `cat_recall_by_lpp.ipynb` | Recall rate by binned LPP amplitude and category |
| `cat_spc.ipynb` | Category-conditioned serial position curve |
| `cross_validation.ipynb` | Leave-one-list-out cross-validation fit/evaluate workflow |

### `selective_interference`

| Notebook | Role |
|------------------------------------|------------------------------------|
| `interference_sweep.ipynb` | Selective-interference paradigm sweep with cached phase execution |