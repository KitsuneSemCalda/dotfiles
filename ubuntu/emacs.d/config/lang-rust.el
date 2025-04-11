;; -*- lexical-binding: t -*-

(use-package rust-mode
  :mode "\.rs\'"
  :hook (rust-mode .lsp))

(use-package lsp-mode
  :hook (rust-mode . lsp)
  :custom
  (lsp-rust-server 'rust-analyzer))

(use-package cargo
  :hook (rust-mode . cargo-minor-mode))

(use-package lsp-ui)

(provide 'lang-rust)
