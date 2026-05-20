# Inventory and Evaluation of Metrics

## Intro

This repository contains replication data for "Inventory and Evaluation of Metrics for a Sustainability Indicator Framework in the Northeast U.S. Food System". It also holds Quarto `.qmd` files for a notebook with analyses and visualizations.

## Running Project

This repository is set up with a structure for [Principled Data Processing](https://www.youtube.com/watch?v=ZSunU9GQdcI). Each numbered folder represents a task in the analysis process (e.g., eda, correlations, trends). Each task is rendered into its own [Quarto](https://quarto.org/) page. Each task also contains a Makefile which controls the processing for that step. More information on Makefiles can be found [here](https://makefiletutorial.com/).

To run the entire project, go to the root of the project, then:

```sh
make
```

Or, to run only a single page, use:

```sh
cd 3_coverage && make
```

To clear results and outputs, use:

```sh
make clean
```

Note that `5_trends` will take ~20 minutes to run. To avoid having to re-run this, we are using Quarto's freeze feature, which caches outputs in `_freeze/`. Cells will only re-run when code has changed. `make clean` will erase this as is expected to ensure that you get a clean, reproducible run. If you'd rather not lose this cache, but you do want to erase outputs in task folders, you can use `make mostlyclean` instead. This repo is shipped with the freeze cache intact for convenience, so remember to use `make clean` first to erase it.

## Structure

Each task contains the following files and folders :

- `src/`: Quarto markdown (`.qmd`) files with R code and text that run that step of the analysis and render a website page.
- `input/`: Any required inputs for that task
- `output/`: Outputs saved to file.
- `Makefile`: Instructions to run the given task

Other files and folders in root:

- `_site/`: HTML files to render Quarto website
- `_freeze/`: Cached results from tasks
- `assets/`: Style sheets and `.bib` files
- `_quarto.yml`: Quarto configuration and formatting
