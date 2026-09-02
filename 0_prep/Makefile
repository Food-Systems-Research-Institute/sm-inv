# 0_prep

.PHONY: all clean

# Reads the two source Excel files in input/, builds dp_* objects used throughout
INPUTS = \
	input/secondary_metrics_revised.xlsx \
	input/literature_justifying_indicators.xlsx

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

$(OUTPUTS) &: src/excel_processing.R $(INPUTS) ../.renv_restored
	Rscript src/excel_processing.R

../.renv_restored: ../renv.lock
	Rscript -e "renv::restore(project = '..', prompt = FALSE)"
	touch $@

clean:
	rm -f $(OUTPUTS)
