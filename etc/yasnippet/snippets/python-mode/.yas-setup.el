(defun elpy-snippet-split-args (arg-string)
  "Split a python argument string into ((name, default)..) tuples."
  (mapcar (lambda (x)
            (split-string x "[[:blank:]]*=[[:blank:]]*" t))
          (split-string arg-string "[[:blank:]]*,[[:blank:]]*" t)))

(defun elpy-snippet-init-assignments (arg-string)
  "Return the typical __init__ assignments for arguments."
  (let ((indentation (make-string (save-excursion
                                    (goto-char start-point)
                                    (current-indentation))
                                  ?\s)))
    (mapconcat (lambda (arg)
                 (if (string-match "^\\*" (car arg))
                     ""
                   (format "self.%s = %s\n%s"
                           (car arg)
                           (car arg)
                           indentation)))
               (elpy-snippet-split-args arg-string)
               "")))
