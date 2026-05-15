(use-package apheleia
  :straight t
  :bind ("M-g f" . apheleia-format-buffer)
  :config
  (apheleia-global-mode 1)
  (setq apheleia-format-after-save t)
  :hook ((prog-mode . apheleia-mode)))

(provide 'init-format)
