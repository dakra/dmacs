-include lib/borg/borg.mk

bootstrap-borg:
	@git submodule--helper clone --name borg --path lib/borg \
	--url git@github.com:emacscollective/borg.git
	@cd lib/borg; git symbolic-ref HEAD refs/heads/master
	@cd lib/borg; git reset --hard HEAD

build: init-tangle
native: init-tangle
init-build: init-tangle
quick: init-tangle
