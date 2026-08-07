# 0_prep

.PHONY: all clean

# Pulls Excel from OneDrive, builds dp_* objects used throughout
OUTPUTS = \
    output/dp_tree.rds \
    output/giant_table.xlsx

all: $(OUTPUTS)

$(OUTPUTS) &: src/excel_processing.R ../.renv_restored
	Rscript src/excel_processing.R

../.renv_restored: ../renv.lock
	Rscript -e "renv::restore(project = '..', prompt = FALSE)"
	touch $@

clean:
	rm -f $(OUTPUTS)
