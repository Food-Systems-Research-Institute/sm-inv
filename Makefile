# root

.PHONY: all site data clean

all: site

# Restore renv only when renv.lock changes
.renv_restored: renv.lock
	Rscript -e "renv::restore(project = '.', prompt = FALSE)"
	touch $@

# Build data/paper outputs from tasks with real outputs
data: .renv_restored
	$(MAKE) -C 3_coverage
	$(MAKE) -C 4_correlations
	$(MAKE) -C 5_trends

# Render full website
site: .renv_restored
	quarto render

clean:
	rm -rf _site
	$(MAKE) -C 1_intro clean
	$(MAKE) -C 2_eda clean
	$(MAKE) -C 3_coverage clean
	$(MAKE) -C 4_correlations clean
	$(MAKE) -C 5_trends clean
