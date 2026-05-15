(use-package rime
  :straight (rime :host github :repo "DogLooksGood/emacs-rime")
  :after (dash)
  :init
  (setq rime-user-data-dir (expand-file-name "~/.config/fcitx/rime")
        default-input-method "rime"
        rime-show-candidate 'posframe)
  (setq rime-posframe-properties
        (list :background-color "#333333"
              :foreground-color "#dcdccc"
              :font "WenQuanYi Micro Hei Mono-14"
              :internal-border-width 1))
  :config
  (define-key rime-active-mode-map (kbd "M-o") #'rime--backspace)
  (define-key rime-active-mode-map (kbd "M-m") #'rime--return)
  (define-key rime-active-mode-map (kbd "M-h") #'rime--escape))

(provide 'init-rime)
