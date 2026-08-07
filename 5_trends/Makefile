# 5_trends

.PHONY: all clean

# Trend plots use stamp file instead of individual paths
OUTPUTS = \
    output/series_vars.rds \
    output/state_series_vars.rds \
    output/dp_metrics_county_adj_normed.rds \
    output/fig_lm.png \
    output/fig_errorsarlm.png \
    output/tab_errorsarlm.tex \
    output/.trend_plots_built

# Metric tables depend on trend plots already being built
TABLE_OUTPUTS = \
    output/tab_metrics_body.tex \
    output/tab_metrics_appendix.tex

all: $(OUTPUTS) $(TABLE_OUTPUTS)

$(OUTPUTS) &: src/dp_trends.qmd ../.renv_restored
	quarto render src/dp_trends.qmd --output-dir .
	touch output/.trend_plots_built

$(TABLE_OUTPUTS) &: src/metric_tables.R output/.trend_plots_built ../.renv_restored
	Rscript src/metric_tables.R

../.renv_restored: ../renv.lock
	Rscript -e "renv::restore(project = '..', prompt = FALSE)"
	touch $@

clean:
	rm -f $(OUTPUTS) $(TABLE_OUTPUTS)
	rm -f dp_trends.html
	rm -rf src/dp_trends_cache src/dp_trends_files
	rm -rf output/trend_plots
	rm -f output/.trend_plots_built
