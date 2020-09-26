(require-package 'elpy)
(require-package 'sphinx-doc)
(require-package 'company)
(require-package 'yasnippet)
(require-package 'pyvenv)
(require-package 'highlight-indentation)
(require-package 's)
(require 'elpy)
(require 'sphinx-doc)
(require 'company)
(require 'yasnippet)
(require 'pyvenv)
(require 'highlight-indentation)
(require 's)

(elpy-enable)
(setenv "WORKON_HOME" (expand-file-name "~/.virtualenvs/"))
(setq elpy-rpc-backend "rope")
(add-hook 'python-mode-hook (lambda ()
                              (require 'sphinx-doc)
                              (sphinx-doc-mode t)))


(add-hook 'pyvenv-post-activate-hooks 'fc/configure-elpy-from-env)

(add-hook 'elpy-mode-hook (lambda ()
                            (add-hook 'before-save-hook
                                      'elpy-format-code nil t)))

(defun fc/configure-elpy-from-env ()
  (dolist (elt process-environment)
    (when (string-match "\\`\\(ELPY_[^=]*\\)=\\(.*\\)\\'" elt)
      (let ((var (downcase
                  (replace-regexp-in-string "_" "-" (match-string 1 elt))))
            (val (match-string 2 elt)))
        (set (intern var) (read val))))))
(global-set-key (kbd "C-c ,") 'elpy-multiedit)

(defun elpy-goto-definition-or-rgrep ()
  "Go to the definition of the symbol at point, if found. Otherwise, run `elpy-rgrep-symbol'."
  (interactive)
  (ring-insert find-tag-marker-ring (point-marker))
  (condition-case nil (elpy-goto-definition)
    (error (elpy-rgrep-symbol
            (concat "\\(def\\|class\\)\s" (thing-at-point 'symbol) "(")))))

(define-key elpy-key-map (kbd "M-.") 'elpy-goto-assignment)
(define-key elpy-key-map (kbd "C-x 4 M-.") 'elpy-goto-assignment-other-window)
;; (define-key elpy-mode-map (kbd "M-.") 'elpy-goto-definition-or-rgrep)
(advice-add 'elpy-shell--insert-and-font-lock
            :around (lambda (f string face &optional no-font-lock)
                      (if (not (eq face 'comint-highlight-input))
                          (funcall f string face no-font-lock)
                        (funcall f string face t)
                        (python-shell-font-lock-post-command-hook))))

(advice-add 'comint-send-input
            :around (lambda (f &rest args)
                      (if (eq major-mode 'inferior-python-mode)
                          (cl-letf ((g (symbol-function 'add-text-properties))
                                    ((symbol-function 'add-text-properties)
                                     (lambda (start end properties &optional object)
                                       (unless (eq (nth 3 properties) 'comint-highlight-input)
                                         (funcall g start end properties object)))))
                            (apply f args))
                        (apply f args))))


(provide 'init-elpy)
