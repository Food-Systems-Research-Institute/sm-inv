# 4_correlations

.PHONY: all clean

OUTPUTS = \
	output/fig_corplot.png \
    output/tab_correlations.tex

all: $(OUTPUTS)

$(OUTPUTS) &: src/dp_correlations.qmd ../.renv_restored
	quarto render src/dp_correlations.qmd --output-dir .

../.renv_restored: ../renv.lock
	Rscript -e "renv::restore(project = '..', prompt = FALSE)"
	touch $@

clean:
	rm -f $(OUTPUTS)
	rm -f dp_correlations.html
	rm -rf src/dp_correlations_cache src/dp_correlations_files
