# 3_coverage

.PHONY: all clean

OUTPUTS = \
    output/tab_metric_breakdown.tex \
    output/fig_indicator_coverage.png \
    output/fig_metric_heatmap.png \
    output/abstract_indicator_data.csv \
    output/fig_indicator_heatmap.png

all: $(OUTPUTS)

$(OUTPUTS) &: src/dp_coverage.qmd data/data_paper/neast_tiles.rds ../.renv_restored
	quarto render src/dp_coverage.qmd --output-dir .

../.renv_restored: ../renv.lock
	Rscript -e "renv::restore(project = '..', prompt = FALSE)"
	touch $@

clean:
	rm -f $(OUTPUTS)
	rm -f dp_coverage.html
	rm -rf src/dp_coverage_cache src/dp_coverage_files
