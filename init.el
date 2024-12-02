;;; init.el --- user-init-file                    -*- lexical-binding: t -*-

(defvar before-user-init-time (current-time)
  "Value of `current-time' when Emacs begins loading `user-init-file'.")

(message "Loading Emacs...done (%.3fs)"
         (float-time (time-subtract before-user-init-time
                                    before-init-time)))

;; * Initialize borg
(add-to-list 'load-path (expand-file-name "lib/borg" user-emacs-directory))
(require 'borg)
(borg-initialize)

(setq use-package-enable-imenu-support t)
(require 'use-package)



(use-package no-littering
  :demand t
  :config
  (setq server-auth-dir (no-littering-expand-var-file-name "server"))
  ;; /etc is version controlled and I want to store mc-lists in git
  (setq mc/list-file (no-littering-expand-etc-file-name "mc-list.el"))
  ;; Put the auto-save and backup files in the var directory to the other data files
  (no-littering-theme-backups))

(use-package emacs
  :config
  ;; ;; Compile loaded .elc files asynchronously
  ;; (setq natiqve-comp-jit-compilation t)
  ;; (if (eq system-type 'windows-nt)
  ;;     (setq native-comp-async-jobs-number 4))

  (add-to-list 'default-frame-alist '(font . "Fira Code-12:weight=regular:width=normal"))
  (set-frame-font "Fira Code-12:weight=regular:width=normal" nil t)
  (unless (eq system-type 'darwin)
    (set-fontset-font t 'emoji (font-spec :family "Segoe UI Emoji") nil 'append))

  ;; (require-theme 'modus-themes) ; `require-theme' is ONLY for the built-in Modus themes

  ;; Add all your customizations prior to loading the themes
  ;; (setq modus-themes-italic-constructs t
  ;;       modus-themes-bold-constructs nil)

  ;; Load the theme of your choice.
  ;; (load-theme 'modus-vivendi)

  ;; Register all left windows-key presses as "super".
  ;; Doesn't work for "s-l" as this always locks Windows on a low level.
  (if (eq system-type 'windows-nt)
      (progn
        (prefer-coding-system 'utf-8-dos)

        (setq w32-lwindow-modifier 'super
              w32-pass-lwindow-to-system nil
              w32-pass-alt-to-system nil)
        (w32-register-hot-key [M-])
        (w32-register-hot-key [s-]))
    (prefer-coding-system 'utf-8))

  ;; Always just use left-to-right text. This makes Emacs a bit faster for very long lines
  (setq-default bidi-paragraph-direction 'left-to-right)

  (setq-default indent-tabs-mode nil)  ;; Don't use tabs to indent
  (setq-default tab-width 4)

  (setq tab-always-indent 'complete)  ;; smart tab behavior - indent or complete
  (setq require-final-newline t)  ;; Newline at end of file
  (setq mouse-yank-at-point t)  ;; Paste with middle mouse button doesn't move the cursor
  (delete-selection-mode t)  ;; Delete the selection with a keypress
  (setq auth-source-save-behavior nil)  ;; Don't ask to store credentials in .authinfo.gpg
  ;; (setq truncate-string-ellipsis "…")  ;; Use 'fancy' ellipses for truncated strings

  ;; Focus follows mouse for Emacs windows and frames
  (setq mouse-autoselect-window t)
  (setq focus-follows-mouse t)

  ;; Activate character folding in searches i.e. searching for 'a' matches 'ä' as well
  (setq search-default-mode 'char-fold-to-regexp)

  ;; Only split horizontally if there are at least 90 chars column after splitting
  (setq split-width-threshold 180)
  ;; Only split vertically on very tall screens
  (setq split-height-threshold 140)

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
  (setq ring-bell-function 'ignore)

  (setq create-lockfiles nil)  ; disable lock file symlinks

  (setq make-backup-files t    ;; backup of a file the first time it is saved.
        backup-by-copying t    ;; don't clobber symlinks
        version-control t      ;; version numbers for backup files
        delete-old-versions t  ;; delete excess backup files silently
        kept-old-versions 6    ;; oldest versions to keep when a new numbered backup is made
        kept-new-versions 9)   ;; newest versions to keep when a new numbered backup is made

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
         ("M-U"   . dakra-downcase-dwim)
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
    (setq-local fill-column 68)
    (auto-fill-mode))

  ;; Autofill (e.g. M-x autofill-paragraph or M-q) to 80 chars (default 70)
  (setq-default fill-column 80)

  (defmacro dakra-define-up/downcase-dwim (case)
    (let ((func (intern (concat "dakra-" case "-dwim")))
          (doc (format "Like `%s-dwim' but %s from beginning when no region is active." case case))
          (case-region (intern (concat case "-region")))
          (case-word (intern (concat case "-word"))))
      `(defun ,func (arg)
         ,doc
         (interactive "*p")
         (save-excursion
           (if (use-region-p)
               (,case-region (region-beginning) (region-end))
             (beginning-of-thing 'symbol)
             (,case-word arg))))))
  (dakra-define-up/downcase-dwim "upcase")
  (dakra-define-up/downcase-dwim "downcase")
  (dakra-define-up/downcase-dwim "capitalize"))

;; So-long: Mitigating slowness due to extremely long lines
(use-package so-long
  :defer 5
  :config
  (global-so-long-mode))

(use-package compile
  :config
  (setq compilation-ask-about-save nil  ;; Always save before compiling
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
        '(compile-command kill-ring regexp-search-ring corfu-history)))

(use-package hippie-exp
  :bind (("M-/" . hippie-expand)))

(use-package editorconfig
  :defer t
  :config
  (setq editorconfig-trim-whitespaces-mode 'ws-butler-mode))

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

(use-package dogears
  :hook (after-init . dogears-mode)
  :bind (("C-x SPC" . dogears-go)
         ("C-x C-SPC" . dogears-back)
         ("C-x M-SPC" . dogears-forward))
  :config
  (setq dogears-idle 3))

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
  :bind (("C-x m" . eshell)
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
                                 "nmtui" "dstat" "mycli" "pgcli" "vue" "ngrok"
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
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-recent-file consult--source-project-recent-file consult--source-bookmark
   :preview-key '(:debounce 0.2 any))

  (setq consult-narrow-key "<"))

(use-package consult-project-extra
  :defer t)

(use-package embark
  :bind (("C-." . embark-act)         ;; pick some comfortable binding
         ("C-," . embark-dwim)        ;; good alternative: M-.
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
  :hook (((prog-mode conf-mode) . corfu-mode)
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

(use-package beacon
  :unless noninteractive
  :hook (after-init . beacon-mode))

(use-package minions
  :unless noninteractive
  :hook (after-init . minions-mode)
  :config
  (setq minions-mode-line-lighter "+")
  (setq minions-prominent-modes '(flycheck-mode
                                  multiple-cursors-mode
                                  mu4e-modeline-mode)))

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
               '(("Timbre"
                  (format  . "TIMESTAMP LEVEL [NAME] -")
                  (levels  . "SLF4J")))))

(use-package gptel
  :defer t
  :config
  (setq gptel-default-mode 'org-mode
        gptel-model 'claude-3-5-sonnet-20241022
        gptel-prompt-prefix-alist '((markdown-mode . "# ") (org-mode . "* ") (text-mode . "# "))
        gptel-backend (gptel-make-anthropic "Claude"
                        :stream t
                        :key gptel-api-key)))

;; Only deps: pfuture
(use-package treemacs
  :bind (([f8] . treemacs-select-window)
         ([f12] . treemacs-find-file)
         :map treemacs-mode-map
         ("M-l" . nil)  ;; We bind `M-l' to `windmove-right'
         ("C-t a" . treemacs-add-project-to-workspace)
         ("C-t d" . treemacs-remove-project)
         ("C-t r" . treemacs-rename-project)
         ;; If we only hide the treemacs buffer (default binding) then, when we switch
         ;; a frame to a different project and toggle treemacs again we still get the old project
         ("q" . treemacs-kill-buffer))
  :config
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

  (treemacs-resize-icons 14)  ;; Make icons a bit smaller (22 pixels by default)

  (treemacs-follow-mode -1)
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

(use-package with-editor
  ;; Use local Emacs instance as $EDITOR (e.g. in `git commit' or `crontab -e')
  :hook ((shell-mode eshell-mode vterm-mode term-exec) . with-editor-export-editor))

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
  ;; Set remote.pushDefault
  (setq magit-remote-set-if-missing 'default)

  ;; Don't override date for extend or reword
  (setq magit-commit-extend-override-date nil)
  (setq magit-commit-reword-override-date nil)

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

  ;; When showing refs (In magit status press `y y') show only merged into master by default
  (setq magit-show-refs-arguments '("--merged=master"))
  ;; Show color and graph in magit-log. Since color makes it a bit slow, only show the last 128 commits
  (setq magit-log-arguments '("--graph" "--color" "--decorate" "-n128"))
  ;; Always highlight word differences in diff
  (setq magit-diff-refine-hunk 'all)

  ;; Don't change my window layout after quitting magit
  ;; Often I invoke magit and then do a lot of things in other windows
  ;; On quitting, magit would then "restore" the window layout like it was
  ;; when I first invoked magit. Don't do that!
  (setq magit-bury-buffer-function 'magit-mode-quit-window)

  ;; Show magit status in the same window
  (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package git-modes
  :defer t)

;; Only deps: ghub, treepy
(use-package forge
  :after magit
  :config
  ;; Don't pull notifications as it blocks Emacs for a long time
  (setq forge-pull-notifications nil))

(use-package diff-hl
  :hook (((prog-mode conf-mode vc-dir-mode ledger-mode) . turn-on-diff-hl-mode)
         (magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
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
         ("C-M-$" . jinx-languages)))

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
                                       ";;" "__" "..." ".." "&&" "++")))

(use-package transient
  :defer t
  :bind (("C-x l" . transient-emacs-launcher)
         ("C-x C-l" . transient-emacs-launcher)
         ("C-x t" . transient-toggle-stuff)
         ("C-x 9" . transient-unicode))
  :config
  ;; Display transient buffer below current window
  ;; and not bottom of the complete frame (minibuffer like)
  (setq transient-display-buffer-action '(display-buffer-below-selected))

  (defmacro transient-help-toggle (text toggle)
    `(if (bound-and-true-p ,toggle)
         (format "[x] %s" ,text)
       (format "[ ] %s" ,text)))

  (transient-define-prefix transient-toggle-stuff ()
    "Toggle various modes and settings"
    [["Misc"
      ("a" "Abbrev" abbrev-mode
       :description (lambda () (transient-help-toggle "abbrev" abbrev-mode)))
      ("b" "Browser" dakra-toggle-browser
       :description (lambda () (format "[%s] toggle eww/firefox"
                                       (if (eq browse-url-browser-function 'browse-url-firefox) "Firefox" "eww"))))
      ("d e" "Debug" toggle-debug-on-error
       :description (lambda () (transient-help-toggle "debug-on-error" debug-on-error)))
      ("d q" "Debug" toggle-debug-on-quit
       :description (lambda () (transient-help-toggle "debug-on-quit" debug-on-quit)))
      ("s" "Sticky" toggle-window-dedicated
       :description (lambda () (transient-help-toggle "Sticky buffer mode" window-dedicated-p)))]
     ["Text"
      ("c" "Column number" column-number-mode
       :description (lambda () (transient-help-toggle "column-number-mode" column-number-mode)))
      ("f" "Fill mode" auto-fill-mode
       :description (lambda () (transient-help-toggle "fill-mode" auto-fill-function)))
      ("v" "Visual fill column mode" visual-fill-column-mode
       :description (lambda () (transient-help-toggle "visual-fill-column-mode" visual-fill-column-mode)))
      ("w" "Whitespace" whitespace-mode
       :description (lambda () (transient-help-toggle "whitespace-mode" whitespace-mode)))
      ("l" "Truncate lines" toggle-truncate-lines
       :description (lambda () (transient-help-toggle "truncate-lines" truncate-lines)))]
     ["Org"
      ("ol" "Link display" org-toggle-link-display
       :description (lambda () (transient-help-toggle "org link-display" org-descriptive-links)))
      ("op" "Pretty entities" org-toggle-pretty-entities
       :description (lambda () (transient-help-toggle "org pretty-entities" org-pretty-entities)))
      ("oi" "Inline images" org-toggle-inline-images
       :description (lambda () (transient-help-toggle "org inline-images" org-inline-image-overlays)))]])

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
      ("L" "Lock" (lambda ()
                    (interactive)
                    (start-process-shell-command "pmset" nil "pmset sleepnow")))
      
      ;; ("b" "brain.fm - Stream music" brain-fm-play)
      ;; ("y" "YouTube - Open dired buffer" (lambda () (interactive) (dired youtube-dl-directory)))
      ]])
  )

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
