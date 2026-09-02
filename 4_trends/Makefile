# 4_trends

.PHONY: all clean

# Trend plots use stamp file instead of individual paths
OUTPUTS = \
    output/series_vars.rds \
    output/state_series_vars.rds \
    output/dp_metrics_county_adj_normed.rds \
    output/fig_errorsarlm.png \
    output/tab_errorsarlm.tex \
    output/.trend_plots_built

# Metric tables depend on trend plots already being built
TABLE_OUTPUTS = \
    output/tab_metrics_body.tex \
    output/tab_metrics_appendix.tex

# Upstream data these read (see readRDS calls in src/dp_trends.qmd and
# metric_tables.R). metric_tables.R also reads the bibliography.
DP := ../0_prep/output
DP_INPUTS = \
	$(DP)/dp_meta.rds \
	$(DP)/dp_weights.rds \
	$(DP)/dp_metrics_county_adj.rds \
	$(DP)/dp_metrics_state_adj.rds
BIB := ../assets/sm_data_survey_full.bib

all: $(OUTPUTS) $(TABLE_OUTPUTS)

$(OUTPUTS) &: src/dp_trends.qmd $(DP_INPUTS) ../.renv_restored
	quarto render src/dp_trends.qmd --output-dir .
	touch output/.trend_plots_built

# metric_tables.R runs from root dir
$(TABLE_OUTPUTS) &: src/metric_tables.R output/.trend_plots_built $(DP)/dp_meta.rds $(BIB) ../.renv_restored
	cd .. && Rscript 4_trends/src/metric_tables.R

../.renv_restored: ../renv.lock
	Rscript -e "renv::restore(project = '..', prompt = FALSE)"
	touch $@

clean:
	rm -f $(OUTPUTS) $(TABLE_OUTPUTS)
	rm -f dp_trends.html
	rm -rf src/dp_trends_cache src/dp_trends_files
	rm -rf output/trend_plots
	rm -f output/.trend_plots_built
