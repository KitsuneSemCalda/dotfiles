(use-package lsp-mode
  :hook ((c-mode c++-mode) . lsp)
  :custom
  (lsp-clients-clangd-executable "clangd")
  (lsp-enable-symbol-highlighting nil)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-prefer-capf t)
  (lsp-idle-delay 0.3))

(use-package lsp-ui
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-doc-sideline-enable nil))

(use-package company
  :after lsp-mode)

(use-package ccls
  :if (executable-find "ccls")
  :hook ((c-mode c++-mode objc-mode) . (lambda () (require 'ccls) (lsp)))
  :custom (ccls-executable "ccls"))

(provide 'lang-cpp)
