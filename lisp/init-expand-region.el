(use-package expand-region
  :straight (expand-region :host github :repo "magnars/expand-region.el")
  :bind ("C-=" . er/expand-region))

(provide 'init-expand-region)
