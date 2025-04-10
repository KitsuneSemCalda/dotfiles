;; -*- lexical-binding: t; -*-

;  ===== Minimalist Emacs GTK Interface =====

; Epic Message
(setq initial-stratch-message ";; Kitsune Emacs | Ready to Coffee")

; Set the another folders to load config
(add-to-list 'load-path (expand-file-name "config" user-emacs-directory))

; Enable cua-mode
(cua-mode t)

; Require the core config with the principal config of emacs
(require 'core)
(require 'packages)
(require 'dev)
(require 'editor)
(require 'ui)
(require 'acessibility)
(require 'navigation)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(evil-collection evil which-key counsel ivy all-the-icons nerd-icons treesit-auto lsp-ui lsp-mode company)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
