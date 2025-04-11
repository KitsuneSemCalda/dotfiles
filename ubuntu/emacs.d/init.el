;; -*- lexical-binding: t; -*-

;  ===== Minimalist Emacs GTK Interface =====

(setq initial-scratch-message ";; Kitsune Emacs | Ready to Coffee")

; Set directory config to load path
(add-to-list 'load-path (expand-file-name "config" user-emacs-directory))

(dolist (module '(core packages dev editor ui acessibility navigation lang-cpp lang-python lang-ruby lang-rust))
  (require module))

;; Silence startup
(setq inhibit-startup-message t)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(evil-collection evil which-key counsel ivy nerd-icons all-the-icons)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
