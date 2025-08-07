(use-package company
  :init (global-company-mode)
  :config
  (setq company-minimum-prefix-length 1
	company-idle-delay 0.0))

(use-package lsp-mode
  :hook ((prog-mode . lsp))
  :custom
  (lsp-headerline-breadcrumbs-enable nil)
  (lsp-enable-symbol-highlighting nil))

(use-package lsp-ui
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-sideline-enable nil))

(use-package treesit-auto
  :config (global-treesit-auto-mode))

(use-package nerd-icons)

(provide 'dev)
