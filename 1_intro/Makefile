.PHONY: render clean

render: ../.renv_restored
	quarto render src/dp_intro.qmd --output-dir .

../.renv_restored: ../renv.lock
	Rscript -e "renv::restore(project = '..', prompt = FALSE)"
	touch $@

clean:
	rm -f dp_intro.html
	rm -rf src/dp_intro_cache src/dp_intro_files
	rm -rf dp_intro_cache dp_intro_files
