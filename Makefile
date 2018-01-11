-include lib/borg/borg.mk

bootstrap-borg:
	@git submodule--helper clone --name borg --path lib/borg \
	--url git@github.com:emacscollective/borg.git
	@cd lib/borg; git symbolic-ref HEAD refs/heads/master
	@cd lib/borg; git reset --hard HEAD

# Abuse `SILENCIO` variable to tangle our init org file first
SILENCIO += -L lib/org --load org
SILENCIO += --eval '(org-babel-tangle-file (expand-file-name "init.org" user-emacs-directory))'

build-init:
	@rm -f init.elc
	@$(EMACS) -Q --batch -L lib/borg --load borg -L lib/org --load org \
        --eval '(org-babel-tangle-file (expand-file-name "init.org" user-emacs-directory))' \
	--funcall borg-initialize \
	--funcall borg-batch-rebuild-init 2>&1
