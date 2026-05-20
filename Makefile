# root

.PHONY: all site data clean distclean

all: site

# Restore renv only when renv.lock changes. $@ is target name
.renv_restored: renv.lock
	Rscript -e "renv::restore(project = '.', prompt = FALSE)"
	touch $@ 

# Convenience - only render pages with actual outputs
data: .renv_restored
	$(MAKE) -C 3_coverage
	$(MAKE) -C 4_correlations
	$(MAKE) -C 5_trends

# Render full website, executing chunks unless cached found in _freeze
site: .renv_restored
	quarto render

# Remove outputs, but keep _freeze intact. Quarto only re-renders when code changes
mostlyclean: 
	rm -rf _site
	$(MAKE) -C 1_intro clean
	$(MAKE) -C 2_eda clean
	$(MAKE) -C 3_coverage clean
	$(MAKE) -C 4_correlations clean
	$(MAKE) -C 5_trends clean

# Run mostlyclean and remove _freeze. This is a hard reset
clean: mostlyclean
	rm -rf _freeze
