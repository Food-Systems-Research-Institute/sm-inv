# Inventory and Evaluation of Metrics

## Intro

This repository contains replication data for "Inventory and Evaluation of Metrics for a Sustainability Indicator Framework in the Northeast U.S. Food System". It also holds Quarto `.qmd` files for a notebook with analyses and visualizations.

## Running Project

This repository is set up with a structure for [Principled Data Processing](https://www.youtube.com/watch?v=ZSunU9GQdcI). Each numbered folder represents a task in the analysis process (e.g., eda, correlations, trends). Each task is rendered into its own [Quarto](https://quarto.org/) page. Each task also contains a Makefile which controls the processing for that step. More information on Makefiles can be found [here](https://makefiletutorial.com/).

To run the entire project, go to the root of the project, then:

```sh
make
```

This defaults to running `make all`.

Or, to run only a single page, use:

```sh
cd 3_coverage && make
```

To clear results and outputs, use:

```sh
make clean
```

Note that `4_trends` will take a few minutes. To avoid having to re-run this, we are using Quarto's freeze feature, which caches outputs in `_freeze/`. Cells will only re-run when code has changed. `make clean` will erase this as is expected to ensure that you get a clean, reproducible run. If you'd rather not lose this cache, but you do want to erase outputs in task folders, you can use `make mostlyclean` instead. This repo is shipped with the freeze cache intact for convenience, so remember to use `make clean` first to erase it.

To build the Quarto site:

```sh
make site
```

This renders to `_site/`. Note that rendering will used cached results where possible.

To produce manuscript outputs:

```sh
make paper
```


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

## Where things come from

- Metric table, among other inputs, is coming from `SMdocs::giant_table`. Edits need to be done there.
    - `excel_processing.R` creates giant table, used previously in SMdocs 
    - `giant_table_processing.R` uses `SMdocs::giant_table` previously
    - Now putting excel processing into 1_intro to set things up. giant table processing into 5_trends after we get graphs for it
    - Although there is so much in SMdocs maybe it isn't worth it. Also have `dp_tree` coming from there
- Many wrangling functions are coming from `SMdata`
- Note that we need to update our `SM_Data_Survey.bib`

## Notes and Issues

- Dropping `4_correlations/`