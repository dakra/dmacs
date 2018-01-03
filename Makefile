# Copyright (C) 2016-2017  Jonas Bernoulli
#
# Author: Jonas Bernoulli <jonas@bernoul.li>
# License: GPL v3 <https://www.gnu.org/licenses/gpl-3.0.txt>

EMACS ?= emacs

.PHONY: all help build build-init quick bootstrap clean
.FORCE:

all: build

SILENCIO  = --load subr-x
SILENCIO += --eval "(put 'if-let 'byte-obsolete-info nil)"
SILENCIO += --eval "(put 'when-let 'byte-obsolete-info nil)"
SILENCIO += --eval "(fset 'original-message (symbol-function 'message))"
SILENCIO += --eval "(fset 'message\
(lambda (format &rest args)\
  (unless (equal format \"pcase-memoize: equal first branch, yet different\")\
    (apply 'original-message format args))))"

help:
	$(info )
	$(info make [all|build]    = rebuild all drones and init files)
	$(info make quick          = rebuild most drones and init files)
	$(info make lib/DRONE      = rebuild DRONE)
	$(info make build-init     = rebuild init files)
	$(info make bootstrap      = bootstrap collective or new drones)
	$(info make clean          = remove all *.elc and *-autoloads.el)
	@printf "\n"

build:
	@rm -f init.elc
	@$(EMACS) -Q --batch -L lib/borg --load borg -L lib/org-mode --load org $(SILENCIO) \
        --eval '(org-babel-tangle-file (expand-file-name "init.org" user-emacs-directory))' \
	--funcall borg-initialize \
	--funcall borg-batch-rebuild 2>&1

build-init:
	@rm -f init.elc
	@$(EMACS) -Q --batch -L lib/borg --load borg -L lib/org-mode --load org \
        --eval '(org-babel-tangle-file (expand-file-name "init.org" user-emacs-directory))' \
	--funcall borg-initialize \
	--funcall borg-batch-rebuild-init 2>&1

quick:
	@rm -f init.elc
	@$(EMACS) -Q --batch -L lib/borg --load borg $(SILENCIO) \
	--funcall borg-initialize \
	--eval  '(borg-batch-rebuild t)' 2>&1

lib/%: .FORCE
	@$(EMACS) -Q --batch -L lib/borg --load borg $(SILENCIO) \
	--funcall borg-initialize \
	--eval  '(borg-build "$(@F)")' 2>&1

bootstrap:
	@printf "\n=== Running 'git submodule init' ===\n\n"
	@git submodule init
	@printf "\n=== Running 'bin/borg-bootstrap' ===\n"
	@bin/borg-bootstrap
	@printf "\n=== Running 'make build' ===\n\n"
	@make build

clean:
	@find lib -name '*-autoloads.el' -exec rm '{}' ';'
	@find lib -name '*.elc' -exec rm '{}' ';'
	@rm -f init.elc
