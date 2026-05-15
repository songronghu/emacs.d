;;; init-vertico.el --- Vertico configuration  -*- lexical-binding: t; -*-

(use-package vertico
  :straight (vertico :host github :repo "minad/vertico")
  :init
  (vertico-mode)

  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;; (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  (setq vertico-cycle t))

(provide 'init-vertico)
