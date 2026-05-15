(use-package block-nav
  :straight (block-nav :type git :host github :repo "nixin72/block-nav.el")
  :config
 (progn
    (setf block-nav-move-skip-shallower t
          block-nav-center-after-scroll t)))

(use-package avy
  :straight (avy :host github :repo "abo-abo/avy")
  :defer t
  :bind (
         ("s-d" . avy-goto-char)
         ("s-j" . avy-goto-word-1)
         ))

(provide 'init-avy)
