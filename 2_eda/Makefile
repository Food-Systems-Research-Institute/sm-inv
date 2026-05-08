.PHONY: render clean

render: ../.renv_restored
	quarto render src/dp_eda.qmd --output-dir .

../.renv_restored: ../renv.lock
	Rscript -e "renv::restore(project = '..', prompt = FALSE)"
	touch $@

clean:
	rm -f dp_eda.html
	rm -rf src/dp_eda_cache src/dp_eda_files
	rm -rf dp_eda_cache dp_eda_files
