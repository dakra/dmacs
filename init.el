;;; init.el --- user-init-file                    -*- lexical-binding: t -*-

(defvar before-user-init-time (current-time)
  "Value of `current-time' when Emacs begins loading `user-init-file'.")

(message "Loading Emacs...done (%.3fs)"
         (float-time (time-subtract before-user-init-time
                                    before-init-time)))

(setq use-package-enable-imenu-support t)
(require 'use-package)

;; * Initialize borg
(add-to-list 'load-path (expand-file-name "lib/borg" user-emacs-directory))
(require 'borg)
(borg-initialize)



(use-package no-littering
  :demand t
  :config
  (setq server-auth-dir (no-littering-expand-var-file-name "server"))
  ;; /etc is version controlled and I want to store mc-lists in git
  (setq mc/list-file (no-littering-expand-etc-file-name "mc-list.el"))
  ;; Put the auto-save and backup files in the var directory to the other data files
  (no-littering-theme-backups))

;; Load personal config that shouldn't end up on github
(load-file (expand-file-name "personal.el" user-emacs-directory))

(use-package emacs
  :config
  ;; ;; Compile loaded .elc files asynchronously
  ;; (setq natiqve-comp-jit-compilation t)
  ;; (if (eq system-type 'windows-nt)
  ;;     (setq native-comp-async-jobs-number 4))

  (setq use-default-font-for-symbols)
  ;; (add-to-list 'default-frame-alist '(font . "Fira Code-12:weight=regular:width=normal"))
  ;; (set-frame-font "Fira Code-12:weight=regular:width=normal" nil t)

  ;; (add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font-12:weight=regular:width=normal"))
  ;; (set-frame-font "FiraCode Nerd Font-12:weight=regular:width=normal" nil t)

  (add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font Mono Julia-12:weight=regular:width=normal"))
  (set-frame-font "FiraCode Nerd Font Mono Julia-12:weight=regular:width=normal" nil t)

  (unless (eq system-type 'darwin)
    (set-fontset-font t 'emoji (font-spec :family "Segoe UI Emoji") nil 'append))

  (prefer-coding-system 'utf-8)

  ;; Always just use left-to-right text. This makes Emacs a bit faster for very long lines
  (setq-default bidi-paragraph-direction 'left-to-right)

  (setq-default indent-tabs-mode nil)  ;; Don't use tabs to indent
  (setq-default tab-width 4)

  (setq tab-always-indent 'complete)  ;; smart tab behavior - indent or complete
  (setq require-final-newline t)  ;; Newline at end of file
  (setq mouse-yank-at-point t)  ;; Paste with middle mouse button doesn't move the cursor
  (delete-selection-mode t)  ;; Delete the selection with a keypress
  (setq auth-source-save-behavior nil)  ;; Don't ask to store credentials in .authinfo.gpg
  (setq truncate-string-ellipsis "…")  ;; Use 'fancy' ellipses for truncated strings

  ;; Increase the limit to catch infinite recursions.
  ;; Large scala files need sometimes more and this value can safely be increased.
  (setq max-lisp-eval-depth 32768)

  ;; Focus follows mouse for Emacs windows and frames
  (setq mouse-autoselect-window t)
  (setq focus-follows-mouse t)

  ;; Activate character folding in searches i.e. searching for 'a' matches 'ä' as well
  (setq search-default-mode 'char-fold-to-regexp)

  ;; Only split horizontally if there are at least 100 chars column after splitting
  (setq split-width-threshold 200)
  ;; Only split vertically on very tall screens
  (setq split-height-threshold 150)

  ;; When (un-)splitting windows, resize all windows in the frame
  (setq window-combination-resize t)

  ;; Save whatever’s in the current (system) clipboard before
  ;; replacing it with the Emacs’ text.
  (setq save-interprogram-paste-before-kill t)

  ;; Accept 'UTF-8' (uppercase) as a valid encoding in the coding header
  (define-coding-system-alias 'UTF-8 'utf-8)

  ;; Increase the amount of data which Emacs reads from the process
  ;; (Useful for LSP where the LSP responses are in the 800k - 3M range)
  (setq read-process-output-max (* 1024 1024)) ;; 1mb

  ;; Allow some commands as safe by default
  ;; allow horizontal scrolling with "M-x >"
  (put 'scroll-left 'disabled nil)
  ;; enable narrowing commands
  (put 'narrow-to-region 'disabled nil)
  (put 'narrow-to-page 'disabled nil)
  (put 'narrow-to-defun 'disabled nil)
  ;; enabled change region case commands
  (put 'upcase-region 'disabled nil)
  (put 'downcase-region 'disabled nil)
  ;; enable erase-buffer command
  (put 'erase-buffer 'disabled nil)

  ;; Enable y/n answers
  (fset 'yes-or-no-p 'y-or-n-p)

  ;; Disable blinking cursor and the bell ring
  (blink-cursor-mode -1)

  (setq ring-bell-function 'ignore
        create-lockfiles nil   ;; disable lock file symlinks
        make-backup-files t    ;; backup of a file the first time it is saved.
        backup-by-copying t    ;; don't clobber symlinks
        version-control t      ;; version numbers for backup files
        delete-old-versions t  ;; delete excess backup files silently
        kept-old-versions 6    ;; oldest versions to keep when a new numbered backup is made
        kept-new-versions 9)   ;; newest versions to keep when a new numbered backup is made

  ;; Don't quit Emacs on C-x C-c
  (when (daemonp)
    (global-set-key (kbd "C-x C-c") 'kill-buffer-and-window))

  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Support opening new minibuffers from inside existing minibuffers.
  (setq enable-recursive-minibuffers t)

  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond Vertico.
  (setq read-extended-command-predicate #'command-completion-default-include-p))

(use-package moe-theme
  :demand t
  :unless noninteractive
  :config (load-theme 'moe-dark t))

(use-package simple
  :bind (("C-/"   . undo-only)
         ("C-z"   . undo-only)
         ("C-S-z" . undo-redo)
         ("C-?"   . undo-redo)
         ("C-a"   . move-beginning-of-line-or-indentation)
         ("C-x k" . kill-current-buffer)
         ("M-u"   . dakra-upcase-dwim)
         ("M-l"   . dakra-downcase-dwim)
         ("M-c"   . dakra-capitalize-dwim))
  :hook (((mu4e-compose-mode markdown-mode rst-mode git-commit-setup) . text-mode-autofill-setup)
         ((visual-fill-column-mode markdown-mode) . word-wrap-whitespace-mode))
  :config
  ;; mode line settings
  (line-number-mode t)
  (column-number-mode t)
  (size-indication-mode t)

  (defun move-beginning-of-line-or-indentation ()
    "Move to beginning of line or indentation."
    (interactive)
    (let ((orig-point (point)))
      (back-to-indentation)
      (when (= orig-point (point))
        (beginning-of-line))))

  ;; Hide commands in M-x which do not apply to the current mode.
  (setq read-extended-command-predicate #'command-completion-default-include-p)

  (defun text-mode-autofill-setup ()
    "Set fill-column to 68 and turn on auto-fill-mode."
    (setq-local fill-column 80)
    (auto-fill-mode))

  ;; Increase autofill (e.g. M-x autofill-paragraph or M-q) (default 70 chars)
  (setq-default fill-column 90)

  (require 'thingatpt)
  (defun dakra-upcase-dwim (arg)
    "Like `upcase-dwim' but upcase from beginning when no region is active."
    (interactive "*p")
    (save-excursion
      (if (use-region-p)
          (upcase-region (region-beginning) (region-end))
        (beginning-of-thing 'symbol)
        (upcase-word arg))))

  (defun dakra-downcase-dwim (arg)
    "Like `downcase-dwim' but downcase from beginning when no region is active."
    (interactive "*p")
    (save-excursion
      (if (use-region-p)
          (downcase-region (region-beginning) (region-end))
        (beginning-of-thing 'symbol)
        (downcase-word arg))))

  (defun dakra-capitalize-dwim (arg)
    "Like `capitalize-dwim' but Capitalize from beginning when no region is active."
    (interactive "*p")
    (save-excursion
      (if (use-region-p)
          (capitalize-region (region-beginning) (region-end))
        (beginning-of-thing 'symbol)
        (capitalize-word arg)))))

;; So-long: Mitigating slowness due to extremely long lines
(use-package so-long
  :defer 5
  :config
  (global-so-long-mode))

(use-package help
  :config (setq help-window-select t))

(use-package compile
  :config
  (setq compilation-environment '("TERM=xterm-256color")
        compilation-ask-about-save nil  ;; Always save before compiling
        compilation-always-kill t  ;; Kill old compile processes before starting a new one
        compilation-scroll-output t))  ;; Scroll with the compilation output

(use-package ansi-color
  :hook (compilation-filter . ansi-color-compilation-filter))

(use-package treesit
  :defer t
  :config
  ;; Download the pre-build grammars from https://github.com/emacs-tree-sitter/tree-sitter-langs/releases
  ;; Place them in `treesit-extra-load-path' and rename them with a libtree-sitter-<LANG> prefix.
  ;; E.g. in bash something like `for i in *.*; do mv $i libtree-sitter-$i; done'
  ;; For MacOS you may have to remove the apple quarantine flag with `xattr -d com.apple.quarantine <file>`
  ;; For all in the folder: for i in *; do xattr -d com.apple.quarantine $i; done
  (setq treesit-extra-load-path
        (list (no-littering-expand-var-file-name (concat "tree-sitter-grammars/"
                                                         (symbol-name system-type))))))

(use-package subword
  :hook ((python-mode yaml-ts-mode conf-mode go-mode go-ts-mode clojure-mode cider-repl-mode
                      java-mode java-ts-mode cds-mode js-mode js-ts-mode) . subword-mode))

(use-package epa
  :defer t
  :config
  ;; Always replace encrypted text with plain text version
  (setq epa-replace-original-text t))

(use-package epg
  :defer t
  :config
  ;; Let Emacs query the passphrase through the minibuffer
  (setq epg-pinentry-mode 'loopback))

;; highlight the current line
(use-package hl-line
  :unless noninteractive
  :hook (after-init . global-hl-line-mode))

(use-package abbrev
  :hook (text-mode . abbrev-mode)
  ;; :hook ((message-mode org-mode markdown-mode rst-mode) . abbrev-mode)
  :config
  ;; Don't ask to save abbrevs when saving all buffers
  (setq save-abbrevs 'silently)
  ;; I want abbrev saved in my config/version control and not in the var folder
  (setq abbrev-file-name (no-littering-expand-etc-file-name "abbrev.el")))

;; Saveplace: Remember your location in a file
(use-package saveplace
  :unless noninteractive
  :hook (after-init . save-place-mode)
  :config
  (setq save-place-limit 1000))

(use-package repeat
  :unless noninteractive
  :hook (after-init . repeat-mode))

;; Savehist: Keep track of minibuffer history
(use-package savehist
  :unless noninteractive
  :hook (after-init . savehist-mode)
  :config
  (setq savehist-additional-variables
        '(compile-command kill-ring search-ring regexp-search-ring corfu-history)))

(use-package hippie-exp
  :bind (("M-/" . hippie-expand)))

(use-package editorconfig
  :defer t
  :config
  (setq editorconfig-trim-whitespaces-mode 'ws-butler-mode))

(use-package envrc
  :hook (after-init . envrc-global-mode))

(use-package recentf
  :hook (after-init . recentf-mode)
  :config
  (add-to-list 'recentf-exclude "^/\\(?:ssh\\|su\\|sudo\\)?:")
  (add-to-list 'recentf-exclude no-littering-var-directory)

  (setq recentf-max-saved-items 500
        recentf-max-menu-items 15
        ;; disable recentf-cleanup on Emacs start, because it can cause
        ;; problems with remote files
        recentf-auto-cleanup 'never))

(use-package hideshow
  :hook (prog-mode . hs-minor-mode)
  :bind (:map hs-minor-mode-map
              ([C-tab] . hs-toggle-hiding))
  :config
  (setq hs-allow-nesting t))

(use-package bookmark
  :defer t
  :config
  ;; Hide all the fringe bookmarks as dogears uses bookmarks
  (setq bookmark-fringe-mark nil))

(use-package dumb-jump
  :bind (("M-g o" . xref-find-definitions-other-window)
         ("M-g j" . xref-find-definitions)
         ("M-g p" . xref-go-back))
  :init
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  :config
  (setq dumb-jump-selector 'completing-read))

(use-package gumshoe
  :hook (after-init . global-gumshoe-mode)
  :bind (("C-x SPC" . gumshoe-backtrack)
         ("C-x C-SPC" . gumshoe-buf-backtrack)
         ("C-x M-SPC" . global-gumshoe-backtracking-mode-forward)
         :map global-gumshoe-backtracking-mode-map
         ("p" . global-gumshoe-backtracking-mode-back)
         ("n" . global-gumshoe-backtracking-mode-forward)
         ("SPC" . global-gumshoe-backtracking-mode-back)
         ("C-SPC" . global-gumshoe-backtracking-mode-forward))
  :config
  (setq gumshoe-ignored-major-modes
        '( fundamental-mode minibuffer-mode treemacs-mode
           vterm-mode eat-mode compilation-mode eshell-mode shell-mode term-mode comint-mode
           magit-process-mode magit-status-mode magit-log-mode magit-diff-mode magit-blame-mode
           xwidget-webkit-mode)))

(use-package consult-gumshoe
  :after (gumshoe consult))

;;(use-package dogears
;;  :hook (after-init . dogears-mode)
;;  :bind (("C-x SPC" . dogears-go)
;;         ("C-x C-SPC" . dogears-back)
;;         ("C-x M-SPC" . dogears-forward))
;;  :config
;;  (setq dogears-idle 3))

(use-package proced
  :bind ("C-x p" . proced)
  :config
  (add-to-list 'proced-filter-alist '(java (comm . "java")))
  (setq-default proced-filter 'user-running)
  (setq proced-format 'medium)
  (setq proced-tree-flag t))

(use-package display-fill-column-indicator
  :hook ((git-commit-setup) . display-fill-column-indicator-mode))

(use-package winner
  :hook (after-init . winner-mode))

(use-package xwidget
  :bind (:map xwidget-webkit-mode-map
              ("n" . xwidget-webkit-scroll-up-line)
              ("p" . xwidget-webkit-scroll-down-line)
              ("q" . kill-current-buffer)
              ("Q" . quit-window))
  :config
  ;; Don't ask if I want to kill a xwidget buffer
  (remove-hook 'kill-buffer-query-functions #'xwidget-kill-buffer-query-function)
  ;; Slightly short buffer name
  (setq xwidget-webkit-buffer-name-format "*xwidget: %T*"))

(use-package browse-url
  :bind (("C-c u" . browse-url-at-point))
  :commands (dakra-toggle-browser)
  :config
  (defun dakra-toggle-browser ()
    "Toggle browser function between eww and Firefox."
    (interactive)
    (if (eq browse-url-browser-function 'eww-browse-url)
        (progn
          (setq browse-url-browser-function 'browse-url-firefox)
          (message "Setting browser to Firefox"))
      (setq browse-url-browser-function 'eww-browse-url)
      (message "Setting browser to eww"))))

(use-package eldoc
  :hook (prog-mode . eldoc-mode)
  :config
  (eldoc-add-command-completions "sp-" "paredit-"))

(use-package ibuffer
  :bind ("C-x C-b" . ibuffer))

(use-package project
  :bind-keymap (("s-p"   . project-prefix-map)  ; projectile-command-map
                ("C-c p" . project-prefix-map))
  :bind (("C-x C-x" . consult-project-extra-find)
         :map project-prefix-map
         ("SPC" . consult-project-extra-find)
         ("B"   . babashka-find-project-file)
         ("d"   . project-dired)
         ("D"   . project-edit-deps-edn)
         ("t"   . project-toggle-test)
         ("s"   . consult-ripgrep)
         ("E"   . project-edit-dir-locals)
         ("P"   . project-run-python))
  :config
  ;; Ignore clj-kondo and cljs-runtime folder by default
  (setq project-vc-ignores '(".clj-kondo/" "cljs-runtime/"))

  (defun project-edit-dir-locals ()
    "Open buffer with .dir-locals.el for current project."
    (interactive)
    (thread-last (project-current)
                 (project-root)
                 (expand-file-name ".dir-locals.el")
                 (find-file)))

  (defun project-edit-deps-edn ()
    "Open buffer with deps.edn for current project."
    (interactive)
    (thread-last (project-current)
                 (project-root)
                 (expand-file-name "deps.edn")
                 (find-file)))

  (defun project-toggle-test ()
    "Toggle between source and test buffers."
    (interactive)
    (let* ((root (project-root (project-current t)))
           (fn (file-relative-name (buffer-file-name) root))
           (main-src (if (derived-mode-p 'java-mode) "/main" "/src"))
           (test-suffix (if (derived-mode-p 'java-mode) "Test" "_test"))
           (test-p (s-contains-p "test" fn))
           (dir (file-name-directory fn))
           (base (file-name-base fn))
           (ext (file-name-extension fn))
           (toggle-dir (if test-p
                           (replace-regexp-in-string "/test" "/main" dir)
                         (replace-regexp-in-string main-src "/test" dir)))
           (toggle-base (if test-p
                            (replace-regexp-in-string (concat test-suffix "$") "" base)
                          (concat base test-suffix)))
           (toggle-fn (concat root toggle-dir toggle-base "." ext))
           (buf (find-buffer-visiting toggle-fn)))
      (if buf
          (pop-to-buffer buf)
        (if (file-exists-p toggle-fn)
            (find-file toggle-fn)
          (when (y-or-n-p (format "Test file not found. Create '%s'?" toggle-fn))
            (find-file toggle-fn))))))

  (require 'python)
  (defun project-run-python ()
    "Run a dedicated inferior Python process for the current project.
Like `run-python' started with a prefix-arg and then choosing to
created a dedicated process for the project."
    (interactive)
    (run-python (python-shell-calculate-command) 'project t))

  ;; Don't show a dispatch menu when switching projects but always choose project buffer/file
  (setq project-switch-commands #'consult-project-extra-find))

(use-package ibuffer-project
  :hook (ibuffer . ibuffer-project-set-filter-groups)
  :config
  (defun ibuffer-project-set-filter-groups ()
    (setq ibuffer-filter-groups (ibuffer-project-generate-filter-groups))
    (unless (eq ibuffer-sorting-mode 'project-file-relative)
      (ibuffer-do-sort-by-project-file-relative))))

(use-package dired
  :bind (("C-x d" . dired)
         :map dired-mode-map
         ("j" . consult-line)
         ("M-u" . dired-up-directory)
         ("M-RET" . emms-play-dired)
         ("C-RET" . dired-open-xdg)
         ([(control return)] . dired-open-xdg)
         ("e" . dired-ediff-files)
         ("C-c C-d" . dired-dragon-popup)
         ("C-c C-e" . dired-toggle-read-only))
  :config
  ;; Allow drag and drop out of dired into other apps (e.g. browser)
  (setq dired-mouse-drag-files t)
  ;; Open directories in same buffer
  (setq dired-kill-when-opening-new-dired-buffer t)
  ;; always delete and copy recursively
  (setq dired-recursive-deletes 'always)
  (setq dired-recursive-copies 'always)
  (setq dired-dwim-target t))

(use-package dired-aux
  :after dired
  :config
  ;; Add unrar to `dired-compress'
  (add-to-list 'dired-compress-file-suffixes '("\\.rar\\'" "" "unrar x %i")))

(use-package dired-ranger  ;; From dired-hacks package
  :after dired
  :init
  (bind-keys :map dired-mode-map
             :prefix "c"
             :prefix-map dired-ranger-map
             :prefix-docstring "Map for ranger operations."
             ("c" . dired-ranger-copy)
             ("p" . dired-ranger-paste)
             ("m" . dired-ranger-move))

  (bind-keys :map dired-mode-map
             ("'" . dired-ranger-bookmark)
             ("`" . dired-ranger-bookmark-visit)))

(use-package bash-completion
  :hook ((shell-dynamic-complete-functions . bash-completion-dynamic-complete)
         (eshell-mode . bash-completion-setup-capf))
  :init
  (defun bash-completion-setup-capf ()
    (setq-local completion-at-point-functions
                (cons #'bash-completion-capf-nonexclusive
                      completion-at-point-functions))))

(use-package eshell
  :bind (("C-x M" . eshell)
         :map eshell-mode-map
         ("M-P" . eshell-previous-prompt)
         ("C-d" . dakra-eshell-quit-or-delete-char)
         ("M-N" . eshell-next-prompt)
         ("M-R" . eshell-list-history)
         ("C-r" . consult-history))
  :init
  (setq eshell-aliases-file (no-littering-expand-etc-file-name "eshell-aliases"))
  :config
  (delete 'eshell-banner eshell-modules-list)
  (require 'em-tramp)
  (add-to-list 'eshell-modules-list 'eshell-tramp)

  (require 'em-prompt)
  (defun dakra-eshell-quit-or-delete-char (arg)
    "Make C-d exit the shell on empty prompt or delete a char otherwise."
    (interactive "p")
    (if (= (point) (line-beginning-position) (line-end-position))
        (progn
          (eshell-life-is-too-much)
          (ignore-errors
            (when (= arg 4)  ; With prefix argument, also remove eshell frame/window
              ;; Remove frame if eshell is the only window (otherwise just close window)
              (if (one-window-p)
                  (delete-frame)
                (delete-window)))))
      (delete-char arg)))

  (require 'em-hist)
  ;; Fix eshell overwriting history.
  ;; From https://emacs.stackexchange.com/a/18569/15023.
  (setq eshell-history-size 8192
        eshell-save-history-on-exit nil)
  (defun eshell-append-history ()
    "Call `eshell-write-history' with the `append' parameter set to `t'."
    (when eshell-history-ring
      (let ((newest-cmd-ring (make-ring 1)))
        (ring-insert newest-cmd-ring (car (ring-elements eshell-history-ring)))
        (let ((eshell-history-ring newest-cmd-ring))
          (eshell-write-history eshell-history-file-name t)))))
  (add-hook 'eshell-pre-command-hook #'eshell-append-history)

  (setq eshell-ls-initial-args "-h"
        eshell-scroll-to-bottom-on-input 'all
        eshell-error-if-no-glob t
        eshell-hist-ignoredups t
        eshell-visual-commands '("ptpython" "ipython" "pshell" "tail" "vi" "vim" "watch"
                                 "nmtui" "dstat" "mycli" "pgcli" "vue" "ngrok" "bandwhich"
                                 "tmux" "screen" "top" "htop" "less" "more" "ncftp")
        eshell-prefer-lisp-functions nil)

  ;; Functions starting with `eshell/' can be called directly from eshell
  ;; with only the last part. E.g. (eshell/foo) will call `$ foo'
  (defun eshell/d (&optional dir)
    "Open dired in current directory."
    (dired (or dir ".")))

  (defun eshell/ccat (file)
    "Like `cat' but output with Emacs syntax highlighting."
    (with-temp-buffer
      (insert-file-contents file)
      (let ((buffer-file-name file))
        (delay-mode-hooks
          (set-auto-mode)
          (if (fboundp 'font-lock-ensure)
              (font-lock-ensure)
            (with-no-warnings
              (font-lock-fontify-buffer)))))
      (buffer-string)))

  (defun eshell/lcd (&optional directory)
    "Like regular `cs' but don't jump out of a tramp directory.
When on a remote directory with tramp don't jump \"out\" of the server.
So if we're connected with sudo to \"remotehost\", \"$ lcd /etc\" would
go to \"/sudo:remotehost:/etc\" instead of just \"/etc\" on localhost."
    (setq directory (or directory "~/"))
    (unless (file-remote-p directory)
      (setq directory (concat (file-remote-p default-directory) directory)))
    (eshell/cd directory))

  (defun eshell/gst (&rest args)
    (magit-status-setup-buffer (or (pop args) default-directory))
    ;; The echo command suppresses output
    (eshell/echo)))

(use-package eat
  ;;:hook (eshell-load-hook . eat-eshell-visual-command-mode)
  :bind (:map eat-semi-char-mode-map
              ("M-i" . windmove-up)
              ("M-k" . windmove-down)
              ("M-j" . windmove-left)
              ("M-l" . windmove-right)
              ("M-J" . windmove-swap-states-left)
              ("M-K" . windmove-swap-states-down)
              ("M-I" . windmove-swap-states-up)
              ("M-L" . windmove-swap-states-right))
  :config
  (defun eat-compile (command name)
    (let ((buf (pop-to-buffer name '((display-buffer-no-window)
                                     (inhibit-same-window . t))))
          (eat-mode-hook nil)
          (eat-kill-buffer-on-exit nil))
      (with-current-buffer buf
        (delete-region (point-min) (point-max))
        (eat-exec buf name "bash" nil (list "-ilc" command))
        (setq eat--synchronize-scroll-function #'eat--synchronize-scroll)
        (eat-emacs-mode)
        (compilation-minor-mode))))

  (setq eat-kill-buffer-on-exit t))

(use-package vterm
  :defer t
  :bind (:map vterm-mode-map
              ("C-y" . vterm-yank)
              ("M-y" . vterm-yank-pop)
              ("C-k" . vterm-send-C-k-and-kill)
              ("M-d" . vterm-send-M-d-and-kill)
              ("M-DEL" . vterm-backward-kill-word)
              ;; I'm used to go up/down the shell history with M-n/p from eshell
              ;; Simulate this behavior in vterm
              ("M-p" . vterm-send-C-p)
              ("M-n" . vterm-send-C-n))
  :hook (vterm-mode . -vterm-init)
  :config
  (defun -vterm-init ()
    "Disable whole-line-or-region otherwise I can't bind `C-y'.
And disable hl-line-mode which causes a flicker on prompt when typing."
    (whole-line-or-region-local-mode -1)
    (hl-line-mode 'toggle))

  (defun vterm-send-C-p ()
    "Sends C-p to the libvterm."
    (interactive)
    (vterm-send-key "p" nil nil t))

  (defun vterm-send-C-n ()
    "Sends C-n to the libvterm."
    (interactive)
    (vterm-send-key "n" nil nil t))

  ;; Kill dead vterm buffers
  (setq vterm-kill-buffer-on-exit t
        vterm-max-scrollback 100000)

  ;; Run a shell command in vterm with compilation-minor-mode
  (defun vterm-compile (command &optional name)
    (interactive
     (list
      (let ((command (eval compile-command)))
        (if (or compilation-read-command current-prefix-arg)
            (compilation-read-command command)
          command))
      (consp current-prefix-arg)))
    (let ((buffer (generate-new-buffer (or name "*vterm*"))))
      (with-current-buffer buffer
        (let ((vterm-shell command)
              (vterm-kill-buffer-on-exit nil)
              (vterm-mode-hook nil)
              (next-error-function 'vterm-next-error-function))
          (vterm-mode)
          (compilation-minor-mode))
        (pop-to-buffer buffer))))

  (defun vterm-send-C-k-and-kill ()
    "Send `C-k' to libvterm.
Like normal Emacs `C-k'.  Kill to end of line and put content in kill-ring."
    (interactive)
    (kill-ring-save (point) (line-end-position))
    (vterm-send-key "k" nil nil t))

  (defun vterm-send-M-d-and-kill ()
    "Send `M-d' to libvterm.
Like normal Emacs `M-d'.  Kill word and put content in kill-ring."
    (interactive)
    (kill-ring-save (point) (save-excursion (forward-word) (point)))
    (vterm-send-key "d" nil t nil))

  (defun vterm-backward-kill-word ()
    "Send `M-DEL' to libvterm.
Like normal Emacs `M-d'.  Kill a word backward and put content in kill-ring."
    (interactive)
    (kill-ring-save (save-excursion (backward-word) (point)) (point))
    (vterm-send-key "DEL" nil t nil))

  ;; Allow vterm to invoke some elisp functions
  (setq vterm-eval-cmds '(("dired-other-window" dired-other-window)
                          ("find-file" find-file)
                          ("find-file-other-window" find-file-other-window)
                          ("magit-status-setup-buffer" magit-status-setup-buffer)
                          ("message" message)
                          ("vterm-clear-scrollback" vterm-clear-scrollback))))

(use-package ghostel
  :bind (("C-x m" . ghostel)
         :map ghostel-mode-map
         ("C-s" . consult-line)
         ("C-k" . ghostel-send-C-k-and-kill)
         ("M-d" . ghostel-send-M-d-and-kill)
         ("M-<backspace>" . ghostel-backward-kill-word)
         ;; I'm used to go up/down the shell history with M-n/p from eshell
         ;; Simulate this behavior in ghostel by sending C-p and C-n
         ("M-p" . (lambda () (interactive) (ghostel-send-key "p" "ctrl")))
         ("M-n" . (lambda () (interactive) (ghostel-send-key "n" "ctrl")))
         :map project-prefix-map
         ("m" . ghostel-project))
  :config
  (defun ghostel-send-C-k-and-kill ()
    "Send `C-k' to ghostel.
Like normal Emacs `C-k'.  Kill to end of line and put content in kill-ring."
    (interactive)
    (kill-ring-save (point) (line-end-position))
    (ghostel-send-key "k" "ctrl"))

  (defun ghostel-send-M-d-and-kill ()
    "Send `M-d' to ghostel.
Like normal Emacs `M-d'.  Kill word and put content in kill-ring."
    (interactive)
    (kill-ring-save (point) (save-excursion (forward-word) (point)))
    (ghostel-send-key "d" "alt"))

  (defun ghostel-backward-kill-word ()
    "Send `M-backspace' to ghostel.
Like normal Emacs `M-d'.  Kill a word backwards and put content in kill-ring."
    (interactive)
    (kill-ring-save (save-excursion (backward-word) (point)) (point))
    (ghostel-send-key "backspace" "alt"))

  ;; (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'ghostel-eval-cmds '("magit-status-setup-buffer" magit-status-setup-buffer)))

(use-package ghostel-eshell
  :hook (eshell-load-hook . ghostel-eshell-visual-command-mode))

(use-package ghostel-compile
  :hook (after-init . ghostel-compile-global-mode))

;; (use-package gterm
;;   :defer t
;;   :config
;;   (setq gterm-shell "/opt/homebrew/bin/bash"))

(use-package markdown-mode
  :mode (("\\.markdown\\'" . gfm-mode)
         ("README\\.md\\'" . gfm-mode))
  :bind (:map markdown-mode-map
              ("\C-c TAB" . nil)  ;; Reserve for tempel-expand instead of markdown-insert-image
              ("C-c =" . markdown-insert-header-dwim))
  :config
  ;; Display remote images
  (setq markdown-display-remote-images t)
  ;; Enable fontification for code blocks
  (setq markdown-fontify-code-blocks-natively t)
  ;; Add some more languages
  (dolist (x '(("ini" . conf-mode)
               ("clj" . clojure-mode)
               ("cljs" . clojure-mode)
               ("cljc" . clojure-mode)))
    (add-to-list 'markdown-code-lang-modes x))

  ;; use pandoc with source code syntax highlighting to preview markdown (C-c C-c p)
  (setq markdown-command "pandoc -s --highlight-style pygments -f markdown_github -t html5"))

;; Only deps: websocket
(use-package monet
  :hook ((after-init . monet-mode))
  :config
  ;; monet-simple-diff has no benefit over the diff in claude code
  ;; so don't disturb my windows and only use the diff inside claude code
  (setq monet-diff-tool nil)
  ;; (setq monet-diff-tool #'monet-ediff-tool)
  ;; (setq monet-diff-cleanup-tool #'monet-ediff-cleanup-tool)
  )

;; Only deps: inheritenv, monet
(use-package claude-code
  ;; :bind-keymap ("C-c c" . claude-code-command-map)
  :bind (("C-c c" . claude-code-transient)
         :repeat-map my-claude-code-map ("M" . claude-code-cycle-mode))
  :hook ((after-init . claude-code-mode))
  :config
  ;; This hook has to go here as use-package :hook adds a -hook to the name.
  (add-hook 'claude-code-process-environment-functions #'monet-start-server-function)

  ;; (load-file (expand-file-name "examples/hooks/claude-code-auto-revert-hook.el" (borg-worktree "claude-code")))
  ;; (setup-claude-auto-revert)

  ;; Display claude buffer on the right
  ;; (add-to-list 'display-buffer-alist
  ;;              '("^\\*claude"
  ;;                (display-buffer-in-direction)
  ;;                (direction . right)))

  ;; Display claude in an existing window if one exists, otherwise create one on the right
  ;; (add-to-list 'display-buffer-alist
  ;;              '("^\\*claude"
  ;;                (display-buffer-reuse-window
  ;;                 display-buffer-in-direction)
  ;;                (direction . right)))

  (add-to-list 'display-buffer-alist
               '("^\\*claude"
                 (display-buffer-reuse-window
                  display-buffer-use-some-window)
                 (inhibit-same-window . t)))

  (defun -claude-code-mac-notify (title message)
    "Display a MacOS notification with sound."
    (call-process "osascript" nil nil nil
                  "-e" (format "display notification \"%s\" with title \"%s\" sound name \"Glass\""
                               message title)))

  (setq claude-code-toggle-auto-select t
        ;; claude-code-program "happy"
        claude-code-program-switches '("--allow-dangerously-skip-permissions"
                                       ;; "--channels" "plugin:telegram@claude-plugins-official"
                                       )
        claude-code-enable-notifications nil
        ;; claude-code-notification-function #'-claude-code-mac-notify
        claude-code-terminal-backend 'ghostel))

;; Only deps: web-server, websocket
;; (use-package claude-code-ide
;;   :bind ("C-c c" . claude-code-ide-menu)
;;   :config
;;   (claude-code-ide-emacs-tools-setup))

(use-package eca
  :bind ("C-c e" . eca-transient-menu)
  :config
  (setq eca-server-install-path (no-littering-expand-var-file-name "eca/eca")
        eca-chat-use-side-window nil))

;; * vertico/consult etc

(use-package vertico
  :unless noninteractive
  :hook (after-init . vertico-mode))

(use-package vertico-buffer
  :after vertico
  :config
  (setq vertico-buffer-display-action '(display-buffer-below-selected
                                        (window-height . ,(+ 3 vertico-count))))
  (vertico-buffer-mode))

(use-package vertico-multiform
  :after vertico
  :config
  (setq vertico-multiform-commands
        '((consult-xref buffer)
          (consult-line buffer)
          (consult-buffer buffer)
          (consult-org-heading buffer)
          (consult-imenu buffer)
          (consult-project-buffer buffer)
          (consult-mu-dynamic buffer)
          (consult-project-extra-find buffer)))
  (vertico-multiform-mode))

(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion))
                                        (eglot (styles orderless))
                                        (eglot-capf (styles orderless)))))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :unless noninteractive
  :hook (after-init . marginalia-mode)
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle)))

(use-package consult
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
         ("C-c M" . consult-mode-command)
         ("C-c k" . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b"   . consult-buffer)              ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ;; Custom M-# bindings for fast register access
         ("M-#"   . consult-register-load)
         ("M-'"   . consult-register-store)        ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y"      . consult-yank-pop)           ;; orig. yank-pop
         ("<help> a" . consult-apropos)            ;; orig. apropos-command
         ;; M-g bindings (goto-map)
         ("M-g e" . consult-compile-error)
         ;; ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-m"   . consult-imenu)
         ("C-M-m"   . consult-imenu-multi)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings (search-map)
         ("s-c" . nil)  ;; Bound to `ns-copy-including-secondary' by default on MacOS
         ("s-c d" . consult-find)
         ("s-c D" . consult-locate)
         ("s-c g" . consult-grep)
         ("s-c G" . consult-git-grep)
         ("s-c r" . consult-ripgrep)
         ("s-c l" . consult-line)
         ("s-c L" . consult-line-multi)
         ("s-c m" . consult-multi-occur)
         ("s-c k" . consult-keep-lines)
         ("s-c u" . consult-focus-lines)
         ;; Isearch integration
         ("C-s" . consult-line)
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi))           ;; needed by consult-line to detect isearch
  :hook (completion-list-mode . consult-preview-at-point-mode)

  :init
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :config
  ;; (setq consult-preview-key "M-.")
  (consult-customize
   consult-theme
   :preview-key "M-."
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file consult-source-bookmark
   :preview-key '(:debounce 0.2 any))

  (setq consult-narrow-key "<"))

(use-package consult-project-extra
  :defer t)

(use-package embark
  :bind (("C-." . embark-dwim)         ;; pick some comfortable binding
         ("C-," . embark-act)        ;; good alternative: M-.
         ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :after (embark consult)
  :demand t ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package corfu
  :hook (((prog-mode conf-mode markdown-mode) . corfu-mode)
         (eshell-mode . corfu-no-auto-mode))
  :bind (:map corfu-map
              ("RET" . nil))
  :config
  (defun corfu-no-auto-mode ()
    "Activate corfu but with auto mode disabled."
    (setq-local corfu-auto nil)
    (corfu-mode))

  (setq corfu-cycle t
        corfu-auto t
        corfu-auto-delay 0.1
        corfu-auto-prefix 2))

(use-package corfu-history
  :after corfu
  :config
  (corfu-history-mode))

(use-package corfu-popupinfo
  :after corfu
  :config
  (setq corfu-popupinfo-max-height 30)
  (corfu-popupinfo-mode))

(use-package tempel
  :bind (("\C-c TAB" . tempel-complete)
         :map tempel-map
         ([tab] . tempel-next)
         ([backtab] . tempel-previous))
  :hook ((text-mode prog-mode) . tempel-setup-capf)
  :config
  ;; Load templates from etc folder
  (setq tempel-path (no-littering-expand-etc-file-name "tempel.eld"))

  ;; Don't auto reload templates.
  ;; `(setq tempel--path-templates nil)' if you want to force a reload.
  (setq tempel-auto-reload nil)

  ;; Setup completion at point
  (defun tempel-setup-capf ()
    ;; Add the Tempel Capf to `completion-at-point-functions'.
    ;; `tempel-expand' only triggers on exact matches. Alternatively use
    ;; `tempel-complete' if you want to see all matches, but then you
    ;; should also configure `tempel-trigger-prefix', such that Tempel
    ;; does not trigger too often when you don't expect it. NOTE: We add
    ;; `tempel-expand' *before* the main programming mode Capf, such
    ;; that it will be tried first.
    (setq-local completion-at-point-functions
                (cons #'tempel-expand
                      completion-at-point-functions))))

;; * Third party packages

(use-package pulse
  :unless noninteractive
  :config
  (setq pulse-flag t
        pulse-delay .05))

(use-package winpulse
  :unless noninteractive
  :hook (after-init . winpulse-mode))

(use-package dimmer  ;; Visually highlight the selected buffer
  :disabled t  ; doesn't work right with my emacsclient window navigation?
  :unless noninteractive
  :hook (after-init . dimmer-mode)
  :config
  ;; Don't dim hydra, transient buffers or minibuffers
  (setq dimmer-buffer-exclusion-regexps '(" \\*\\(LV\\|transient\\)\\*"
                                          "^ \\*.*posframe.*buffer.*\\*$"
                                          "^\\*Minibuf-[0-9]+\\*"
                                          "^.\\*which-key\\*$"
                                          "^.\\*Echo.*\\*"))
  ;;(setq dimmer-use-colorspace ':rgb)
  (setq dimmer-fraction 0.3))

(use-package beacon
  :disabled t
  :unless noninteractive
  :hook (after-init . beacon-mode)
  :config
  (setq beacon-blink-when-focused t
        beacon-size 60
        beacon-blink-duration 0.4))

;; You can change syntax in regex-builder with "C-c TAB"
;; "read" is 'code' syntax
;; "string" is already read and no extra escaping. Like what Emacs prompts interactively
(use-package re-builder
  :defer t
  :config
  (setq reb-re-syntax 'string))

(use-package visual-replace
  :bind (("C-c r" . visual-replace)
         ([remap query-replace] . visual-replace)
         ([remap replace-string] . visual-replace)
         ([remap isearch-query-replace] . visual-replace-from-isearch)
         ([remap isearch-query-replace-regexp] . visual-replace-from-isearch)
         :map isearch-mode-map
         ("C-c r" . visual-replace-from-isearch))
  :config
  (setq visual-replace-default-to-full-scope t))

(use-package minions
  :unless noninteractive
  :hook (after-init . minions-mode)
  :config
  (setq minions-mode-line-lighter "+")
  (setq minions-prominent-modes '(flycheck-mode
                                  multiple-cursors-mode
                                  mu4e-modeline-mode)))

(use-package pdf-tools
  ;; manually update
  ;; after each update we have to call:
  ;; Install pdf-tools but don't ask or raise error (otherwise daemon mode will wait for input)
  ;; (pdf-tools-install t t t)
  :magic ("%PDF" . pdf-view-mode)
  :mode (("\\.pdf\\'" . pdf-view-mode))
  :hook ((pdf-view-mode . pdf-view-init))
  :bind (:map pdf-view-mode-map
              ("C-s" . isearch-forward)
              ("M-w" . pdf-view-kill-ring-save))
  :config
  (defun pdf-view-init ()
    "Initialize pdf-tools view like enabline TOC functions or use dark theme at night."

    ;; Use dark theme when opening PDFs at night time
    (let ((hour (string-to-number (format-time-string "%H"))))
      (when (or (< hour 5) (< 20 hour))
        (pdf-view-midnight-minor-mode)))

    ;; Enable pdf-tools minor mode to have features like TOC extraction by pressing `o'.
    (pdf-tools-enable-minor-modes)

    ;; Disable while-line-or-region to free keybindings.
    (whole-line-or-region-local-mode -1))

  (setq pdf-misc-print-program-executable "lpr"

        pdf-roll-vertical-margin 5
        pdf-roll-margin-color "black"

        pdf-view-resize-factor 1.1  ;; more fine-grained zooming; +/- 10% instead of default 25%

        ;; Always use midnight-mode and almost same color as default font.
        ;; Just slightly brighter background to see the page boarders
        pdf-view-midnight-colors '("#c6c6c6" . "#363636")))

(use-package visual-fill-column
  :defer t
  ;; :config
  ;; Option to center text by default
  ;; (setq-default visual-fill-column-center-text t)
  )

(use-package csv-mode
  :hook ((csv-mode . csv-align-mode)
         (csv-mode . csv-header-line))
  :init
  ;; Don't font-lock as comment when there's a `##'
  ;; string somewhere inside a CSV line.
  (setq csv-comment-start-default nil)
  ;; Add more separators.
  ;; This variable has to be set *before*
  ;; loading csv-mode (i.e. the use-package :init block)
  (setq csv-separators '("," "	" ";" "|")))

;; Only deps: datetime, extmap
(use-package logview
  :mode ("log.out\\'" . logview-mode)
  :config
  (setq datetime-timezone 'Europe/Berlin)
  (setq logview-additional-timestamp-formats
        '(("ISO 8601 datetime (with 'T') + millis + 'Z'"
           (java-pattern . "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
           (datetime-options :any-decimal-separator t)
           (aliases "yyyy-MM-dd HH:mm:ss.SSS") (aliases "yyyy-MM-dd HH:mm:ss.SSSSSS")
           (aliases "yyyy-MM-dd'T'HH:mm:ss.SSS") (aliases "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
           (aliases "yyyy-MM-dd'T'HH:mm:ss.SSSSSS") (aliases "HH:mm:ss.SSS")
           (aliases "HH:mm:ss.SSSSSS"))))
  (add-to-list 'logview-additional-submodes
               '("Timbre"
                 (format  . "TIMESTAMP LEVEL [NAME] -")
                 (levels  . "SLF4J"))))

(use-package gptel
  ;; :hook (gptel-mode . (visual-line-mode visual-fill-column-mode))
  :config
  (gptel-make-gemini "Gemini" :key gptel-api-key :stream t)  ;;  :models '(gemini-2.5-pro)
  (gptel-make-gh-copilot "Copilot")  ;;  :models '(gpt-4.1)

  (setq gptel-default-mode 'org-mode
        gptel-track-media t
        gptel-model 'claude-opus-4-6
        gptel-prompt-prefix-alist '((markdown-mode . "# ") (org-mode . "* ") (text-mode . "# "))
        gptel-backend (gptel-make-anthropic "Claude"
                        :stream t
                        :key gptel-api-key
                        :models '(claude-opus-4-6 claude-sonnet-4-5-20250929 claude-haiku-4-5-20251001))))

(use-package gptel-agent
  :after gptel
  :config
  (gptel-agent-update))

;; Only deps: pfuture
(use-package treemacs
  :bind (([f8] . treemacs-find-file-select-window)
         ([f12] . treemacs-find-file-deep)
         :map treemacs-mode-map
         ("M-l" . nil)  ;; We bind `M-l' to `windmove-right'
         ("{" . treemacs-decrease-width)
         ("}" . treemacs-increase-width)
         ("C-t a" . treemacs-add-project-to-workspace)
         ("C-t d" . treemacs-remove-project)
         ("C-t r" . treemacs-rename-project)
         ;; If we only hide the treemacs buffer (default binding) then, when we switch
         ;; a frame to a different project and toggle treemacs again we still get the old project
         ("q" . treemacs-kill-buffer))
  :config
  (defun treemacs-find-file-deep ()
    "`treemacs-find-file' only opens 1 layer at a time.
Just call it 8 times in a row should be enough to always show the file."
    (interactive)
    (dotimes (_ 8)
      (treemacs-find-file)))

  (defun treemacs-find-file-select-window ()
    "Like `treemacs-select-window' but calls `treemacs-find-file' first."
    (interactive)
    (when (buffer-file-name)
      (treemacs-find-file-deep))
    (treemacs-select-window))

  (defun treemacs-ignore-python-files (file _)
    (or (s-ends-with-p ".pyc" file)
        (string= file "__pycache__")))
  (add-to-list 'treemacs-ignored-file-predicates 'treemacs-ignore-python-files)

  ;; Read input from minibuffer instead of childframe (which requires an extra package)
  (setq treemacs-read-string-input 'from-minibuffer)

  (setq treemacs-follow-after-init          t
        treemacs-indentation                1
        treemacs-width                      30
        treemacs-collapse-dirs              5)

  ;; HACK: We can only call resize-icons once we created a frame.
  ;; Since we start Emacs in daemon mode, just wait 3min to make sure there is a frame.
  (run-with-timer 180 nil #'treemacs-resize-icons 14)  ;; Make icons a bit smaller (22 pixels by default)

  (treemacs-follow-mode -1)
  (treemacs-fringe-indicator-mode -1)
  (if (eq system-type 'windows-nt)
      (treemacs-git-mode -1)  ;; Turn git and filewatch mode off on slow Windows
    (treemacs-git-mode 'simple)
    (treemacs-filewatch-mode t)))

;; Use magit hooks to notify treemacs of git changes
(use-package treemacs-magit
  :after treemacs)

(use-package treemacs-icons-dired
  :after dired
  :config
  (treemacs-icons-dired-mode))

(use-package indent-bars
  :hook ((python-ts-mode sh-mode java-ts-mode toml-ts-mode yaml-ts-mode) . indent-bars-mode)
  :config
  ;; (setopt indent-bars-color-by-depth '(:regexp "outline-\\([0-9]+\\)" :blend 1))
  ;; (setopt indent-bars-color-by-depth nil)
  ;; (setopt indent-bars-color '(highlight :face-bg t :blend 0.6))
  ;; (setopt indent-bars-highlight-current-depth '(:face default :blend 0.2 :pattern "."))
  ;; (setopt indent-bars-width-frac 0.25)
  (setq indent-bars-treesit-support t
        indent-bars-color-by-depth nil
        indent-bars-color '(highlight :face-bg t :blend 0.6)
        indent-bars-highlight-current-depth '(:face default :blend 0.2 :pattern ".")
        indent-bars-no-descend-lists t
        indent-bars-treesit-wrap '((c      argument_list parameter_list init_declarator parenthesized_expression)
                                   (java   argument_list formal_parameters block_comment)
                                   (rust arguments parameters)
                                   (python argument_list parameters
                                           list list_comprehension
                                           dictionary dictionary_comprehension
                                           parenthesized_expression subscript)
                                   (toml   table array comment)
                                   (yaml   block_mapping_pair comment))
        indent-bars-treesit-scope '((python function_definition class_definition for_statement
                                            if_statement with_statement while_statement)
                                    (rust trait_item impl_item
                                          macro_definition macro_invocation
                                          struct_item enum_item mod_item
                                          const_item let_declaration
                                          function_item for_expression
                                          if_expression loop_expression
                                          while_expression match_expression
                                          match_arm call_expression
                                          token_tree token_tree_pattern
                                          token_repetition))
        indent-bars-treesit-ignore-blank-lines-types '("module")))

(use-package copilot
  ;; :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ;; ("<tab>" . 'copilot-accept-completion)
              ;; ("TAB" . 'copilot-accept-completion)
              ;; ("C-TAB" . 'copilot-accept-completion-by-word)
              ;; ("C-<tab>" . 'copilot-accept-completion-by-word)
              ("C-g" . 'copilot-clear-overlay)
              ("<right>" . 'copilot-accept-completion)
              ("M-f" . 'copilot-accept-completion)
              ("M-<right>" . 'copilot-accept-completion-by-word)
              ("M-F" . 'copilot-accept-completion-by-word)
              ("M-n" . 'copilot-next-completion)
              ("M-p" . 'copilot-previous-completion))
  :config
  ;; Don't pop up a warning buffer
  (setq copilot-max-char-warning-disable t
        copilot-indent-offset-warning-disable t)
  (add-to-list 'copilot-indentation-alist '(sh-mode 4))
  (add-to-list 'copilot-indentation-alist '(clojure-mode 2))
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2)))

(use-package flycheck
  :hook (((prog-mode
           conf-mode
           ledger-mode
           systemd-mode
           mu4e-compose-mode
           markdown-mode
           rst-mode) . flycheck-mode)
         (flycheck-mode . mp-flycheck-prefer-eldoc))
  :config
  ;; Don't initialize packages (as we don't use package.el)
  (setq flycheck-emacs-lisp-initialize-packages nil)
  ;; Use the load-path from running Emacs when checking elisp files
  (setq flycheck-emacs-lisp-load-path 'inherit)

  ;; Only do flycheck when I actually safe the buffer
  (setq flycheck-check-syntax-automatically '(save mode-enable))

  ;; Work with `eldoc-documentation-functions'
  ;; From https://www.masteringemacs.org/article/seamlessly-merge-multiple-documentation-sources-eldoc
  (defun mp-flycheck-eldoc (callback &rest _ignored)
    "Print flycheck messages at point by calling CALLBACK."
    (when-let* ((flycheck-errors (and flycheck-mode (flycheck-overlay-errors-at (point)))))
      (mapc
       (lambda (err)
         (funcall callback
                  (format "%s: %s"
                          (let ((level (flycheck-error-level err)))
                            (pcase level
                              ('info (propertize "I" 'face 'flycheck-error-list-info))
                              ('error (propertize "E" 'face 'flycheck-error-list-error))
                              ('warning (propertize "W" 'face 'flycheck-error-list-warning))
                              (_ level)))
                          (flycheck-error-message err))
                  :thing (or (flycheck-error-id err)
                             (flycheck-error-group err))
                  :face 'font-lock-doc-face))
       flycheck-errors)))

  (defun mp-flycheck-prefer-eldoc ()
    (add-hook 'eldoc-documentation-functions #'mp-flycheck-eldoc nil t)
    (setq eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)
    (setq flycheck-display-errors-function nil)
    (setq flycheck-help-echo-function nil)))

(use-package shrink-whitespace
  :bind ("M-SPC" . shrink-whitespace))

;; Automatically remove trailing whitespace (only if I put them there)
(use-package ws-butler
  :hook ((text-mode prog-mode) . ws-butler-mode)
  :config (setq ws-butler-keep-whitespace-before-point nil))

;; * Git

;; Highlight and link issue IDs to website
;; bug-reference-url-format has to be set in dir-locals (S-p E)
;; E.g. for github: (bug-reference-url-format . "https://github.com/dakra/dmacs/issues/%s")
(use-package bug-reference
  :hook ((prog-mode . bug-reference-prog-mode)
         ((log-view-mode magit-status-mode) . bug-reference-mode)
         (magit-log-wash-summary . magit-highlight-bug-reference-regexp))
  :config
  ;; (setq bug-reference-bug-regexp "#\\(?2:[0-9]+\\)")
  (setq bug-reference-bug-regexp "\\(\\b\\(?:[Bb]ug ?#?\\|[Ii]ssue ?#\\|[Pp]atch ?#\\|RFE ?#\\|PR [a-z+-]+/\\)\\([0-9]+\\(?:#[0-9]+\\)?\\)\\)")

  (defun magit-highlight-bug-reference-regexp ()
    "Highlight bug-reference-regexp in magit logs."
    (while (re-search-forward bug-reference-bug-regexp nil t)
      (put-text-property (match-beginning 0)
                         (match-end 0)
                         'font-lock-face 'magit-keyword))))


(use-package with-editor
  ;; Use local Emacs instance as $EDITOR (e.g. in `git commit' or `crontab -e')
  :hook ((shell-mode eshell-mode term-exec) . with-editor-export-editor))

(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-x G" . magit-dispatch)
         ("C-x M-g" . magit-dispatch)
         ("s-m" . nil)  ;; iconify-frame by default on MacOS
         ("s-m p" . magit-list-repositories)
         ("s-m m" . magit-status)
         ("s-m f" . magit-file-dispatch)
         ("s-m l" . magit-log)
         ("s-m L" . magit-log-buffer-file)
         ("s-m b" . magit-blame-addition)
         ("s-m B" . magit-blame)
         :map magit-process-mode-map
         ("k" . magit-process-kill))
  :hook (after-save . magit-after-save-refresh-status)
  :config
  ;; Don't override date for extend or reword
  (setq magit-commit-extend-override-date nil
        magit-commit-reword-override-date nil)

  ;; Always show recent/unpushed/unpulled commits
  (setq magit-section-initial-visibility-alist '((unpushed . show)
                                                 (unpulled . show)))

  ;; Show submodules section to magit status
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-modules
                          'magit-insert-stashes
                          'append)

  ;; Show ignored files section to magit status
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-ignored-files
                          'magit-insert-untracked-files
                          nil)

  ;; Disable safety nets
  (setq magit-commit-squash-confirm nil)
  (setq magit-save-repository-buffers 'dontask)
  (setf (nth 2 (assq 'magit-stash-pop  magit-dwim-selection)) t)
  (dolist (x '(rename resurrect untrack stage-all-changes unstage-all-changes))
    (add-to-list 'magit-no-confirm x t))

  ;; Always highlight word differences in diff
  (setq magit-diff-refine-hunk 'all
        ;; Add syntax highlighting to diff hunks
        magit-diff-fontify-hunk 'all
        magit-diff-specify-hunk-foreground nil
        magit-diff-use-indicator-faces t)

  ;; Wrap excessively long summary lines (doesn't wrap the body)
  (setq magit-revision-fill-summary-line 100)

  ;; Don't change my window layout after quitting magit
  ;; Often I invoke magit and then do a lot of things in other windows
  ;; On quitting, magit would then "restore" the window layout like it was
  ;; when I first invoked magit. Don't do that!
  (setq magit-bury-buffer-function 'magit-mode-quit-window)

  ;; Show magit status in the same window
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package magit-wip
  :after magit
  :config
  ;; Disable more safety nets that can be reverted with WIP mode
  (add-to-list 'magit-no-confirm 'safe-with-wip t)
  (magit-wip-mode))

(use-package git-modes
  :defer t)

(use-package git-commit
  :defer t
  :bind ( :map git-commit-mode-map
          ("C-c ." . git-commit-insert-date))
  :commands (git-commit-insert-date)
  :config
  (defun git-commit-insert-date (&optional arg)
    "Insert current date in YYYY-MM-DD format at point.
With prefix ARG, also insert time in HH:MM format."
    (interactive "P")
    (insert (format-time-string (if arg
                                    "%Y-%m-%d %H:%M"
                                  "%Y-%m-%d")))))

;; Only deps: ghub, treepy
(use-package forge
  :after magit
  :config
  ;; Don't pull notifications as it blocks Emacs for a long time
  (setq forge-pull-notifications nil))

(use-package diff-hl
  :hook (((prog-mode conf-mode vc-dir-mode ledger-mode yaml-ts-mode toml-ts-mode markdown-mode) . turn-on-diff-hl-mode)
         (magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :bind (:map diff-hl-mode-map
              ("C-x v s" . diff-hl-show-hunk)
              ("C-x v n" . diff-hl-next-hunk)
              ("C-x v p" . diff-hl-previous-hunk)
              ("C-x v r" . diff-hl-revert-hunk))
  :config
  ;; Disable diff-hl in Tramp
  (setq diff-hl-disable-on-remote t)
  (setq diff-hl-draw-borders nil))

(use-package git-link
  :bind (("C-c G" . git-link))
  :config
  (setq git-link-use-commit t
        git-link-open-in-browser t))

;; * xxx
(use-package wgrep
  :bind (:map grep-mode-map
              ("C-x C-q" . wgrep-change-to-wgrep-mode))
  :config (setq wgrep-auto-save-buffer t))

(use-package undo-fu-session
  :hook (after-init . undo-fu-session-global-mode)
  :config
  (setq undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'")))

(use-package vundo
  :config
  (setq vundo-glyph-alist vundo-unicode-symbols))

(use-package jinx
  :hook (((text-mode prog-mode conf-mode) . jinx-mode))
  :bind (([remap ispell-word] . jinx-correct)  ;; ispell-word bound to "M-$"
         ("C-M-$" . jinx-languages))
  :config
  (setq jinx-languages "en_US de_DE"))

(use-package just-ts-mode
  :defer t)

(use-package justl
  :defer t)

(use-package speed-type
  :defer t)

(use-package disk-usage
  :defer t)

(use-package ligature
  :hook (prog-mode . ligature-mode)
  :config
  ;; Some ligatures supported by most fonts. E.g. Fira Code, Victor Mono
  (ligature-set-ligatures 'prog-mode '("~~>" "##" "|-" "-|" "|->" "|=" ">-" "<-" "<--" "->"
                                       "-->" "-<" ">->" ">>-" "<<-" "<->" "->>" "-<<" "<-<"
                                       "==>" "=>" "=/=" "!==" "!=" "<==" ">>=" "=>>" ">=>"
                                       "<=>" "<=<" "=<=" "=>=" "<<=" "=<<"
                                       "=:=" "=!=" "==" "=~" "!~" "===" "::" ":=" ":>" ">:"
                                       ";;" "__" "..." ".." "&&" "++"
                                       ;; Add ligatures for git merge conflicts. If they don't exist, they'll
                                       ;; be displayed with normal fonts instead of multiple combined ligatures.
                                       "<<<<<<<" "=======" "|||||||" ">>>>>>>")))

(use-package transient
  :defer t
  :bind (("C-x l" . transient-emacs-launcher)
         ("C-x C-l" . transient-emacs-launcher)
         ("C-x t" . transient-toggle-stuff)
         ("C-x 9" . transient-unicode))
  :config
  ;; Display transient buffer below current window
  ;; and not bottom of the complete frame (minibuffer like)
  ;; (setq transient-display-buffer-action '(display-buffer-below-selected))
  (setq transient-show-during-minibuffer-read t
        transient-display-buffer-action '(display-buffer-below-selected (dedicated . t)
                                                                        (inhibit-same-window . t)))

  (defun transient-help-toggle (text toggle)
    (if (bound-and-true-p toggle)
        (format "[x] %s" text)
      (format "[ ] %s" text)))

  (transient-define-prefix transient-toggle-stuff ()
    "Toggle various modes and settings"
    [["Misc"
      ("a" "Abbrev" abbrev-mode
       :description (lambda () (transient-help-toggle "abbrev" 'abbrev-mode)))
      ("b" "Browser" dakra-toggle-browser
       :description (lambda () (format "[%s] toggle eww/firefox"
                                       (if (eq browse-url-browser-function 'browse-url-firefox) "Firefox" "eww"))))
      ("d e" "Debug" toggle-debug-on-error
       :description (lambda () (transient-help-toggle "debug-on-error" 'debug-on-error)))
      ("d q" "Debug" toggle-debug-on-quit
       :description (lambda () (transient-help-toggle "debug-on-quit" 'debug-on-quit)))
      ("s" "Sticky" toggle-window-dedicated
       :description (lambda () (transient-help-toggle "Sticky buffer mode" 'window-dedicated-p)))]
     ["Text"
      ("c" "Column number" column-number-mode
       :description (lambda () (transient-help-toggle "column-number-mode" 'column-number-mode)))
      ("f" "Fill mode" auto-fill-mode
       :description (lambda () (transient-help-toggle "fill-mode" 'auto-fill-function)))
      ("v" "Visual fill column mode" visual-fill-column-mode
       :description (lambda () (transient-help-toggle "visual-fill-column-mode" 'visual-fill-column-mode)))
      ("w" "Whitespace" whitespace-mode
       :description (lambda () (transient-help-toggle "whitespace-mode" 'whitespace-mode)))
      ("l" "Truncate lines" toggle-truncate-lines
       :description (lambda () (transient-help-toggle "truncate-lines" 'truncate-lines)))
      ("p" "Visual wrap prefix mode" visual-wrap-prefix-mode
       :description (lambda () (transient-help-toggle "visual-wrap-prefix-mode" 'visual-wrap-prefix-mode)))]
     ["Org"
      ("ol" "Link display" org-toggle-link-display
       :description (lambda () (transient-help-toggle "org link-display" 'org-descriptive-links)))
      ("op" "Pretty entities" org-toggle-pretty-entities
       :description (lambda () (transient-help-toggle "org pretty-entities" 'org-pretty-entities)))
      ("oi" "Inline images" org-toggle-inline-images
       :description (lambda () (transient-help-toggle "org inline-images" 'org-inline-image-overlays)))]])

  (defun dakra/insert-unicode (unicode-name)
    "Same as C-x 8 enter UNICODE-NAME."
    (insert-char (gethash unicode-name (ucs-names))))

  (transient-define-prefix transient-unicode ()
    "Insert Unicode characters"
    ["Unicode Characters"
     ["Umlauts"
      ("a" "ä" (lambda () (interactive) (dakra/insert-unicode "LATIN SMALL LETTER A WITH DIAERESIS")))
      ("A" "Ä" (lambda () (interactive) (dakra/insert-unicode "LATIN CAPITAL LETTER A WITH DIAERESIS")))
      ("o" "ö" (lambda () (interactive) (dakra/insert-unicode "LATIN SMALL LETTER O WITH DIAERESIS")))
      ("O" "Ö" (lambda () (interactive) (dakra/insert-unicode "LATIN CAPITAL LETTER O WITH DIAERESIS")))
      ("u" "ü" (lambda () (interactive) (dakra/insert-unicode "LATIN SMALL LETTER U WITH DIAERESIS")))
      ("U" "Ü" (lambda () (interactive) (dakra/insert-unicode "LATIN CAPITAL LETTER U WITH DIAERESIS")))
      ("s" "ß" (lambda () (interactive) (dakra/insert-unicode "LATIN SMALL LETTER SHARP S")))]
     ["Symbols"
      ("c" "©" (lambda () (interactive) (dakra/insert-unicode "COPYRIGHT SIGN")))
      ("d" "°" (lambda () (interactive) (dakra/insert-unicode "DEGREE SIGN")))
      ("e" "€" (lambda () (interactive) (dakra/insert-unicode "EURO SIGN")))
      ("p" "£" (lambda () (interactive) (dakra/insert-unicode "POUND SIGN")))
      ("r" "→" (lambda () (interactive) (dakra/insert-unicode "RIGHTWARDS ARROW")))
      ("m" "µ" (lambda () (interactive) (dakra/insert-unicode "MICRO SIGN")))]])

  (defun ns-lock-screen ()
    "Lock Screen on MacOS"
    (interactive)
    (start-process-shell-command
     "ScreenSaver" nil
     "open -a ScreenSaverEngine"))

  (transient-define-prefix transient-emacs-launcher ()
    "Launch (Emacs) apps"
    [["Apps"
      ;; ("e" "Elfeed - RSS/Atom Newsreader" elfeed)
      ;; ("t" "Transmission - Torrent" transmission)
      ("m" "mu4e - Mail" mu4e)
      ("p" "proced" proced)
      ;; ("v" "VPN" ovpn)
      ]
     ["Utils"
      ("c" "calc - Quick calc" quick-calc)
      ;; ("d" "docker" docker)
      ("C" "calendar" calendar)
      ("T" "time - Display world time" world-clock)
      ;; ("s" "Systemctl" hydra-systemctl)
      ]
     ["Misc"
      ("a" "Ansi Terminal" ansi-term)
      ;; ("b" "brain.fm - Stream music" brain-fm-play)
      ("E" "elisp-index-search" elisp-index-search)
      ;; ("S" "Screenshot with scrot" scrot)
      ;; ("w" "woman - Man page viewer" woman)
      ("M" "Man page viewer" man)
      ;; ("y" "YouTube - Open dired buffer" (lambda () (interactive) (dired youtube-dl-directory)))
      ("z" "Zone - Screensaver" zone)]
     ["External"
      ;; ("K" "Kitty" (start-process-lambda "kitty"))
      ("k" "Kitty" (lambda ()
                     (interactive)
                     (start-process-shell-command "kitty" nil "kitty")))
      ("g" "Ghostty" (lambda ()
                       (interactive)
                       (start-process-shell-command "Ghostty" nil "open -a Ghostty")))
      ("L" "Lock Screen" ns-lock-screen)
      ("S" "Sleep" (lambda ()
                     (interactive)
                     (start-process-shell-command "pmset" nil "pmset sleepnow")))]]))

;; Do action that normally works on a region to the whole line if no region active.
;; That way you can just C-w to copy the whole line for example.
(use-package whole-line-or-region
  :hook (after-init . whole-line-or-region-global-mode))

(use-package aggressive-indent
  :hook ((emacs-lisp-mode lisp-mode hy-mode clojure-mode css js-mode) . aggressive-indent-mode)
  :config
  (setq aggressive-indent-region-function
        (lambda (start end)
          "indent-region but without the annoying =reporter= message."
          (let ((inhibit-message t))
            (indent-region start end)))))

(use-package alert
  :defer t
  :config
  ;; send alerts by default to D-Bus or use native OSX messages on Mac
  (setq alert-default-style (if (eq system-type 'darwin) 'osx-notifier 'notifications)))

(use-package smartparens
  :hook ((
          emacs-lisp-mode lisp-mode lisp-data-mode clojure-mode cider-repl-mode hy-mode
          prolog-mode go-mode go-ts-mode cc-mode python-mode
          typescript-mode json-mode json-ts-mode javascript-mode java-mode
          java-ts-mode typescript-ts-mode python-ts-mode js-ts-mode json-ts-mode
          ) . smartparens-strict-mode)
  :bind (:map smartparens-mode-map
              ;; This is the paredit mode map minus a few key bindings
              ;; that I use in other modes (e.g. M-?)
              ("C-M-f" . sp-forward-sexp) ;; navigation
              ("C-M-b" . sp-backward-sexp)
              ("C-M-u" . sp-backward-up-sexp)
              ("C-M-d" . sp-down-sexp)
              ("C-M-p" . sp-backward-down-sexp)
              ("C-M-n" . sp-up-sexp)
              ("C-w" . whole-line-or-region-sp-kill-region)
              ("M-s" . sp-splice-sexp) ;; depth-changing commands
              ("M-r" . sp-splice-sexp-killing-around)
              ("M-(" . sp-wrap-round)
              ("C-)" . sp-forward-slurp-sexp) ;; barf/slurp
              ("M-0" . sp-forward-slurp-sexp)
              ("C-<right>" . sp-forward-slurp-sexp)
              ("C-}" . sp-forward-barf-sexp)
              ("C-<left>" . sp-forward-barf-sexp)
              ("C-(" . sp-backward-slurp-sexp)
              ("M-9" . sp-backward-slurp-sexp)
              ("C-M-<left>" . sp-backward-slurp-sexp)
              ("C-{" . sp-backward-barf-sexp)
              ("C-M-<right>" . sp-backward-barf-sexp)
              ("M-S" . sp-split-sexp))
  :config
  (require 'smartparens-config)
  (setq sp-base-key-bindings 'paredit)
  (setq sp-autoskip-closing-pair 'always)

  ;; Always highlight matching parens
  (show-smartparens-global-mode)
  (setq blink-matching-paren nil)  ;; Don't blink matching parens

  (defun whole-line-or-region-sp-kill-region (prefix)
    "Call `sp-kill-region' on region or PREFIX whole lines."
    (interactive "*p")
    (whole-line-or-region-wrap-beg-end 'sp-kill-region prefix))

  ;; Create keybindings to wrap symbol/region in pairs (from prelude)
  (defun prelude-wrap-with (s)
    "Create a wrapper function for smartparens using S."
    `(lambda (&optional arg)
       (interactive "P")
       (sp-wrap-with-pair ,s)))
  (define-key prog-mode-map (kbd "M-(") (prelude-wrap-with "("))
  (define-key prog-mode-map (kbd "M-[") (prelude-wrap-with "["))
  (define-key prog-mode-map (kbd "M-{") (prelude-wrap-with "{"))
  (define-key prog-mode-map (kbd "M-\"") (prelude-wrap-with "\""))
  (define-key prog-mode-map (kbd "M-'") (prelude-wrap-with "'"))
  (define-key prog-mode-map (kbd "M-`") (prelude-wrap-with "`"))

  ;; Don't include semicolon ; when slurping
  (add-to-list 'sp-sexp-suffix '(java-mode regexp ""))
  (add-to-list 'sp-sexp-suffix '(java-ts-mode regexp "")))

(use-package symbol-overlay
  :hook ((prog-mode html-mode css-mode) . symbol-overlay-mode)
  :bind (("C-c s" . symbol-overlay-put)
         :map symbol-overlay-mode-map
         ("M-n" . symbol-overlay-jump-next)
         ("M-p" . symbol-overlay-jump-prev)
         :map symbol-overlay-map
         ("M-n" . symbol-overlay-jump-next)
         ("M-p" . symbol-overlay-jump-prev)
         ("C-c C-s r" . symbol-overlay-rename)
         ("C-c C-s k" . symbol-overlay-remove-all)
         ("C-c C-s q" . symbol-overlay-query-replace)
         ("C-c C-s t" . symbol-overlay-toggle-in-scope)
         ("C-c C-s n" . symbol-overlay-jump-next)
         ("C-c C-s p" . symbol-overlay-jump-prev))
  :init (setq symbol-overlay-scope t)
  :config
  ;;(set-face-background 'symbol-overlay-temp-face "gray30")
  ;; Remove all default bindings
  (setq symbol-overlay-map (make-sparse-keymap)))

(use-package avy
  :bind ("C-;" . avy-goto-char-timer)
  :config
  (setq avy-background t)
  (setq avy-style 'at-full)
  (setq avy-timeout-seconds 0.2))

(use-package expand-region
  :bind (([remap set-mark-command] . set-mark-or-expand-region))
  :config
  ;; Idea from the `smart-region' package, but a simpler version.
  (defun set-mark-or-expand-region (arg)
    "This function initially acts like `set-mark', but when there is a
selectred region active it calls `er/expand-region'.
So you can press it once to activate a region and multiple times in a
row to expand the region as necessary."
    (interactive "P")
    (if (region-active-p)
        (call-interactively #'er/expand-region)
      (setq this-command 'set-mark-command)
      (call-interactively 'set-mark-command))))

(use-package selected
  :hook ((text-mode prog-mode) . selected-minor-mode)
  :init (defvar selected-org-mode-map (make-sparse-keymap))
  :bind (:map selected-keymap
              ("q" . selected-off)
              ("u" . upcase-region)
              ("d" . downcase-region)
              ("w" . count-words-region)
              ("m" . apply-macro-to-region-lines)
              ;; multiple cursors
              ("v" . mc/vertical-align-with-space)
              ("a" . mc/mark-all-dwim)
              ("A" . mc/mark-all-like-this)
              ("m" . mc/mark-more-like-this-extended)
              ("p" . mc/mark-previous-like-this)
              ("P" . mc/unmark-previous-like-this)
              ("S" . mc/skip-to-previous-like-this)
              ("n" . mc/mark-next-like-this)
              ("N" . mc/unmark-next-like-this)
              ("s" . mc/skip-to-next-like-this)
              ("r" . mc/edit-lines)
              :map selected-org-mode-map
              ("t" . org-table-convert-region)))

(use-package multiple-cursors
  :bind (("C-c m" . mc/mark-all-dwim)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         :map mc/keymap
         ("C-x 1" . mc/insert-numbers)
         ("C-x v" . mc/vertical-align-with-space)
         ("C-x n" . mc-hide-unmatched-lines-mode)
         ("M-T"   . mc/reverse-regions)
         ("C-,"   . mc/unmark-next-like-this)
         ("C-."   . mc/skip-to-next-like-this))
  :config
  (with-eval-after-load 'multiple-cursors-core
    ;; Immediately load mc list, otherwise it will show as
    ;; changed as empty in my git repo
    (mc/load-lists)))

(use-package edit-indirect
  :bind (("C-c '" . edit-indirect-dwim)
         :map edit-indirect-mode-map
         ("C-x n" . edit-indirect-commit))
  :config
  (defvar edit-indirect-string nil)
  (put 'edit-indirect-string 'end-op
       (lambda ()
         (while (nth 3 (syntax-ppss))
           (forward-char))
         (backward-char)))
  (put 'edit-indirect-string 'beginning-op
       (lambda ()
         (let ((forward (nth 3 (syntax-ppss))))
           (while (nth 3 (syntax-ppss))
             (backward-char))
           (when forward
             (forward-char)))))

  (defun edit-indirect-dwim (beg end &optional display-buffer)
    "DWIM version of edit-indirect-region.
When region is selected, behave like `edit-indirect-region'
but when no region is selected and the cursor is in a 'string' syntax
mark the string and call `edit-indirect-region' with it."
    (interactive
     (if (or (use-region-p) (not transient-mark-mode))
         (prog1 (list (region-beginning) (region-end) t)
           (deactivate-mark))
       (if (nth 3 (syntax-ppss))
           (list (beginning-of-thing 'edit-indirect-string)
                 (end-of-thing 'edit-indirect-string)
                 t)
         (user-error "No region marked and not inside a string."))))
    (edit-indirect-region beg end display-buffer))

  (defvar edit-indirect-guess-mode-history nil)
  (defun edit-indirect-guess-mode-fn (_buffer _beg _end)
    (let* ((lang (completing-read "Mode: "
                                  '("gfm" "rst"
                                    "emacs-lisp" "clojure" "python" "sql"
                                    "typescript" "js2" "web" "scss")
                                  nil nil nil 'edit-indirect-guess-mode-history))
           (mode-str (concat lang "-mode"))
           (mode (intern mode-str)))
      (unless (functionp mode)
        (error "Invalid mode `%s'" mode-str))
      (funcall mode)))
  (setq edit-indirect-guess-mode-function #'edit-indirect-guess-mode-fn))

(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode lisp-mode hy-mode clojure-mode cider-repl-mode sql-mode) . rainbow-delimiters-mode))

(use-package form-feed
  :hook (prog-mode . form-feed-init)
  :config
  (defun form-feed-init ()
    (make-local-variable 'form-feed--font-lock-keywords)
    (add-to-list 'form-feed--font-lock-keywords
                 `(,(concat comment-start-skip "=\\{40,\\}") 0 form-feed--font-lock-face t))
    (add-to-list 'form-feed--font-lock-keywords
                 `(,(concat comment-start-skip "-\\{40,\\}") 0 form-feed--font-lock-face t))
    (form-feed-mode)))

(use-package ipinfo
  :defer t)

;; * Mail and News

(use-package mm-decode
  :defer t
  :config
  ;; View JSON file attachements inline in mu4e/gnus
  (defun mm-display-json-inline (handle)
    "Show a JSON file from HANDLE inline."
    (mm-display-inline-fontify handle 'json-ts-mode))

  (add-to-list 'mm-inline-media-tests '("application/json" mm-display-json-inline identity))
  (add-to-list 'mm-inlined-types "application/json"))

(use-package  gnus-dired
  :after mu4e
  :hook (dired-mode . turn-on-gnus-dired-mode)
  :config
  ;; From the mu4e manual https://www.djcbsoftware.nl/code/mu/mu4e/Attaching-files-with-dired.html
  ;; make the `gnus-dired-mail-buffers' function also work on
  ;; message-mode derived modes, such as mu4e-compose-mode
  (defun gnus-dired-mail-buffers ()
    "Return a list of active message buffers."
    (let (buffers)
      (save-current-buffer
        (dolist (buffer (buffer-list t))
          (set-buffer buffer)
          (when (and (derived-mode-p 'message-mode)
                     (null message-sent-message-via))
            (push (buffer-name buffer) buffers))))
      (nreverse buffers)))

  (setq gnus-dired-mail-mode 'mu4e-user-agent))

(use-package message-view-patch
  :hook (gnus-part-display . message-view-patch-highlight))

(use-package org-msg
  :defer t
  :config
  (setq org-msg-options "html-postamble:nil H:5 num:nil ^:{} toc:nil author:nil email:nil \\n:t"
        org-msg-startup "hidestars indent inlineimages"
        org-msg-greeting-name-limit 3
        org-msg-convert-citation t
        org-msg-default-alternatives '((new           . (text html))
                                       (reply-to-html . (text html))
                                       (reply-to-text . (text)))))


;; Install mu with brew and not latest master with elpaca
(use-package mu4e
  ;; Open mu4e with the 'Mail' key (if your keyboard has one)
  :bind (("<XF86Mail>" . mu4e)
         :map mu4e-main-mode-map
         ("U" . mu4e-update-index-nonlazy)
         ;; ("U" . mu4e-update-mail-and-index-background)
         :map mu4e-headers-mode-map
         ("TAB" . mu4e-headers-next-unread)
         ("J" . mu4e-move-to-junk)
         ("d" . my-move-to-trash)
         ("D" . my-move-to-trash)
         ("M" . mu4e-headers-mark-all-unread-read) ; Mark all as read
         :map mu4e-search-minor-mode-map
         ("P" . mu4e-view-headers-prev)
         :map mu4e-view-mode-map
         ;; ("A" . mu4e-view-attachment-action)
         ;; ("M-o" . ace-link-mu4e)
         ;; ("o" . ace-link-mu4e)
         ("n" . mu4e-scroll-up)
         ("p" . mu4e-scroll-down)
         ("N" . mu4e-view-headers-next)
         ("P" . mu4e-view-headers-prev)
         ("J" . mu4e-move-to-junk)
         ("d" . my-move-to-trash)
         ("D" . my-move-to-trash))
  :hook (message-send . message-warn-if-no-attachments)
  :init
  ;; Prefer text over html/ritchtext
  (setq mm-discouraged-alternatives '("text/html" "text/richtext"))

  ;; Use completing-read (vertico) instead of ido or mu4e's own version
  (setq mu4e-read-option-use-builtin nil
        mu4e-completing-read-function 'completing-read)

  ;; set mu4e as default mail client
  (setq mail-user-agent 'mu4e-user-agent)

  ;; Always use local smtp server (msmtp in my case) to send mails
  (setq send-mail-function 'sendmail-send-it
        sendmail-program (executable-find "msmtp")
        mail-specify-envelope-from t
        mail-envelope-from 'header)
  :config
  (require 'mu4e-contrib)  ;; Define some extra commands like mark-all-unread-read

  ;; Display the main window in the current window instead of making it full screen
  (add-to-list
   'display-buffer-alist
   '("*mu4e-main*" (display-buffer-same-window)))

  (defun mu4e-update-mail-and-index-background ()
    "Call `mu4e-update-mail-and-index' to run in background."
    (interactive)
    (mu4e-update-mail-and-index t))

  ;; gmail delete == move mail to trash folder
  (fset 'my-move-to-trash "mt")

  ;; Move mails to spam/junk folder
  (fset 'mu4e-move-to-junk "mj")

  ;; Fix mu4e highlighting in moe-dark theme
  (set-face-attribute 'mu4e-header-highlight-face nil :background "#626262" :foreground "#eeeeee")

  ;;; Save attachment (this can also be a function)
  (setq mu4e-attachment-dir "~/Downloads"
        mu4e-confirm-quit nil
        mu4e-view-scroll-to-next nil)

  ;; Show additional user-agent header
  (setq-default mu4e-view-fields
                '(:from :to :cc :subject :flags :date :maildir :user-agent :mailing-list
                        :tags :attachments :signature :decryption))

  ;; Don't show related messages by default.
  ;; Activate with 'a s' (mu4e action - show thread) on demand.
  (setq mu4e-search-include-related nil)

  ;; Don't spam the minibuffer with 'Indexing...' messages
  (setq mu4e-hide-index-messages t)

  ;; Always update in background otherwise mu4e manipulates the window layout
  ;; when the update is finished but this breaks when we switch exwm workspaces
  ;; and the current focused window just gets hidden.
  (setq mu4e-index-update-in-background t)

  ;; Allow using temp-files for optimizing mu <-> mu4e communication.
  (setq mu4e-mu-allow-temp-file t)

  ;; update database every ten minutes
  ;; (setq  mu4e-update-interval (* 60 10))
  (setq  mu4e-update-interval nil)

  ;; We do a full index (that verify integrity) with a systemd job
  ;; Go fast inside emacs
  (setq mu4e-index-cleanup nil)   ;; don't do a full cleanup check
  (setq mu4e-index-lazy-check t)  ;; don't consider up-to-date dirs

  ;; Change the default threading characters to some "nicer" looking chars
  (setq mu4e-headers-thread-child-prefix '("├>" . "├→ ")
        mu4e-headers-thread-last-child-prefix '("└>" . "└→ ")
        mu4e-headers-thread-connection-prefix '("│" . "│ ")
        mu4e-headers-thread-orphan-prefix '("┬>" . "┬→ ")
        mu4e-headers-thread-single-orphan-prefix '("─>" . "─→ "))

  ;; Also change to some nicer characters for marks
  (setq mu4e-use-fancy-chars t
        mu4e-headers-new-mark       '("N" . "📨")
        mu4e-headers-flagged-mark   '("F" . "📍")
        mu4e-headers-passed-mark    '("P" . "❯")
        mu4e-headers-replied-mark   '("R" . "❮")
        mu4e-headers-seen-mark      '("S" . "")
        mu4e-headers-trashed-mark   '("T" . "🗑️")
        mu4e-headers-attach-mark    '("a" . "📎")
        mu4e-headers-encrypted-mark '("x" . "🔒")
        mu4e-headers-signed-mark    '("s" . "🔑")
        mu4e-headers-unread-mark    '("u" . "📫")
        mu4e-headers-calendar-mark  '("c" . "📅"))

  ;; rename files when moving
  ;; NEEDED FOR MBSYNC
  (setq mu4e-change-filenames-when-moving t)

  ;; start with the first (default) context;
  ;; default is to ask-if-none (ask when there's no context yet, and none match)
  (setq mu4e-context-policy 'pick-first)

  ;; compose with the current context is no context matches;
  ;; default is to ask
  (setq mu4e-compose-context-policy nil)

  ;; don't keep message buffers around
  (setq message-kill-buffer-on-exit t)

  (defun dakra-mu4e-update-index (&optional alert?)
    "Like `mu4e-update-index' but also update modeline and optionally send an alert message."
    (mu4e-update-index)
    (mu4e--modeline-update)
    (when alert?
      (alert "You've got new mails" :title "New Mail")))

  ;; If there's 'attach' 'file' 'pdf' in the message warn when sending w/o attachment
  ;; From http://mbork.pl/2016-02-06_An_attachment_reminder_in_mu4e
  (defun message-attachment-present-p ()
    "Return t if an attachment is found in the current message."
    (save-excursion
      (save-restriction
        (widen)
        (goto-char (point-min))
        (when (search-forward "<#part" nil t) t))))

  (defvar message-attachment-intent-re
    (regexp-opt '("attach" "pdf" "anhang" "angehängt" "angehaengt"))
    "A regex which - if found in the message, and if there is no
attachment - should launch the no-attachment warning.")

  (defvar message-attachment-reminder
    "Are you sure you want to send this message without any attachment? "
    "The default question asked when trying to send a message
containing `message-attachment-intent-re' without an
actual attachment.")

  (defun message-warn-if-no-attachments ()
    "Ask the user if he wants to send the message even though
there are no attachments.
Should be added to `message-send-hook'."
    (when (and (save-excursion
                 (save-restriction
                   (widen)
                   (goto-char (point-min))
                   (re-search-forward message-attachment-intent-re nil t)))
               (not (message-attachment-present-p)))
      (unless (y-or-n-p message-attachment-reminder)
        (keyboard-quit)))))

(use-package consult-mu
  :after mu4e
  :bind (:map mu4e-main-mode-map
              ("s" . consult-mu-dynamic))
  :config
  (setq consult-mu-maxnum 300
        consult-mu-mark-viewed-as-read nil))

(use-package consult-mu-compose
  :after mu4e
  :config
  (require 'consult-mu-compose-embark)
  (setq consult-mu-compose-preview-key "M-o"))

(use-package consult-mu-contacts
  :after mu4e
  :config
  (require 'consult-mu-contacts-embark))



;; * Programming languages

(use-package elisp-mode
  :bind (:map emacs-lisp-mode-map
              ("C-c C-c" . eval-defun)
              ("C-c C-b" . eval-buffer)
              ("C-c C-k" . eval-buffer)
              ("C-c C-;"   . eval-print-as-comment)
              :map lisp-interaction-mode-map  ; Scratch buffer
              ("C-c C-c" . eval-defun)
              ("C-c C-b" . eval-buffer)
              ("C-c C-k" . eval-buffer)
              ("C-c C-;"   . eval-print-as-comment))
  :config
  (defvar eval-print-as-comment-prefix ";;=> ")

  (defun eval-print-as-comment (&optional arg)
    (interactive "P")
    (let ((start (point)))
      (eval-print-last-sexp arg)
      (save-excursion
        (goto-char start)
        (save-match-data
          (re-search-forward "[[:space:]\n]*" nil t)
          (insert eval-print-as-comment-prefix))))))

(use-package clojure-mode
  :bind (:map clojure-mode-map
              ("C-M-;" . clojure-toggle-ignore))
  :config
  ;; Eval top level forms inside comment forms instead of the comment form itself
  (setq clojure-toplevel-inside-comment-form t)

  ;; Don't align the body of clojure.core/match with the first argument
  (put-clojure-indent 'match 1))

;; Only deps: queue, parseedn; parseclj, sesman
(use-package cider
  :bind (:map cider-mode-map
              ("<f6>" . cider-scratch-project)
              ("M-?" . cider-maybe-clojuredocs)
              ("C-c C-o" . -cider-find-and-clear-repl-and-result-output)
              :map cider-repl-mode-map
              ("M-?" . cider-doc))
  :config
  (setq
   ;; By default prefer clojure-cli build-tool when jacking in
   cider-preferred-build-tool 'clojure-cli
   ;; and set the :dev and :licp alias
   cider-clojure-cli-aliases ":dev"
   ;; Always reuse a dead REPS without prompt when it's the only option
   cider-reuse-dead-repls 'auto
   ;; Automatically download source artifacts for 3rd-party Java classes
   cider-download-java-sources t
   ;; Only show cider eval results as overlay and not in the minibuffer
   cider-use-overlays t
   ;; Use `moon' spinner that looks nice and doesn't take as much space as the progress bar
   cider-eval-spinner-type 'moon
   ;; Store more items in repl history (default 500)
   cider-repl-history-size 2000
   ;; When loading the buffer (C-c C-k) save first without asking
   cider-save-file-on-load t
   ;; Don't show cider help text in repl after jack-in
   cider-repl-display-help-banner nil
   ;; Don't focus repl after sending somehint to there from another buffer
   cider-switch-to-repl-on-insert nil
   ;; Eval automatically when insreting in the repl (e..g. C-c C-j d/e) (unless called with prefix)
   cider-invert-insert-eval-p t
   ;; Show error as overlay instead of the buffer (buffer is generated anyway in case it's needed)
   cider-show-error-buffer 'except-in-repl
   ;; If we set `cider-show-error-buffer' to non-nil,
   ;; don't focus error buffer when error is thrown
   cider-auto-select-error-buffer nil
   ;; Don't focus inspector after evaluating something
   cider-inspector-auto-select-buffer nil
   ;; Don't show tooltip with mouse hover
   cider-use-tooltips nil
   ;; Display context dependent info in the eldoc where possible.
   cider-eldoc-display-context-dependent-info t
   ;; Don't pop to the REPL buffer on connect
   ;; Create and display the buffer, but don't focus it.
   cider-repl-pop-to-buffer-on-connect 'display-only
   ;; Just use symbol under point and don't prompt for symbol in e.g. cider-doc.
   cider-prompt-for-symbol nil
   ;; Use clj-reload instead of clojure.tools.namespace
   cider-ns-code-reload-tool 'clj-reload)

  ;; I basically never connect to a remote host nrepl, so skip the host question on connect
  (defun cider--completing-read-host (hosts)
    '("localhost"))

  ;; Display cider-scratch buffer in the same window
  (add-to-list
   'display-buffer-alist
   '("*cider-scratch.*" (display-buffer-reuse-window
                         display-buffer-same-window)))

  (setq cider-scratch-initial-message
        "(ns scratch
  (:require [clojure.java.io :as io]
            [clojure.pprint :as pprint]
            [clojure.set :as set]
            [clojure.string :as str]))
")

  ;; Output to the cider-result buffer
  ;; This needs my personal WIP fork: https://github.com/dakra/cider/tree/wip
  ;; (setq cider-interactive-eval-output-destination 'cider-result-buffer)

  (defun -cider-find-and-clear-repl-and-result-output (&optional clear-repl)
    "Like `cider-find-and-clear-repl-output' but additionally clear
the *cider-result* buffer."
    (interactive "P")
    (cider-find-and-clear-repl-output clear-repl)
    (let ((buf (get-buffer cider-result-buffer)))
      (when (and buf (> (buffer-size buf) 0))  ;; Only clear when buffer exists and is not empty
        (save-excursion
          (with-current-buffer buf
            (let ((inhibit-read-only t))
              (if clear-repl  ;; Remove all output when called with prefix
                  (delete-region (point-min) (point-max))

                ;; Only remove output of the "cell" where the cursor currently is
                (goto-char (or (search-backward "\f" nil t) (point-min))) ;; Search the beginning
                (forward-sexp)  ;; Skip input sexp
                (forward-line 2)  ;; Skip the =*ns* <buffer>:line-ns=> info arrow
                (beginning-of-line)
                (let ((start (point)))
                  (search-forward "\f" nil t)
                  (backward-char)
                  (delete-region start (point)))
                (insert-before-markers
                 (propertize ";; output cleared\n" 'font-lock-face 'font-lock-comment-face)))))))))

  (defun cider-maybe-clojuredocs (&optional arg)
    "Like `cider-doc' but call `cider-clojuredocs' when invoked with prefix arg in `clojure-mode'."
    (interactive "P")
    (if (and arg (or (eq major-mode 'clojure-mode)
                     (eq major-mode 'clojurec-mode)
                     (eq major-mode 'cider-clojure-interaction-mode)))
        (cider-clojuredocs)
      (cider-doc)))

  (require 's)
  (defun -cider-check-alias-fn (alias)
    "Return predicate function that check if cider contains alias string ALIAS."
    (lambda (&rest _)
      (and cider-clojure-cli-aliases
           (s-contains? alias cider-clojure-cli-aliases))))

  ;; Inject flow-storm middleware in cider-jack-in when the `:flow-storm' alias is set
  (add-to-list 'cider-jack-in-nrepl-middlewares
               `("flow-storm.nrepl.middleware/wrap-flow-storm" :predicate ,(-cider-check-alias-fn ":flow-storm")))

  ;; Inject portal middleware in cider-jack-in when the `:portal' alias is set
  (add-to-list 'cider-jack-in-nrepl-middlewares
               `("portal.nrepl/wrap-portal" :predicate ,(-cider-check-alias-fn ":portal")))

  ;; Inject reveal middleware in cider-jack-in when the `:reveal' alias is set
  (add-to-list 'cider-jack-in-nrepl-middlewares
               `("vlaaad.reveal.nrepl/middleware" :predicate ,(-cider-check-alias-fn ":reveal")))

  ;; Inject shadowcljs nrepl middleware in cider-jack-in when the `:cljs' alias is set
  (add-to-list 'cider-jack-in-nrepl-middlewares
               `("shadow.cljs.devtools.server.nrepl/middleware" :predicate ,(-cider-check-alias-fn ":cljs")))

  ;; Update classpath without restarting the repl
  ;; Requires lambdaisland.classpath which is under :licp alias in my global deps.edn
  (defun cider-update-deps-classpath ()
    "Update classpath from deps.edn with lambdaisland.classpath."
    (interactive)
    ;; FIXME: Catch cider error and just display `user-error' when licp not found
    (cider-interactive-eval "(require 'lambdaisland.classpath)")
    (let* ((deps-path (concat (project-root (project-current t)) "deps.edn"))
           (deps-str (with-temp-buffer
                       (insert-file-contents deps-path)
                       (buffer-string))))
      (cider-interactive-eval
       (concat "(lambdaisland.classpath/update-classpath! '{:extra " deps-str "})"))))

  ;; XXX: Refactor clerk functions in own package
  (defun clerk-serve ()
    "Serve clerk notebooks."
    (interactive)
    (cider-interactive-eval "(nextjournal.clerk/serve! {:browse? true})"))

  (defun clerk-tap-inspector ()
    "Open tap inspector notebook to let Clerk show a tap> stream."
    (interactive)
    (message "Show tap> stream in clerk.")
    (cider-interactive-eval "(nextjournal.clerk/show! 'nextjournal.clerk.tap)"))

  (defun clerk-tap-table (&optional full-p)
    "Evaluate and tap the expression preceding point as a clerk table."
    (interactive "P")
    (let ((tapped-form (concat "(clojure.core/doto "
                               (cider-last-sexp)
                               " (->> "
                               "(nextjournal.clerk/table "
                               (if full-p "{:nextjournal.clerk/width :full}" "")
                               ") clojure.core/tap>))")))
      (cider-interactive-eval tapped-form
                              nil
                              nil
                              (cider--nrepl-pr-request-map))))

  (defun clerk-tap-vega-lite (&optional wide-p)
    "Evaluate and tap the expression preceding point as a vega lite chart.
If invoked with WIDE-P, make the chart ::clerk/width :wide"
    (interactive "P")
    (let ((tapped-form (concat "(clojure.core/doto "
                               (cider-last-sexp)
                               " (->> "
                               "(nextjournal.clerk/vl "
                               (if wide-p "{:nextjournal.clerk/width :wide}" "")
                               ") clojure.core/tap>))")))
      (cider-interactive-eval tapped-form
                              nil
                              nil
                              (cider--nrepl-pr-request-map))))
  (defun clerk-build ()
    "Build static html for the current clerk notebook."
    (interactive)
    (message "Building static page")
    (when-let* ((filename (buffer-file-name)))
      (let ((root (project-root (project-current t))))
        (cider-interactive-eval
         (concat "(nextjournal.clerk/build! {:paths [\""
                 (file-relative-name filename root) "\"]})")))))

  (defun clerk-show ()
    "Show buffer in clerk."
    (interactive)
    (message "Show buffer in clerk.")
    (when-let* ((filename (buffer-file-name)))
      (cider-interactive-eval
       (concat "(nextjournal.clerk/show! \"" filename "\")"))))

  (defun clerk-save-and-show ()
    "Save buffer and show in clerk."
    (interactive)
    (save-buffer)
    (clerk-show))

  (define-minor-mode clerk-mode
    "A mode that calls `clerk-show' after save and adds a keybinding to `<M-return>'."
    :lighter " clerk"
    :keymap `((,(kbd "<M-return>") . clerk-save-and-show)
              (,(kbd "<C-c t>") . clerk-tap-table))
    (if clerk-mode
        (add-hook 'after-save-hook #'clerk-show 100 t)
      (remove-hook 'after-save-hook #'clerk-show t)))

  ;; jack-in for babashka
  ;; Code mostly from corgi: https://github.com/lambdaisland/corgi-packages/blob/main/corgi-clojure/corgi-clojure.el#L192-L211
  (defun cider-jack-in-babashka (&optional project-dir)
    "Start a utility CIDER REPL backed by Babashka, not related to a specific project."
    (interactive)
    (let ((project-dir (or project-dir (project-root (project-current t)))))
      (nrepl-start-server-process
       project-dir
       "bb --nrepl-server 0"
       (lambda (server-buffer)
         (cider-nrepl-connect
          (list :repl-buffer server-buffer
                :repl-type 'clj
                :host (plist-get nrepl-endpoint :host)
                :port (plist-get nrepl-endpoint :port)
                :project-dir project-dir
                :session-name "babashka"
                :repl-init-function (lambda ()
                                      (setq-local cljr-suppress-no-project-warning t
                                                  cljr-suppress-middleware-warnings t)
                                      (rename-buffer "*babashka-repl*")))))))))

(use-package clj-refactor
  :hook (clojure-mode . clj-refactor-mode)
  :bind (:map cider-mode-map
              ("C-c C-r n a" . cljr-add-missing-libspec))
  :config
  ;; Allow a few more chars each row in namespace (default 72)
  (setq cljr-print-right-margin 90)

  (dolist (magic-require '(("aero"     . "aero.core")
                           ("clerk"    . "nextjournal.clerk")
                           ("csv"      . "clojure.data.csv")
                           ("edn"      . "clojure.edn")
                           ("fs"       . "babashka.fs")
                           ("http"     . "babashka.http-client")
                           ("jdbc"     . "next.jdbc")
                           ("transit"  . "cognitect.transit")
                           ("walk"     . "clojure.walk")
                           ("pprint"   . "clojure.pprint")
                           ("http"     . "babashka.http-client")
                           ("reagent"  . "reagent.core")
                           ("re-frame" . "re-frame.core")
                           ("tick"     . "tick.core")))
    (add-to-list 'cljr-magic-require-namespaces magic-require)))

(use-package babashka
  :defer t)

;; (use-package nrepl-client
;;   :config
;;   ;; Give sync requests a bit more time to respond (default 10s)
;;   ;; Especially when using with ejc-sql and e.g. Athena queries
;;   (setq nrepl-sync-request-timeout 90))

(use-package eglot
  :defer t
  :config
  ;; XXX Check https://zubanls.com/blog/ for updates (no auto imports, docstrings yet)
  ;; (add-to-list 'eglot-server-programs
  ;;              `((python-ts-mode python-mode) . ("uv" "tool" "run" "zuban" "server")))
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode)
                 . ("uv" "tool" "run" "--from" "basedpyright" "basedpyright-langserver" "--stdio")))

  (setq eglot-extend-to-xref t
        eglot-autoshutdown t))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (((java-mode java-ts-mode) . lsp-deferred)
         (lsp-completion-mode . lsp-mode-setup-orderless))
  :bind (:map lsp-mode-map
              ("C-c C-a" . lsp-execute-code-action)
              ("M-." . lsp-find-definition-other)
              ("M-," . lsp-find-references-other))
  :init (setq lsp-keymap-prefix nil)  ; Don't map the lsp keymap to any key
  :config
  (defcustom lsp-clients-vtsls-server "vtsls"
    "The vtsls executable to use.
Leave as just the executable name to use the default behavior of
finding the executable with variable `exec-path'."
    :group 'lsp-mode
    :risky t
    :type 'file)

  (defcustom lsp-clients-vtsls-server-args '("--stdio")
    "Extra arguments for starting the vtsls language server."
    :group 'lsp-mode
    :risky t
    :type '(repeat string))

  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection (lambda ()
                                                            (cons lsp-clients-vtsls-server
                                                                  lsp-clients-vtsls-server-args)))
                    :activation-fn #'lsp-typescript-javascript-tsx-jsx-activate-p
                    :priority -1
                    :completion-in-comments? t
                    :server-id 'vtsls))

  ;; Shutdown lsp-server when all buffers associated with that server are closed
  (setq lsp-keep-workspace-alive nil)

  (require 'lsp-completion)
  (setq lsp-completion-provider :none)  ;; we use Corfu

  (defun lsp-mode-setup-orderless ()
    (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
          '(orderless)))

  (setq lsp-enable-on-type-formatting nil
        lsp-enable-indentation nil
        lsp-enable-snippet nil
        lsp-semantic-tokens-enable t)

  (defun lsp-find-definition-other (other?)
    "Like `lsp-find-definition' but open in other window when called with prefix arg."
    (interactive "P")
    (dogears-remember)
    (if other?
        (lsp-find-definition :display-action 'window)
      (lsp-find-definition)))
  (defun lsp-find-references-other (other?)
    "Like `lsp-find-references' but open in other window when called with prefix arg."
    (interactive "P")
    (dogears-remember)
    (if other?
        (lsp-find-references :display-action 'window)
      (lsp-find-references)))

  ;; Don't watch `build' directory for file changes
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]build\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.aider\\.tags\\.cache\\.v3\\'")

  ;; (require 'yasnippet)  ;; We use yasnippet for lsp snippet support
  (setq-default flycheck-disabled-checkers '(c/c++-clang c/c++-cppcheck c/c++-gcc)))

(use-package lsp-ui
  :after lsp-mode
  :bind (:map lsp-mode-map
              ("M-?" . lsp-ui-doc-toggle))
  :config
  (defun lsp-ui-doc-toggle ()
    "Shows or hides lsp-ui-doc popup."
    (interactive)
    (if lsp-ui-doc--bounds
        (lsp-ui-doc-hide)
      (lsp-ui-doc-show)))

  (setq lsp-ui-doc-include-signature t
        lsp-ui-doc-position 'at-point)

  ;; Deactivate most of the annoying "fancy features"
  (setq lsp-headerline-breadcrumb-enable nil
        lsp-ui-doc-enable nil
        lsp-lens-enable t  ;; "1 reference" etc at the end of the line
        lsp-ui-sideline-enable nil
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-symbol nil))

(use-package lsp-treemacs
  :disabled t
  :after lsp-mode
  :config
  ;; Enable bidirectional synchronization of lsp workspace folders and treemacs
  (lsp-treemacs-sync-mode))

(use-package lsp-pyright
  :after lsp-mode
  :hook (python-ts-mode . lsp-deferred)
  :config
  (setq lsp-disabled-clients '(ruff))
  (setq lsp-pyright-language-server-command "basedpyright"
        lsp-pyright-langserver-command-args '("tool" "run" "--from" "basedpyright" "basedpyright-langserver" "--stdio")))

;; Onlye deps: requests, deferred, (lsp-treemacs)
(use-package lsp-java
  :after lsp-mode
  :hook (((java-mode java-ts-mode conf-javaprop-mode) . lsp-java-boot-lens-mode))
  :init
  ;; Set java vmargs in init so we can use with-eval-after-load in personal.el to call `add-to-list'.
  (setq lsp-java-vmargs
        '("-noverify"
          "-XX:+UseParallelGC"
          "-XX:GCTimeRatio=4"
          "-XX:AdaptiveSizePolicyWeight=90"
          "-XX:+UseStringDeduplication"
          "-Dsun.zip.disableMemoryMapping=true"
          "-Xmx4G"
          "-Xms256m"))
  :config
  ;; Use Google style formatting by default
  ;; (setq lsp-java-format-settings-url
  ;;      "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml")
  ;; (setq lsp-java-format-settings-profile "GoogleStyle")

  ;; See https://github.com/eclipse-jdtls/eclipse.jdt.ls/blob/main/CHANGELOG.md
  ;; and download from https://download.eclipse.org/jdtls/milestones/
  (setq lsp-java-jdt-download-url
        "https://www.eclipse.org/downloads/download.php?file=/jdtls/milestones/1.57.0/jdt-language-server-1.57.0-202602261110.tar.gz")

  (setq lsp-java-compile-null-analysis-mode "automatic"
        lsp-java-format-on-type-enabled nil
        lsp-java-completion-max-results 20
        ;; Use 3rd party decompiler
        lsp-java-content-provider-preferred "fernflower"))

;; Only deps: bui, lsp-docker, (posframe)
(use-package dap-mode
  :after lsp-mode
  :bind (
         ;; :map dap-server-log-mode-map
         ;; ("g" . recompile)
         :map dap-mode-map
         ("C-c C-t C-c" . dap-java-run-test-class)
         ("C-c C-t C-t" . dap-java-run-last-test)
         ("C-c C-t C-m" . dap-java-run-test-method)
         ([f9]    . dap-continue)
         ([S-f9]  . dap-disconnect)
         ([f10]   . dap-next)
         ([f11]   . dap-step-in)
         ([S-f11] . dap-step-out))
  :config
  ;; I don't want the dap output in a dedicated side-window. I like a simple regular buffer!
  (defun dap-go-to-output-buffer (&optional no-select)
    "Go to output buffer. No dedicated side-window."
    (interactive)
    (unless no-select
      (select-window (dap--debug-session-output-buffer (dap--cur-session-or-die)))))

  ;; Would like a repl in java but it doesn't seem to work,
  (setq dap-auto-configure-features '(sessions locals expressions tooltip))
  ;; (dap-auto-configure-mode)
  )

(use-package dap-java
  :after dap-mode)

(use-package json-ts-mode
  :mode ("\\.json\\'" "\\.avsc\\'"))

(use-package java-ts-mode
  :mode ("\\.java\\'")
  :init
  (add-to-list 'major-mode-remap-alist '(java-mode . java-ts-mode)))

(use-package groovy-mode
  :defer t)

(use-package jenkinsfile-mode
  :mode ("/Jenkinsfile.*"))

(use-package yaml-ts-mode
  :mode ("\\.yaml\\'" "\\.yml\\'")
  :config
  ;; Not the perfect outline regexp but better than no folding support
  (setq outline-regexp "\\([[:space:]]\\{0,2\\}[a-zA-Z_-]+\\):$"))

(use-package toml-ts-mode
  :mode ("\\.toml\\'" "Cargo.lock\\'"))

(use-package zig-ts-mode
  :defer t)

(use-package hcl-mode  ;; Only needed for terraform-mode
  :defer t)

(use-package terraform-mode
  :defer t)

(use-package python
  :mode (("\\.py\\'" . python-ts-mode))
  :interpreter ("python" . python-ts-mode)
  :bind (:map python-ts-mode-map
              ("C-x C-e" . python-shell-send-whole-line-or-region)
              ("C-c C-c" . python-shell-send-whole-line-or-region)
              ("C-c C-k" . python-shell-send-buffer)
              ("C-c C-d" . python-shell-send-defun)
              :map python-mode-map
              ("C-x C-e" . python-shell-send-whole-line-or-region)
              ("C-c C-c" . python-shell-send-whole-line-or-region)
              ("C-c C-k" . python-shell-send-buffer)
              ("C-c C-d" . python-shell-send-defun))
  :init
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))
  :config

  (setq python-shell-interpreter "uv"
        python-shell-interpreter-args "run python"
        ;;python-shell-interpreter-args "run ipython --simple-prompt -i"

        python-shell-prompt-detect-failure-warning nil
        python-shell-completion-native-enable nil

        ;; Don't spam message buffer when python-mode can't guess indent-offset
        python-indent-guess-indent-offset-verbose nil)

  (defun python-shell-send-whole-line-or-region (prefix)
    "Send whole line or region to inferior Python process."
    (interactive "*p")
    (whole-line-or-region-wrap-beg-end 'python-shell-send-region prefix)
    (deactivate-mark)))

(use-package python-pytest
  :defer t
  :config
  (setq python-pytest-executable "uv run pytest"))


(use-package web-mode
  :mode ("\\.phtml\\'" "\\.tpl\\.php\\'" "\\.tpl\\'" "\\.blade\\.php\\'" "\\.jsp\\'" "\\.as[cp]x\\'"
         "\\.erb\\'" "\\.html.?\\'" "/\\(views\\|html\\|theme\\|templates\\)/.*\\.php\\'"
         "\\.jinja2?\\'" "\\.mako\\'" "\\.vue\\'" "_template\\.txt" "\\.ftl\\'")
  :config
  ;; Expand e.g. s/ to <span>|</span>
  (setq web-mode-enable-auto-expanding t)
  ;; Enable current element highlight
  (setq web-mode-enable-current-element-highlight t)
  ;; Show column for current element
  ;; Like highlight-indent-guide but only one line for current element
  (setq web-mode-enable-current-column-highlight t)

  ;; Don't indent directly after a <script> or <style> tag
  (setq web-mode-script-padding 0)
  (setq web-mode-style-padding 0)

  ;; Set default indent to 2 spaces
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  ;; auto close tags in web-mode
  (setq web-mode-enable-auto-closing t))

(use-package dockerfile-ts-mode
  :mode ("Dockerfile"))

(use-package docker-compose-mode
  :mode ("docker-compose[^/]*\\.ya?ml\\'"))

(use-package windmove
  :bind (("s-i" . aerospace-windmove-up)
         ("s-k" . windmove-down)
         ("s-j" . aerospace-windmove-left)
         ("s-l" . aerospace-windmove-right)
         ("s-J" . aerospace-windmove-swap-states-left)
         ("s-K" . aerospace-windmove-swap-states-down)
         ("s-I" . aerospace-windmove-swap-states-up)
         ("s-L" . aerospace-windmove-swap-states-right))
  :commands (aerospace-windmove-up aerospace-windmove-down aerospace-windmove-left aerospace-windmove-right)
  :config
  (defun aerospace-command (args)
    "Call `aerospace' shell command with ARGS."
    (let ((command (concat "aerospace " args)))
      (start-process-shell-command "aerospace" nil command)))

  (defun aerospace-windmove-left (&optional arg)
    "Like windmove-left but call aerospace command `focus left'
if there is no window on the left."
    (interactive "P")
    (if (and (frame-focus-state)
             (windmove-find-other-window 'left arg))
        (progn
          (windmove-do-window-select 'left arg)
          (beacon-blink))
      ;; No window to the left
      (aerospace-command "focus left --boundaries all-monitors-outer-frame")))

  (defun aerospace-windmove-right (&optional arg)
    "Like windmove-right but call aerospace command `focus right'
if there is no window on the right."
    (interactive "P")
    (if (and (frame-focus-state)
             (windmove-find-other-window 'right arg))
        (progn
          (windmove-do-window-select 'right arg)
          (beacon-blink))
      ;; No window to the right
      (aerospace-command "focus right --boundaries all-monitors-outer-frame")))

  (defun aerospace-windmove-up (&optional arg)
    "Like windmove-up but call aerospace command `focus up'
if there is no window on the up."
    (interactive "P")
    (if (and (frame-focus-state)
             (windmove-find-other-window 'up arg))
        (progn
          (windmove-do-window-select 'up arg)
          (beacon-blink))
      ;; No window to the up
      (aerospace-command "focus up --boundaries all-monitors-outer-frame")))

  (defun aerospace-windmove-down (&optional arg)
    "Like windmove-down but call aerospace command `focus down'
if there is no window on the down."
    (interactive "P")
    (let ((other-window (windmove-find-other-window 'down arg)))
      (if (and (frame-focus-state)
               (or (and other-window
                        (not (window-minibuffer-p other-window)))
                   (and (window-minibuffer-p other-window)
                        (minibuffer-window-active-p other-window))))
          (progn
            (windmove-do-window-select 'down arg)
            (beacon-blink))
        ;; No window to the down
        (aerospace-command "focus down --boundaries all-monitors-outer-frame"))))

  (defun aerospace-windmove-swap-states-left (&optional arg)
    "Like windmove-swap-states-left but call aerospace command `move left'
if there is no window on the left."
    (interactive "P")
    (if (and (frame-focus-state)
             (windmove-find-other-window 'left arg))
        (windmove-swap-states-left)
      ;; No window to the left
      (aerospace-command "move left")))

  (defun aerospace-windmove-swap-states-right (&optional arg)
    "Like windmove-swap-states-right but call aerospace command `move right'
if there is no window on the right."
    (interactive "P")
    (if (and (frame-focus-state)
             (windmove-find-other-window 'right arg))
        (windmove-swap-states-right)
      ;; No window to the right
      (aerospace-command "move right")))

  (defun aerospace-windmove-swap-states-up (&optional arg)
    "Like windmove-swap-states-up but call aerospace command `move up'
if there is no window on the up."
    (interactive "P")
    (if (and (frame-focus-state)
             (windmove-find-other-window 'up arg))
        (windmove-swap-states-up)
      ;; No window to the up
      (aerospace-command "move up")))

  (defun aerospace-windmove-swap-states-down (&optional arg)
    "Like windmove-swap-states-down but call aerospace command `move down'
if there is no window on the down."
    (interactive "P")
    (let ((other-window (windmove-find-other-window 'down arg)))
      (if (and (frame-focus-state)
               (or (and other-window
                        (not (window-minibuffer-p other-window)))
                   (and (window-minibuffer-p other-window)
                        (minibuffer-window-active-p other-window))))
          (windmove-swap-states-down)
        (windmove-do-window-select 'down arg)
        ;; No window to the down
        (aerospace-command "move down"))))
  )


;; * Org mode

(use-package org
  :mode ("\\.\\(org\\|org_archive\\)\\'" . org-mode)
  :bind (("C-c a"   . org-agenda)
         :map org-mode-map
         ("<M-return>" . org-insert-todo-heading-respect-content)
         ("<M-S-return>" . org-meta-return)
         ("M-." . org-open-at-point)  ; So M-. behaves like in source code.
         ("M-," . org-mark-ring-goto)
         ("M-;" . org-comment-dwim)
         ("M-m" . consult-org-heading)
         ;; Disable adding and removing org-agenda files via keybinding.
         ("C-c [" . nil)
         ("C-c ]" . nil)
         ("\C-c TAB" . nil)  ;; Remove for tempel-expand
         ("C-a" . org-beginning-of-line)
         ("M-p" . org-previous-visible-heading)
         ("M-n" . org-next-visible-heading)
         ("<M-up>" . org-metaup)
         ("<M-down>" . org-metadown)
         :map org-src-mode-map
         ("C-x n" . org-edit-src-exit))
  :config
  (setq org-auto-align-tags t
        org-tags-column -105
        org-startup-folded t
        org-fold-catch-invisible-edits 'show-and-error
        org-special-ctrl-a/e t
        org-insert-heading-respect-content t
        org-startup-with-inline-images t
        org-imenu-depth 5
        org-special-ctrl-a/e t
        org-special-ctrl-k t
        org-enforce-todo-dependencies t
        org-use-fast-todo-selection t
        org-treat-S-cursor-todo-selection-as-state-change nil
        org-startup-indented t
        ;; Org styling, hide markup etc.
        org-hide-emphasis-markers t
        org-pretty-entities t
        ;; Ellipsis styling
        org-ellipsis "…"
        ;; But Don't print "bar" as subscript in "foo_bar"
        org-pretty-entities-include-sub-superscripts nil
        ;; And also don't display ^ or _ as super/subscripts
        org-use-sub-superscripts nil
        org-default-notes-file (concat org-directory "/inbox.org")
        ;; Set todo colors from moe-theme
        org-todo-keyword-faces '(("TODO" :foreground "#5f0000" :weight bold)  ;; red-4
                                 ("NEXT" :foreground "#0000af" :weight bold)  ;; blue-5
                                 ("DONE" :foreground "#005f00" :weight bold)  ;; green-5
                                 ("WAITING" :foreground "#af5f00" :weight bold)  ;; orange-5
                                 ("HOLD" :foreground "#ff2f9b" :weight bold)  ;; magenta-00
                                 ("CANCELLED" :foreground "#005f00" :weight bold)  ;; green-5
                                 ("MEETING" :foreground "#875f00" :weight bold))  ;; yellow-4
        org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
                            (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|"
                                      "CANCELLED(c@/!)" "MEETING")))

  (set-face-attribute 'org-ellipsis nil :inherit 'default :box nil))

(use-package org-duration
  :defer t
  :after org
  :config
  ;; Never show 'days' in clocksum (e.g. in report clocktable)
  ;; format string used when creating CLOCKSUM lines and when generating a
  ;; time duration (avoid showing days)
  (setq org-duration-format '((special . h:mm))))

(use-package org-clock
  :bind (("<f7>"    . org-clock-goto)
         ("C-c o i" . org-clock-in)
         ("C-c C-x C-j" . org-clock-goto)
         ("C-c C-x C-i" . org-clock-in)
         ("C-c C-x C-o" . org-clock-out))
  :config
  (org-clock-persistence-insinuate)

  (setq
   org-clock-history-length 30

   ;; Save the running clock and all clock history when exiting Emacs, load it on startup
   org-clock-persist t

   ;; Resume clocking task on clock-in if the clock is open
   org-clock-in-resume t
   ;; org-clock-display (C-c C-x C-d) shows times for this month by default
   org-clock-display-default-range 'thismonth

   ;; Only show the current clocked time in mode line (not all)
   org-clock-mode-line-total 'current

   ;; Sometimes I change tasks I'm clocking quickly - this removes clocked tasks with 0:00 duration
   org-clock-out-remove-zero-time-clocks t
   ;; Don't clock out when moving task to a done state
   org-clock-out-when-done nil

   ;; Enable auto clock resolution for finding open clocks
   org-clock-auto-clock-resolution (quote when-no-clock-is-running)
   ;; Include current clocking task in clock reports
   org-clock-report-include-clocking-task t)

  ;; Clocktable (C-c C-x C-r) defaults
  ;; Use fixed month instead of (current-month) because I want to keep a table for each month
  (setq org-clock-clocktable-default-properties
        `(:block ,(format-time-string "%Y-%m") :scope file-with-archives))

  ;; Clocktable (reporting: r) in the agenda
  (setq org-clocktable-defaults
        '(:maxlevel 3 :lang "en" :scope file-with-archives
                    :wstart 1 :mstart 1 :tstart nil :tend nil :step nil :stepskip0 t :fileskip0 t
                    :tags nil :emphasize nil :link t :narrow 70! :indent t :formula nil :timestamp nil
                    :level nil :tcolumns nil :formatter nil))

  ;; Log all State changes to drawer
  (setq org-log-into-drawer t
        ;; and add not when closing ticket
        org-log-done 'note)

  ;; make time editing use discrete minute intervals (no rounding) increments
  (setq org-time-stamp-rounding-minutes (quote (1 1))))

(use-package ol  ;; org-link
  :bind (("C-c l" . org-store-link))
  :config
  ;; Don't remove links after inserting
  (setq org-link-keep-stored-after-insertion t))

(use-package org-agenda
  :defer t
  :config
  ;; Keep tasks with dates/deadlines/scheduled dates/timestamps on the global todo lists
  (setq org-agenda-todo-ignore-with-date nil
        org-agenda-todo-ignore-deadlines nil
        org-agenda-todo-ignore-scheduled nil
        org-agenda-todo-ignore-timestamp nil
        ;; Remove completed deadline tasks from the agenda view
        org-agenda-skip-deadline-if-done t
        org-extend-today-until 4  ;; For 0 to 4am show yesterday in the agenda view "toady"
        org-agenda-show-all-dates t)

  (setq org-agenda-window-setup 'current-window
        org-agenda-log-mode-items (quote (closed state clock))
        org-agenda-tags-column -105
        org-agenda-block-separator ?─
        org-agenda-time-grid
        '((daily today require-timed)
          (800 1000 1200 1400 1600 1800 2000)
          " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
        org-agenda-current-time-string
        "◀── now ─────────────────────────────────────────────────"))

(use-package org-capture
  :bind ("C-c o c" . org-capture)
  :config
  ;; I don't want that org-capture rearanges the windows for me.
  ;; From https://stackoverflow.com/questions/54192239/open-org-capture-buffer-in-specific-window/54251825#54251825
  (defun org-capture-place-template-dont-delete-windows (oldfun args)
    (cl-letf (((symbol-function 'delete-other-windows) 'ignore))
      (apply oldfun args)))
  (advice-add 'org-capture-place-template :around 'org-capture-place-template-dont-delete-windows)

  (setq org-capture-bookmark nil   ; Do *NOT* bookmark to the last location when capturing
        org-reverse-note-order t)  ; Capture/refile new items to the top of the list

  ;; Capture templates for: TODO tasks, Notes, appointments, phone calls, meetings, and org-protocol
  (setq org-capture-templates
        `(("t" "todo" entry (file ,(concat org-directory "/refile.org"))
           "* TODO %?\n" :clock-in t :clock-resume t)
          ("T" "todo with link" entry (file ,(concat org-directory "/refile.org"))
           "* TODO %?\n%a\n" :clock-in t :clock-resume t)
          ("e" "email" entry (file ,(concat org-directory "/refile.org"))
           "* TODO %? Email: %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n"
           :clock-in t :clock-resume t :immediate-finish nil)
          ("j" "Journal entry" entry (file+olp+datetree ,(concat org-directory "/journal.org"))
           "* %?\n")
          ("J" "Journal with link" entry (file+olp+datetree ,(concat org-directory "/journal.org"))
           "* %?\n%a\n")
          ("r" "respond" entry (file ,(concat org-directory "/refile.org"))
           "* TODO Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
          ("n" "note" entry (file ,(concat org-directory "/refile.org"))
           "* %? :NOTE:\n%a\n" :clock-in t :clock-resume t)
          ("w" "org-protocol" entry (file ,(concat org-directory "/refile.org"))
           "* TODO Review %c\n%U\n" :immediate-finish t)
          ("p" "Protocol" entry (file ,(concat org-directory "/refile.org"))
           "* %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
          ("L" "Protocol Link" entry (file ,(concat org-directory "/refile.org"))
           "* %?\n[[%:link][%:description]]\n")
          ("w" "Web site" entry (file "")
           "* %a :website:\n\n%U %?\n\n%:initial"))))

(use-package ob
  :after org
  :hook ((org-babel-after-execute . org-display-inline-images))
  :config
  ;; don't prompt me to confirm every time I want to evaluate a block
  (setq org-confirm-babel-evaluate nil)

  ;; Add more languages to org-babel
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((C . t)
     (awk)
     (calc . t)
     (clojure . t)
     (css)
     (ditaa . t)
     (dot . t)
     (emacs-lisp . t)
     (gnuplot . t)
     (haskell)
     (java . t)
     (js . t)
     (latex)
     (lisp)
     (lua . t)
     (matlab)
     (ocaml)
     (octave . t)
     (perl)
     (plantuml . t)
     (python . t)
     ;; (restclient . t)
     (ruby)
     (sass)
     (scala)
     (scheme)
     (shell . t)
     (sql . t)
     (sqlite . t))))

(use-package ob-clojure
  :after ob
  :config
  (setq org-babel-clojure-backend 'babashka))

;; (use-package ob-restclient
;;   :after ob)

;; (use-package ob-mongo
;;   :after ob)

(use-package org-src
  :after org
  :config
  ;; Always split babel source window below.
  ;; Alternative is `current-window' to don't mess with window layout at all
  (setq org-src-window-setup 'split-window-below)

  (setq org-edit-src-content-indentation 0)

  ;; Add 'conf-mode' to org-babel
  (add-to-list 'org-src-lang-modes '("ini" . conf))
  (add-to-list 'org-src-lang-modes '("conf" . conf)))

(use-package ol
  :after org
  :config
  (setq org-link-keep-stored-after-insertion t))

;; org-link support for magit buffers
(use-package orgit
  ;; Automatically copy orgit link to last commit after commit
  :hook (git-commit-post-finish . orgit-store-after-commit)
  :config
  (defun orgit-store-after-commit ()
    "Store orgit-link for latest commit after commit message editor is finished."
    (let* ((repo (abbreviate-file-name default-directory))
           (rev (magit-git-string "rev-parse" "HEAD"))
           (link (format "orgit-rev:%s::%s" repo rev))
           (summary (substring-no-properties (magit-format-rev-summary rev)))
           (desc (format "%s (%s)" summary repo)))
      (push (list link desc) org-stored-links))))

(use-package org-modern
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :config
  (setq org-modern-hide-stars nil
        org-modern-star 'replace
        org-modern-replace-stars "❶❷❸❹❺❻❼"
        org-modern-progress 7
        ;; Set todo colors from moe-theme
        org-modern-todo-faces '(("TODO" :background "#5f0000" :weight bold)  ;; red-4
                                ("NEXT" :background "#0000af" :weight bold)  ;; blue-5
                                ("DONE" :background "#005f00" :weight bold)  ;; green-5
                                ("WAITING" :background "#af5f00" :weight bold)  ;; orange-5
                                ("HOLD" :background "#ff2f9b" :weight bold)  ;; magenta-00
                                ("CANCELLED" :background "#005f00" :weight bold)  ;; green-5
                                ("MEETING" :background "#875f00" :weight bold))))  ;; yellow-4

(use-package org-modern-indent
  :defer t
  :init
  (add-hook 'org-mode-hook #'org-modern-indent-mode 90))

(use-package org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autolinks nil))

(use-package verb
  :after org
  :config
  (setq verb-tag "http"  ;; Use :http: instead of :verb: which is a bit more meaningful
        verb-enable-ctrl-c-ctrl-c nil  ;; Don't overwrite org-ctrl-c-ctrl-c
        verb-suppress-load-unsecure-prelude-warning nil  ;; Don't show warning when loading verb preludes
        verb-auto-kill-response-buffers 3) ;; Auto kill all but the last 3 http response buffers

  ;; Open application/edn responses in clojure mode
  (add-to-list 'verb-content-type-handlers '("application/edn" clojure-mode) t)

  (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

(use-package server
  :config
  (unless (server-running-p)
    (setq confirm-kill-emacs #'y-or-n-p)
    (server-start)))


;; * Post Initialization
(message "Loading %s...done (%.3fs)" user-init-file
         (float-time (time-subtract (current-time)
                                    before-user-init-time)))
(add-hook 'after-init-hook
          (lambda ()
            (message
             "Loading %s...done (%.3fs) [after-init]" user-init-file
             (float-time (time-subtract (current-time)
                                        before-user-init-time)))
            ;; Restore original file name handlers
            (setq file-name-handler-alist file-name-handler-alist-old)
            ;; Let's lower our GC thresholds back down to 256MB.
            (setq gc-cons-threshold (* 256 1024 1024)))
          t)
