;;; init-marginalia.el --- Marginalia configuration  -*- lexical-binding: t; -*-

(use-package marginalia
  :straight (marginalia :host github :repo "minad/marginalia")
  :init
  (marginalia-mode))

(provide 'init-marginalia)
