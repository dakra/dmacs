-include lib/borg/borg.mk

bootstrap-borg:
	@git submodule--helper clone --name borg --path lib/borg \
	--url git@github.com:emacscollective/borg.git
	@cd lib/borg; git symbolic-ref HEAD refs/heads/master
	@cd lib/borg; git reset --hard HEAD

tangle-init:
	@rm -f init.el
	@$(EMACS) -Q --batch --load org \
	--eval '(org-babel-tangle-file (expand-file-name "init.org" user-emacs-directory))' 2>&1

build: tangle-init
build-init: tangle-init
quick: tangle-init
