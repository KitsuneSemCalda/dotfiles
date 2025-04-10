(require 'package)

(setq use-package-always-ensure t)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
	("gnu" . "https://elpa.gnu.org/packages/")))

(setq evil-want-integration t)
(setq evil-want-keybinding nil)

(setq lsp-completion-provider :carf)

(setq lsp-keymap-prefix "C-c l")
(setq lsp-enable-symbol-highlighting t
      lsp-headerline-breadcrumb-enable t
      lsp-enable-on-type-formatting nil
      lsp-idle-delay 0.500
      lsp-prefer-flymake nil)

(setq lsp-clients-clangd-args `("--clang-tidy"
				"--completion-style=detailed"
				"--header-insertion=never"
				"--background-index"
				"--cross-file-rename"))
(setq lsp-ui-doc-enable t
      lsp-ui-doc-use-childframe t
      lsp-ui-doc-position 'bottom
      lsp-ui-sideline-enable t
      lsp-ui-sideline-show-code-actions t)

(setq company-idle-delay 0.1
      company-minimum-prefix-length 1
      company-selection-wrap-around t)

(when (fboundp 'treesit-available-p)
  (setq major-mode-remap-alist
        '((c-mode . c-ts-mode)
          (c++-mode . c++-ts-mode)
          (objc-mode . objc-ts-mode))))

(setq gdb-many-windows t
      gdb-show-main t)

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
	(package-install 'use-package))

(require 'use-package)

(use-package which-key
  :config
  (which-key-mode))

(use-package ivy
  :config
  (ivy-mode 1))

(use-package evil
  :init
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-one t))

(use-package lsp-mode
  :hook ((c-mode c++-mode objc-mode) . lsp)
  :commands lsp
  :init
  :config)

(use-package lsp-ui
  :commands lsp-ui-mode
  :after lsp-mode
  :config)

(use-package company
  :hook (after-init . global-company-mode)
  :config
  )

(use-package helm
  :config
  (helm-mode 1))

(use-package flycheck
  :init (global-flycheck-mode))

(use-package clang-format
  :bind (("C-c f" . clang-format-buffer)))

(use-package smartparens
  :hook (prog-mode . smartparens-mode))

(use-package magit)

(provide 'package)
