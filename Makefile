# root

.PHONY: all site data mostlyclean clean paper

# make defaults to make all
all: site

# Restore renv only when renv.lock changes. $@ is target name
.renv_restored: renv.lock
	Rscript -e "renv::restore(project = '.', prompt = FALSE)"
	touch $@

# Convenience - only render pages with actual outputs
data: .renv_restored
	$(MAKE) -C 0_prep
	$(MAKE) -C 3_coverage
	$(MAKE) -C 4_trends

# Render full website, executing chunks unless cached found in _freeze
site: data
	quarto render

# Gather manuscript figures and table into one dir for Overleaf
PAPER_DIR := paper
PAPER_SRC := \
	3_coverage/output/tab_metric_breakdown.tex \
	3_coverage/output/fig_indicator_coverage.png \
	3_coverage/output/fig_metric_heatmap.png \
	4_trends/output/fig_errorsarlm.png \
	4_trends/output/tab_errorsarlm.tex \
	4_trends/output/tab_metrics_body.tex \
	4_trends/output/tab_metrics_appendix.tex

paper: .renv_restored
	$(MAKE) -C 0_prep
	$(MAKE) -C 3_coverage
	$(MAKE) -C 4_trends
	@for f in $(PAPER_SRC); do \
	  test -f "$$f" || { echo "paper: missing $$f (try: make -C $${f%%/*} clean && make paper)"; exit 1; }; \
	done
	@ls 4_trends/output/trend_plots/*.png >/dev/null 2>&1 || \
	  { echo "paper: no trend plots (try: make -C 4_trends clean && make paper)"; exit 1; }
	rm -rf $(PAPER_DIR) && mkdir -p $(PAPER_DIR)
	cp $(PAPER_SRC) $(PAPER_DIR)/
	cp 4_trends/output/trend_plots/*.png $(PAPER_DIR)/
	cd $(PAPER_DIR) && zip -qr ../paper_assets.zip .
	@echo "==> $(PAPER_DIR)/ ready ($$(ls $(PAPER_DIR) | wc -l) files); paper_assets.zip written"

# Remove outputs, but keep _freeze intact. Quarto only re-renders when code changes
mostlyclean:
	rm -rf _site
	rm -rf $(PAPER_DIR) paper_assets.zip
	$(MAKE) -C 0_prep clean
	$(MAKE) -C 1_intro clean
	$(MAKE) -C 2_eda clean
	$(MAKE) -C 3_coverage clean
	$(MAKE) -C 4_trends clean

# Run mostlyclean and remove _freeze. This is a hard reset
clean: mostlyclean
	rm -rf _freeze
