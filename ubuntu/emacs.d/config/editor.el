(setq make-backup-files nil)
(setq auto-save-default nil)
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(desktop-save-mode 1)

(prefer-coding-system 'utf-8)
(set-language-environment "UTF-8")

(global-set-key (kbd "C-/") 'comment-line)

(provide 'editor)
