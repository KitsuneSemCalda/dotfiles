;; -*- lexical-binding: t; -*-

(use-package company
  :hook (after-init . global-company-mode)
  :config
  (setq company-minimum-prefix-length 1
	company-idle-delay 0.0))

(provide 'dev)
