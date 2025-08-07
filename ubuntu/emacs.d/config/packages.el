;; -*- lexical-binding: t; -*-

(require 'package)

(setq package-enable-at-startup nil)
(setq package-archives `(("melpa" . "https://melpa.org/packages/")
			 ("gnu" . "https://elpa.gnu.org/packages/")))
(setq use-package-always-ensure t)

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)


(provide 'packages)
