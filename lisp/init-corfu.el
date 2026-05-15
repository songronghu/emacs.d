(use-package corfu
  :straight (corfu :host github :repo "minad/corfu") 
  :custom
  ;; Hi-lock: (("insert" . 'hi-yellow))
  ;; allow cycle select
  (corfu-cycle t)
  ;; only one candidate word, auto insert
  (corfu-on-exact-match 'insert)
  ;; enable auto completion
  (corfu-auto t)
  ;; preselect first candidate words.
  (corfu-preselect 'directory)
  (corfu-auto-delay 0.1)
  (corfu-auto-trigger ".")
  (corfu-auto-prefix 1)
  (corfu-quit-at-boundary nil)
  (corfu-quit-no-match t)
  :config
  (global-corfu-mode)
  (setq corfu-separator ?\s)
  (require 'corfu-history)
  ;; remember completion history
  (corfu-history-mode 1)
  (setq corfu-history-size 1000)
  (require 'corfu-popupinfo)
  ;; show doc floating window
  (corfu-popupinfo-mode 1)
  (setq corfu-popupinfo-delay 5)
  (setq corfu-count 15)

  ;; Insert directly after entering the prefix parameter
  (require 'corfu-indexed)
  (corfu-indexed-mode 1)
  (add-hook 'eshell-mode-hook (lambda ()
                                (setq-local corfu-auto nil)
                                (corfu-mode -1))))
(provide 'init-corfu)
