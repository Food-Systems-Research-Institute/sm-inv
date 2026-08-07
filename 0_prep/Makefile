# 0_prep

.PHONY: all clean

# Pulls Excel from OneDrive, builds dp_* objects used throughout
OUTPUTS = \
    output/dp_tree.rds \
    output/giant_table.xlsx \
	output/dp_meta.rds \
	output/dp_metrics.rds \
	output/dp_metrics_county.rds \
	output/dp_metrics_county_adj.rds \
	output/dp_metrics_county_wide.rds \
	output/dp_metrics_state.rds \
	output/dp_metrics_state_adj.rds \
	output/dp_weight_vars.rds \
	output/dp_weights.rds

all: $(OUTPUTS)

$(OUTPUTS) &: src/excel_processing.R ../.renv_restored
	Rscript src/excel_processing.R

../.renv_restored: ../renv.lock
	Rscript -e "renv::restore(project = '..', prompt = FALSE)"
	touch $@

clean:
	rm -f $(OUTPUTS)
