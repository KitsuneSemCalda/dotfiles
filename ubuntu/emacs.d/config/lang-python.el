;; -*- lexical-binding: t; -*-

(use-package python-mode
  :hook (python-mode . lsp)
  :custom
  (python-shell-interpreter "python3"))

(use-package lsp-pyright
  :if (executable-find "pyright")
  :hook (python-mode . (lambda () (require 'lsp-pyright) (lsp))))

(provide 'lang-python)
