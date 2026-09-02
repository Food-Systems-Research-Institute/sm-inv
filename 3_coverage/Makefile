# 3_coverage

.PHONY: all clean

OUTPUTS = \
    output/tab_metric_breakdown.tex \
    output/fig_indicator_coverage.png \
    output/fig_metric_heatmap.png \
    output/abstract_indicator_data.csv \
    output/fig_indicator_heatmap.png

# Required upstream data
DP := ../0_prep/output
DP_INPUTS = \
	$(DP)/dp_meta.rds \
	$(DP)/dp_metrics.rds \
	$(DP)/dp_metrics_county.rds \
	$(DP)/dp_weights.rds

all: $(OUTPUTS)

$(OUTPUTS) &: src/dp_coverage.qmd input/neast_tiles.rds $(DP_INPUTS) ../.renv_restored
	quarto render src/dp_coverage.qmd --output-dir .

../.renv_restored: ../renv.lock
	Rscript -e "renv::restore(project = '..', prompt = FALSE)"
	touch $@

clean:
	rm -f $(OUTPUTS)
	rm -f dp_coverage.html
	rm -rf src/dp_coverage_cache src/dp_coverage_files
