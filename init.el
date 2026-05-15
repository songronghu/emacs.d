;; init straight config
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         (or (bound-and-true-p straight-base-dir)
                             user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Batch declaration of Emacs 30 built-in packages to prevent straight
(dolist (pkg '(use-package bind-key seq eldoc flymake jsonrpc xref external-completion project eglot map))
  (straight-use-package `(,pkg :type built-in)))

;; install and init use-package
(straight-use-package 'use-package)
(straight-use-package 'transient)

(defcustom emacs-solo-enable-preferred-font t
           "Enable `emacs-solo-enable-preferred-font'."
           :type 'boolean
           :group 'emacs-solo)

;; (defcustom emacs-solo-preferred-font-name "JetBrainsMono Nerd Font"
;;(defcustom emacs-solo-preferred-font-name "Monaco"
(defcustom emacs-solo-preferred-font-name "JetBrains Mono"
           "The name of the font to be used.
           Examples: `Maple Mono NF' or `JetBrainsMono Nerd Font'."
           :type 'string
           :group 'emacs-solo)

(defcustom emacs-solo-preferred-font-sizes '(130 125)
           "List of default font sizes (first for macOS, second for GNU/Linux)."
           :type '(repeat integer)
           :group 'emacs-solo)

(use-package emacs
  :ensure nil
  :bind
  (("M-o" . other-window)
   ("M-j" . duplicate-dwim)
   ("M-g r" . recentf)
   ("M-s g" . grep)
   ("C-x ;" . comment-line)
   ("M-s f" . find-name-dired)
   ("C-x C-b" . ibuffer)
   ("C-x p l". project-list-buffers)
   ("C-x w t"  . window-layout-transpose)            ; EMACS-31
   ("C-x w r"  . window-layout-rotate-clockwise)     ; EMACS-31
   ("C-x w f h"  . window-layout-flip-leftright)     ; EMACS-31
   ("C-x w f v"  . window-layout-flip-topdown)       ; EMACS-31
   ("C-x 5 l"  . select-frame-by-name)
   ("C-x 5 s"  . set-frame-name)
   ("RET" . newline-and-indent)
   ("C-z" . nil)
   ("C-x C-z" . nil)
   ("C-M-z" . delete-pair)
   ("C-x C-k RET" . nil))
  :custom
  (text-mode-ispell-word-completion nil)
  (ad-redefinition-action 'accept)
  (auto-save-default t)
  (bookmark-file (expand-file-name "cache/bookmarks" user-emacs-directory))
  (calendar-latitude 42.36)                   ;; These are needed
  (calendar-longitude -42.36)                 ;; for M-x `sunrise-sunset'
  (calendar-location-name "Cambridge, MA")
  (column-number-mode t)
  (line-number-mode t)
  (line-spacing nil)
  (completion-ignore-case t)
  (completions-detailed t)
  (doc-view-resolution 200)
  (delete-by-moving-to-trash t)
  (delete-pair-blink-delay 0)
  (delete-pair-push-mark t)                   ; EMACS-31 for easy subsequent C-x C-x
  (display-line-numbers-width 4)
  (display-line-numbers-widen t)
  (display-fill-column-indicator-warning nil) ; EMACS-31
  (delete-selection-mode t)
  (enable-recursive minibuffers t)
  (frame-resize-pixelwise t)
  (help-window-select t)
  (history-length 300)
  (inhibit-startup-message t)
  (initial-scratch-message "")
  (ibuffer-human-readable-size t) ; EMACS-31
  (ielm-history-file-name (expand-file-name "cache/ielm-history.eld" user-emacs-directory)) ; EMACS-31
  (kill-do-not-save-duplicates t)
  (create-lockfiles nil)   ; No lock files
  (make-backup-files nil)  ; No backup files
  (multisession-directory (expand-file-name "cache/multisession/" user-emacs-directory))
  (native-comp-async-on-battery-power nil)  ; No compilations when on battery EMACS-31
  (pixel-scroll-precision-mode t)
  (pixel-scroll-precision-use-momentum nil)
  (project-list-file (expand-file-name "cache/projects" user-emacs-directory))
  (project-vc-extra-root-markers '("Cargo.toml" "package.json" "go.mod")) ; Excelent for mono repos with multiple langs, makes Eglot happy
  (ring-bell-function 'ignore)
  (read-answer-short t)
  (recentf-max-saved-items 300) ; default is 20
  (recentf-max-menu-items 15)
  (recentf-auto-cleanup (if (daemonp) 300 'never))
  (recentf-exclude (list "^/\\(?:ssh\\|su\\|sudo\\)?:"))
  (recentf-save-file (expand-file-name "cache/recentf" user-emacs-directory))
  (register-use-preview t)
  (resize-mini-windows 'grow-only)
  (scroll-conservatively 8)
  (scroll-margin 3)
  (savehist-save-minibuffer-history t)    ; t is default
  (savehist-additional-variables
   '(kill-ring                            ; clipboard
     register-alist                       ; macros
     mark-ring global-mark-ring           ; marks
     search-ring regexp-search-ring))     ; searches
  (savehist-file (expand-file-name "cache/history" user-emacs-directory))
  (save-place-file (expand-file-name "cache/saveplace" user-emacs-directory))
  (save-place-limit 600)
  (set-mark-command-repeat-pop t) ; So we can use C-u C-SPC C-SPC C-SPC... instead of C-u C-SPC C-u C-SPC...
  (split-width-threshold 170)     ; So vertical splits are preferred
  (split-height-threshold nil)
  (shr-use-colors nil)
  (switch-to-buffer-obey-display-actions t)
  (tab-always-indent 'complete)
  (tab-width 4)
  (transient-history-file (expand-file-name "cache/transient/history.el" user-emacs-directory))
  (transient-levels-file (expand-file-name "cache/transient/levels.el" user-emacs-directory))
  (transient-values-file (expand-file-name "cache/transient/values.el" user-emacs-directory))
  (treesit-font-lock-level 4)
  (treesit-auto-install-grammar t) ; EMACS-31
  (treesit-enabled-modes t)        ; EMACS-31
  (truncate-lines t)
  (undo-limit (* 13 160000))
  (undo-strong-limit (* 13 240000))
  (undo-outer-limit (* 13 24000000))
  (url-configuration-directory (expand-file-name "cache/url/" user-emacs-directory))
  (use-dialog-box nil)
  (use-file-dialog nil)
  (use-package-hook-name-suffix nil)
  (use-short-answers t)
  (visible-bell nil)
  (window-combination-resize t)
  (window-resize-pixelwise nil)
  (xref-search-program 'ripgrep)        ; TODO: make it dinamic check if ripgrep is available before setting it and if it costs too much of the init time
  (zone-all-frames t)            ; EMACS-31
  (zone-all-windows-in-frame t)  ; EMACS-31
  (zone-programs '[zone-pgm-rat-race])
  (grep-find-ignored-directories
   '("SCCS" ".gradle" "CVS" ".m2" ".src" ".svn" ".jj" ".git" ".hg" ".bzr" "_MTN" "_darcs" "{arch}" "node_modules" "build" "dist"))
  :config
  (setq custom-file (locate-user-emacs-file "custom-vars.el"))
  (load custom-file 'noerror 'nomessage)
  (modify-coding-system-alist 'file "" 'utf-8)
  ;; Setup preferred fonts when present on System
  (declare-function emacs-solo/setup-font "")
  (defun emacs-solo/setup-font ()
    (let* ((emacs-solo-have-default-font (find-font (font-spec :family emacs-solo-preferred-font-name)))
           (size (nth (if (eq system-type 'darwin) 0 1)
                      emacs-solo-preferred-font-sizes))
           (chinese-font-name  "Microsoft YaHei UI"))
      (set-face-attribute 'default nil
                          :family (when emacs-solo-have-default-font
                                    emacs-solo-preferred-font-name)
                          :height size)
      (when (display-grayscale-p)
        (dolist (charset '(kana han symbol cjk-misc bopomofo))
          (set-fontset-font (frame-parameter nil 'font) charset (font-spec :family (eval chinese-font-name)))))))

  ;; Load Preferred Font Setup
  (when emacs-solo-enable-preferred-font
    (emacs-solo/setup-font))

  ;; We want auto-save, but no #file# cluterring, so everything goes under our config cache/
  (make-directory (expand-file-name "cache/auto-saves/" user-emacs-directory) t)
  (setq auto-save-list-file-prefix (expand-file-name "cache/auto-saves/sessions/" user-emacs-directory)
        auto-save-file-name-transforms `((".*" ,(expand-file-name "cache/auto-saves/" user-emacs-directory) t)))

  (setq ibuffer-show-empty-filter-groups nil) ; don't show empty groups

  :init
  ;; Keep margins from automatic resizing
  (defun emacs-solo/set-default-window-margins ()
    "Set default left and right margins for all windows.
    Unless the buffer uses `emacs-solo/center-document-mode`
    or is an ERC buffer."
    (interactive)
    (dolist (window (window-list))
      (with-current-buffer (window-buffer window)
        (unless (or (bound-and-true-p emacs-solo/center-document-mode)
                    (derived-mode-p 'erc-mode))
          (set-window-margins window 0 0))))) ;; (LEFT RIGHT)

  (add-hook 'window-configuration-change-hook #'emacs-solo/set-default-window-margins)

  (tooltip-mode nil)

  (select-frame-set-input-focus (selected-frame))
  (blink-cursor-mode 0)
  (recentf-mode 1)
  (repeat-mode 1)
  (savehist-mode 1)
  (save-place-mode 1)
  (winner-mode)
  (xterm-mouse-mode 1)
  (file-name-shadow-mode 1) ; allows us to type a new path without having to delete the current one
  (global-display-line-numbers-mode 1)

  (with-current-buffer (get-buffer-create "*scratch*")
    (insert (format ";;   Loading time : %s
;;   Packages     : %s
"
                    (emacs-init-time)
                    (number-to-string (length package-activated-list)))))
  (message (emacs-init-time)))

(use-package eglot
             :ensure nil
             :custom
             (eglot-autoshutdown t)
             (eglot-events-buffer-size 0) ;; EMACS-31 -- do we still need it?
             (eglot-events-buffer-config '(:size 0 :format full))
             (eglot-prefer-plaintext nil)
             (jsonrpc-event-hook nil)
             (eglot-code-action-indications nil) ;; EMACS-31 -- annoying as hell
             :init
             (fset #'jsonrpc--log-event #'ignore)

             (setq-default eglot-workspace-configuration (quote
                                                           (:gopls (:hints (:parameterNames t)))))
             (setq eglot-report-progress nil)

             (defun emacs-solo/eglot-setup ()
               "Setup eglot mode with specific exclusions."
               (unless (memq major-mode '(emacs-lisp-mode lisp-mode))
                 (eglot-ensure)))

             (add-hook 'prog-mode-hook #'emacs-solo/eglot-setup)

             (with-eval-after-load 'eglot
                                   (add-to-list
                                     'eglot-server-programs
                                     '((ruby-mode ruby-ts-mode) "ruby-lsp")))

             (with-eval-after-load 'eglot
                                   (add-to-list
                                     'eglot-server-programs
                                     '((tsx-ts-mode typescript-ts-mode js-mode js-jsx-mode js-ts-mode)
                                       . ("rass"
                                          "--"
                                          "typescript-language-server" "--stdio"
                                          "--"
                                          "eslint-lsp" "--stdio"
                                          "--"
                                          "tailwindcss-language-server" "--stdio"))))

             (with-eval-after-load 'eglot
                                   (add-to-list
                                     'eglot-server-programs
                                     '((clojure-mode clojurescript-mode) . ("clojure-lsp"))))
             ;; (with-eval-after-load 'eglot
             ;;   (add-to-list
             ;;    'eglot-server-programs
             ;;    '((java-mode java-ts-mode) . ("jdtls"
             ;;                                  "-configuration" "/home/ronghusong/software/opensoft/jdtls/config_linux/"
             ;;                                  "-data" "/home/ronghusong/.cache/jdtls/"))))
             :bind (:map
                     eglot-mode-map
                     ("C-7" . eglot-find-declaration)
                     ("C-8" . eglot-find-implementation)
                     ("C-c l a" . eglot-code-actions)
                     ("C-c l o" . eglot-code-action-organize-imports)
                     ("C-c l r" . eglot-rename)
                     ("C-c l i" . eglot-inlay-hints-mode)
                     ("C-c l f" . eglot-format)))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(let ((default-directory (expand-file-name "site-lisp" user-emacs-directory)))
    (normal-top-level-add-subdirs-to-load-path))

(require 'server)

(unless (server-running-p)
    (server-start))

(setenv "http_proxy"  "http://127.0.0.1:18080")
(setenv "https_proxy" "http://127.0.0.1:18080")

(require 'init-rime)
(require 'init-tookit)
(require 'init-eaf-config)
(require 'init-fingertip)
(require 'init-sort-tab)
(require 'init-expand-region)
(require 'init-toggle-one-window)
(require 'init-vertico)
(require 'init-marginalia)
(require 'init-consult)
(require 'init-yasnippet)
(require 'init-multiple-cursor)
(require 'init-format)
(require 'init-eshell)
(require 'init-avy)
(require 'init-corfu)
(require 'init-orderless)
(require 'init-eglot-java)
(require 'init-eca)
(require 'init-translate)
(require 'init-god-mode)
(require 'init-cider)

(provide 'init)
