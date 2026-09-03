.PHONY: all site paper prep coverage trends tables clean distclean
.DELETE_ON_ERROR:

all: site

# renv ------------------------- 
.renv_restored: renv.lock
	Rscript -e "renv::restore(prompt = FALSE)"
	@touch $@

# 0_prep ------------------------- 
PREP_SRC := 0_prep/src/excel_processing.R
PREP_IN := 0_prep/input/secondary_metrics_revised.xlsx \
	0_prep/input/literature_justifying_indicators.xlsx
PREP_OUT := $(addprefix 0_prep/output/,\
	dp_tree.rds giant_table.xlsx dp_meta.rds dp_metrics.rds \
	dp_metrics_county.rds dp_metrics_county_adj.rds \
	dp_metrics_county_wide.rds dp_metrics_state.rds \
	dp_metrics_state_adj.rds dp_weight_vars.rds dp_weights.rds)

$(PREP_OUT) &: $(PREP_SRC) $(PREP_IN) .renv_restored
	Rscript $(PREP_SRC)

prep: $(PREP_OUT)

# 3_coverage ------------------------- 
COV_SRC := 3_coverage/src/dp_coverage.qmd
COV_IN  := 3_coverage/input/neast_tiles.rds \
           0_prep/output/dp_meta.rds 0_prep/output/dp_metrics.rds \
           0_prep/output/dp_metrics_county.rds 0_prep/output/dp_weights.rds
COV_OUT := $(addprefix 3_coverage/output/,\
             tab_metric_breakdown.tex fig_indicator_coverage.png \
             fig_metric_heatmap.png fig_indicator_heatmap.png \
             abstract_indicator_data.csv)

$(COV_OUT) &: $(COV_SRC) $(COV_IN) .renv_restored
	cd 3_coverage && quarto render src/dp_coverage.qmd --output-dir .

coverage: $(COV_OUT)

# 4_trends part one - wrangling, analyses, figures ------------------------- 
TR_SRC := 4_trends/src/dp_trends.qmd
TR_IN  := 0_prep/output/dp_meta.rds 0_prep/output/dp_weights.rds \
          0_prep/output/dp_metrics_county_adj.rds \
          0_prep/output/dp_metrics_state_adj.rds
TR_OUT := $(addprefix 4_trends/output/,\
            series_vars.rds state_series_vars.rds \
            dp_metrics_county_adj_normed.rds fig_errorsarlm.png \
            tab_errorsarlm.tex .trend_plots_built)

$(TR_OUT) &: $(TR_SRC) $(TR_IN) .renv_restored
	cd 4_trends && quarto render src/dp_trends.qmd --output-dir .
	@touch 4_trends/output/.trend_plots_built

trends: $(TR_OUT)

# 4_trends part two - tables ------------------------- 
TAB_SRC := 4_trends/src/metric_tables.R
TAB_IN  := 4_trends/output/.trend_plots_built 0_prep/output/dp_meta.rds \
           assets/sm_data_survey_full.bib
TAB_OUT := 4_trends/output/tab_metrics_body.tex \
           4_trends/output/tab_metrics_appendix.tex

$(TAB_OUT) &: $(TAB_SRC) $(TAB_IN) .renv_restored
	Rscript $(TAB_SRC)

tables: $(TAB_OUT)

# quarto site ------------------------- 
site: $(PREP_OUT) $(COV_OUT) $(TR_OUT) $(TAB_OUT)
	quarto render

# Paper outputs ------------------------- 
PAPER_DIR := paper
PAPER_SRC := 3_coverage/output/tab_metric_breakdown.tex \
             3_coverage/output/fig_indicator_coverage.png \
             3_coverage/output/fig_metric_heatmap.png \
             4_trends/output/fig_errorsarlm.png \
             4_trends/output/tab_errorsarlm.tex \
             4_trends/output/tab_metrics_body.tex \
             4_trends/output/tab_metrics_appendix.tex

paper: $(PAPER_SRC) $(TR_OUT)
	@ls 4_trends/output/trend_plots/*.png >/dev/null 2>&1 || \
	  { echo "paper: no trend plots (try: make clean && make trends)"; exit 1; }
	rm -rf $(PAPER_DIR) && mkdir -p $(PAPER_DIR)
	cp $(PAPER_SRC) $(PAPER_DIR)/
	cp 4_trends/output/trend_plots/*.png $(PAPER_DIR)/
	cd $(PAPER_DIR) && zip -qr ../paper_assets.zip .
	@echo "\n*** $(PAPER_DIR)/ dir is ready. Outputs are zipped into paper_assets.zip ***"

# ---- cleaning --------------------------------------------------
clean:
	rm -f  $(PREP_OUT) $(COV_OUT) $(TR_OUT) $(TAB_OUT)
	rm -rf 4_trends/output/trend_plots
	rm -rf $(PAPER_DIR) paper_assets.zip _site
	rm -f  1_intro/src/*.html 2_eda/src/*.html \
	       3_coverage/src/*.html 4_trends/src/*.html
	rm -rf */src/*_files */src/*_cache

distclean: clean
	rm -rf _freeze
	rm -f  .renv_restored
