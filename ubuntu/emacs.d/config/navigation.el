; -*- lexical-binding: t; -*-

(use-package ivy
  :init (ivy-mode 1)
  :config
  (setq ivy-count-format "(%d/%d) "
	ivy-use-virtual-buffers t
	enable-recursive-minibuffers t))

(use-package counsel
  :after ivy
  :init (counsel-mode 1)
  :bind (("M-x" . counsel-M-x)
	 ("C-x C-f" . counsel-find-file)
	 ("C-c k" . counsel-rg)))

(use-package swiper
  :after ivy
  :bind (("C-s" . swiper)))

(use-package which-key
  :init (which-key-mode)
  :config
  (setq which-key-idle-delay 0.5))

(use-package evil
  :init
  (setq evil-want-integration t
	evil-want-C-u-scroll t
	evil-want-keybinding nil
	evil-want-C-i-jump nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))
	

(provide 'navigation)
