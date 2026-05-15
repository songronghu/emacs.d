;;;###autoload
(defun emacs-solo/google-translate-at-point-zh-en ()
  "Translate Chinese to English at point."
  (interactive)
  (let ((google-translate-default-source-language "zh-CN")
        (google-translate-default-target-language "en"))
    (call-interactively 'google-translate-at-point)))

;;;###autoload
(defun emacs-solo/google-translate-query-translate-zh-en ()
  "Translate Chinese to English with query."
  (interactive)
  (let ((google-translate-default-source-language "zh-CN")
        (google-translate-default-target-language "en"))
    (call-interactively 'google-translate-query-translate)))

(use-package google-translate
  :straight (google-translate :host github :repo "atykhonov/google-translate")
  :init
  ;; 绑定快捷键
  (bind-keys ("C-c t" . google-translate-at-point)
             ("C-c T" . google-translate-query-translate)
             ("C-c c" . emacs-solo/google-translate-at-point-zh-en)
             ("C-c C" . emacs-solo/google-translate-query-translate-zh-en))
  :config
  ;; 必须引入默认 UI 模块，否则会报错
  ;;(require 'google-translate-default-ui)
  (require 'google-translate-smooth-ui)

  (setq google-translate-default-source-language "en")
  (setq google-translate-default-target-language "zh-CN")

  (setq google-translate-backend-method 'curl))

(provide 'init-translate)
