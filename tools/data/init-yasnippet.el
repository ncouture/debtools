(require-package 'yasnippet)
(require 'yasnippet)
(require 'yasnippet-snippets)
(add-to-list 'yas-snippet-dirs
             (expand-file-name "~/.emacs.d/snippets/terraform-mode/"
                               (file-name-directory
                                (or load-file-name buffer-file-name)))
             t)
(yas-reload-all)

(provide 'init-yasnippet)
