;; -*- lexical-binding: t -*-

(use-package ruby-mode
  :mode "\.rb\'")

(use-package inf-ruby
  :hook (ruby-mode . inf-ruby-minor-code))

(use-package lsp-mode
  :hook (ruby-mode . lsp)
  :custom
  (lsp-solargraph-use-bundler t))

(provide 'lang-ruby)
