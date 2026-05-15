;;; init-consult.el --- Consult configuration  -*- lexical-binding: t; -*-

(use-package consult
  :straight (consult :host github :repo "minad/consult")
  :bind (;; replace isearch
         ("C-s" . consult-line)
         ;; search in git repo
         ("M-s g" . consult-ripgrep)
         ("C-c f" . consult-find)
         ("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop)
         ("C-x C-b" . consult-buffer))
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, scroll bars and adds some padding.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :config
  ;; Consult-line search from start
  (setq consult-line-start-from-top t))

(provide 'init-consult)
