(use-package project
  :straight (:type built-in))

(use-package eglot
  :straight (:type built-in))

(use-package eglot-java
  :straight (eglot-java :host github :repo "yveszoundi/eglot-java")
  :ensure nil
  :init
  (setq eglot-java-server-install-dir
        "/home/ronghusong/software/opensoft/jdtls")

  (defun custom-eglot-java-init-opts (server eglot-java-eclipse-jdt)
    "custom JDTLS settings，include Google Style format。"
    '(:settings
      (:java
       (:format
        (:settings
         (:url "/home/ronghusong/software/opensoft/jdtls/eclipse-java-google-style.xml"
               :enabled t))))))

  (setq eglot-java-user-init-opts-fn #'custom-eglot-java-init-opts)

  :config
  (add-hook 'java-mode-hook #'eglot-java-mode)
  (add-hook 'java-ts-mode-hook #'eglot-java-mode)

  (define-key eglot-java-mode-map (kbd "C-c l n") #'eglot-java-file-new)
  (define-key eglot-java-mode-map (kbd "C-c l x") #'eglot-java-run-main)
  (define-key eglot-java-mode-map (kbd "C-c l t") #'eglot-java-run-test)
  (define-key eglot-java-mode-map (kbd "C-c l N") #'eglot-java-project-new)
  (define-key eglot-java-mode-map (kbd "C-c l T") #'eglot-java-project-build-task)
  (define-key eglot-java-mode-map (kbd "C-c l R") #'eglot-java-project-build-refresh))

(provide 'init-eglot-java)
