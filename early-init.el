;; Temporarily set `gc-cons-threshold' to 2G until the initialization is done
(setq gc-cons-threshold (* 2 1024 1024 1024))  ;; 2G
;; Temporarily disable file name handlers as it's not needed on initialization
(defvar file-name-handler-alist-old file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Hide title-bar on MacOS
(add-to-list 'default-frame-alist '(undecorated-round . t))

;; Disable the scroll-bar
(scroll-bar-mode -1)

(setq package-enable-at-startup nil
      load-prefer-newer t

      ;; Disable startup screen and startup echo area message and select the scratch buffer by default
      inhibit-startup-buffer-menu t
      inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      initial-buffer-choice t
      initial-scratch-message nil

      ;; Disable certain byte compiler warnings to cut down on the noise. This is a personal
      ;; choice and can be removed if you would like to see any and all byte compiler warnings.
      byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))

;; Put native compilation cache in no-litter var folder.
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "var/eln-cache/" user-emacs-directory))))
