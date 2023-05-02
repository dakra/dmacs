fundamental-mode ;; Available everywhere

(today (format-time-string "%Y-%m-%d"))
(tomorrow (format-time-string "<%Y-%m-%d>" (time-add nil (* 24 60 60))))

prog-mode

(fixme (if (derived-mode-p 'emacs-lisp-mode) ";; " comment-start) "FIXME ")
(todo  (if (derived-mode-p 'emacs-lisp-mode) ";; " comment-start) "TODO ")
(note  (if (derived-mode-p 'emacs-lisp-mode) ";; " comment-start) "NOTE ")
(bug   (if (derived-mode-p 'emacs-lisp-mode) ";; " comment-start) "BUG ")
(hack  (if (derived-mode-p 'emacs-lisp-mode) ";; " comment-start) "HACK ")
(xxx   (if (derived-mode-p 'emacs-lisp-mode) ";; " comment-start) "XXX ")

emacs-lisp-mode

(autoload ";;;###autoload" n)
(advice "(defun " (p "adv" name) " (&rest app)" n> p n> "(apply app))" n>
        "(advice-add #'" (p "fun") " " (p ":around") " #'" (s name) ")")
(header ";;; " (file-name-nondirectory (or (buffer-file-name) (buffer-name)))
        " -- " p " -*- lexical-binding: t -*-" n
        ";;; Commentary:" n ";;; Code:" n n)
(provide "(provide '" (file-name-base (or (buffer-file-name) (buffer-name))) ")" n
         ";;; " (file-name-nondirectory (or (buffer-file-name) (buffer-name)))
         " ends here" n)

python-base-mode

(prints "print(\"" (p "*" char) (make-string 49 (string-to-char char)) "\")")
(ptr "import ptpdb; ptpdb.set_trace()" n>)

clojure-mode

(prints "(println \"" (p "*" char) (make-string 49 (string-to-char char)) "\")")

sql-mode

(dbsize
 "SELECT" n
 "    table_name AS 'Table', SUM(TABLE_ROWS) AS 'Row estimate'," n
 "    round(((data_length + index_length) / 1024 / 1024), 2) 'Size in MB'" n
 "  FROM information_schema.TABLES" n
 " WHERE table_schema = DATABASE()" n
 "   AND table_name = " r ";")

sql-interactive-mode

(dbsize
 "SELECT" n
 "    table_name AS 'Table', SUM(TABLE_ROWS) AS 'Row estimate'," n
 "    round(((data_length + index_length) / 1024 / 1024), 2) 'Size in MB'" n
 "  FROM information_schema.TABLES" n
 " WHERE table_schema = DATABASE()" n
 "   AND table_name = " r ";")

text-mode

(box "┌─" (make-string (length str) ?─) "─┐" n
     "│ " (s str)                       " │" n
     "└─" (make-string (length str) ?─) "─┘" n)
(abox "+-" (make-string (length str) ?-) "-+" n
      "| " (s str)                       " |" n
      "+-" (make-string (length str) ?-) "-+" n)
(cut "--8<---------------cut here---------------start------------->8---" n r n
     "--8<---------------cut here---------------end--------------->8---" n)
(rot13 (p "plain text" text) n "----" n (rot13 text))
(calc (p "taylor(sin(x),x=0,3)" formula) n "----" n (format "%s" (calc-eval formula)))

rst-mode

(title (make-string (length title) ?=) n (p "Title: " title) n (make-string (length title) ?=) n)

org-mode

(caption "#+caption: ")
(name "#+name: ")
;; <s etc is not workign with tempel as `(bounds-of-thing-at-point 'symbol)`
;; (used in `tempel--prefix-bounds`) in org doesn't recognize `<` as part of the symbol.
(quote "#+begin_quote" n> r> n "#+end_quote")
(example "#+begin_example" n> r> n "#+end_example")
(gnuplot "#+begin_src gnuplot :var data=" (p "table") " :file " (p "plot.png") n> r> n "#+end_src" :post (org-edit-src-code))
(src (p (completing-read "Language: " (mapcar 'car org-babel-load-languages)) src t)
     "#+begin_src " src n> r> n "#+end_src")
(el "#+begin_src emacs-lisp" n> r> n "#+end_src" :post (org-edit-src-code))
(clj "#+begin_src clojure" n> r> n "#+end_src" :post (org-edit-src-code))
(py "#+begin_src python" n> r> n "#+end_src" :post (org-edit-src-code))
(rest "#+begin_src restclient" n> r> n "#+end_src")

;; Local Variables:
;; outline-regexp: "[a-z]"
;; imenu-generic-expression: ((nil "^\\([a-z].*\\)" 1))
;; End:
