;; init.el --- My config -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
;; useful for quickly debugging Emacs
;; (setq debug-on-error t)

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
;; End straight config

;; Keep custom-set-variables and friends out of my init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

(defcustom my-cache-directory
  (expand-file-name "cache/" user-emacs-directory)
  "Base directory for cache files.
All entries in `my-cache-paths' are resolved relative to this
directory.  Choose one of the presets or supply any custom directory path.
Changes take effect after restarting Emacs."
  :type `(choice
          (const     :tag "Inside Emacs config  (cache/ in user-emacs-directory)"
                     ,(expand-file-name "cache/" user-emacs-directory))
          (const     :tag "System temp          (/tmp/emacs-cache/)" "/tmp/emacs-cache/")
          (directory :tag "Custom directory"))
  :group 'my)

(defvar my-cache-paths
  '(;; Files:
    (bookmark-file               . "bookmarks")
    (project-list-file           . "projects")
    (recentf-save-file           . "recentf")
    (savehist-file               . "history")
    (save-place-file             . "saveplace")
    (transient-history-file      . "transient/history.el")
    (transient-levels-file       . "transient/levels.el")
    (transient-values-file       . "transient/values.el")
    (tramp-persistency-file-name . "tramp")
    ;; Directories:
    (auto-saves                  . "auto-saves/")
    (auto-saves-sessions         . "auto-saves/sessions/")
    (multisession-directory      . "multisession/")
    (undo-fu-session             . "undo-fu-session"))
  "Alist of (KEY . RELATIVE-PATH) for cache locations.
RELATIVE-PATH is resolved against `my-cache-directory'.
A trailing slash on RELATIVE-PATH marks the entry as a directory.")

(defun my--cache-path (key)
  "Return the absolute path for KEY in `my-cache-paths'."
  (let ((rel (cdr (assq key my-cache-paths))))
    (unless rel
      (error "my--cache-path: Unknown key %S" key))
    (expand-file-name rel my-cache-directory)))

(defun my--ensure-cache-dirs ()
  "Create every directory referenced by `my-cache-paths'.
Entries ending in `/' are created directly; other entries have their
parent directory created."
  (dolist (entry my-cache-paths)
    (let* ((abs (my--cache-path (car entry)))
           (dir (if (directory-name-p abs)
                    abs
                  (file-name-directory abs))))
      (make-directory dir t))))

(my--ensure-cache-dirs)

;;; ASYNC
;; Emacs look SIGNIFICANTLY less often which is a good thing.
;; asynchronous bytecode compilation and various other actions makes
(use-package async
  :straight t
  :after dired
  :init
  (dired-async-mode 1))

(use-package savehist
  :defer 2
  :init
  (savehist-mode t)
  ;; So I can always jump back to wear I left of yesterday
  (add-to-list 'savehist-additional-variables 'global-mark-ring))

(use-package repeat
  :ensure nil
  :defer 10
  :config
  (repeat-mode +1))

(use-package devil
  :straight t
  :demand t
  :bind ("<xf86back>" . keyboard-escape-quit)
  :config
  (global-devil-mode 1)
  (setq overriding-text-conversion-style nil))

;;; MY STUFF
(use-package custom-variables
  :ensure nil :no-require t :demand t
  :init
  (cl-defmacro let-regex ((bindings (string regex)) &body body)
    "Macro for creating BINDINGS to captured blocks of REGEX found in a STRING.
BINDINGS: A list of different symbols to be bound to a captured section of the regex
STRING: The string the regex is searching through
REGEX: Regex used to match against the string

If no binding is captured section of regex is found for a BINDING an error is signaled
   ;; Example usage
   (let-regex ((h w) (\"hello world\" \"\\(hello\\) \\(world\\)\"))
                (message \"result was %s then %s\" h w))"
    (let ((holder (gensym)))
      `(let ((,holder (with-temp-buffer
                        (insert ,string)
                        (beginning-of-buffer)
                        (search-forward-regexp ,regex nil nil)
                        (let ((i 0))
                          (mapcar (lambda (_a)
                                    (setq i (+ i 1))
                                    (match-string i))
                                  '( ,@bindings))))))
         (let ,(mapcar (lambda (binding)
                         `(,binding (or (pop ,holder)
                                        (error "Failed to find binding for %s"
                                               ',binding))))
                       bindings)
           ,@body))))
  (defvar my/is-termux
    (string-match-p "android" system-configuration)
    "Truthy value indicating if Emacs is currently running in termux.")
  (defvar my/is-terminal
    (not window-system)
    "Truthy value indicating if Emacs is currently running in a terminal.")
  (defvar my/my-system
    (equal "ronghusong" (getenv "USER"))
    "Non-nil value if this is my system."))

(use-package undo-fu-session ; Persistant undo history
  :straight (undo-fu-session :host github :repo "emacsmirror/undo-fu-session")
  :bind (("C-x u"   . undo-only)
         ("C-/" . undo-only)
         ("C-?" . undo-redo)
         ("C-z"     . undo-only)
         ("C-S-z"   . undo-redo))
  :custom
  (undo-fu-session-directory (my--cache-path 'undo-fu-session))
  :hook (after-init . global-undo-fu-session-mode))

(use-package emacs
  :ensure nil
  :demand t
  :bind (("C-c w"   . fixup-whitespace)
         ("C-x C-d" . delete-pair)
         ("M-c"     . capitalize-dwim)
         ("M-u"     . upcase-dwim)
         ("M-l"     . downcase-dwim)
         ("M-z"     . zap-up-to-char)
         ("C-x S"   . shell)
         ("C-x M-t" . transpose-regions)
         ("C-;"     . negative-argument)
         ("C-M-;"   . negative-argument)
         ("C-g"     . my/keyboard-quit-only-if-no-macro)
         ("M-o" . other-window)
         ("M-g r" . recentf)
	 ("M-g e" . eshell)
	 ("s-f" . dirvish)
         )
  :config
  ;; According to the POSIX, a line is defined as "a sequence of zero or
  ;; more non-newline characters followed by a terminating newline".
  (setopt require-final-newline t)
  (setopt kill-region-dwim 'emacs-word)
  (defun my-pulse-on-nav (&rest _)
    (require 'pulse)
    (let ((bounds (bounds-of-thing-at-point 'word)))
      (if bounds
	  ;; If there is a word at the cursor, only flash the word area
          (pulse-momentary-highlight-region (car bounds) (cdr bounds))
	;; If the cursor is blank or has a newline character (word boundary cannot be found), the current line will be downgraded and flashed to avoid unresponsiveness.
	(pulse-momentary-highlight-one-line (point)))))
  (defun my/keyboard-quit-only-if-no-macro ()
    "A workaround to let me accidently hit C-g while recording a macro"
    (interactive)
    (if (or defining-kbd-macro executing-kbd-macro)
        (progn
          (if (region-active-p)
              (deactivate-mark)
            (message "Macro running. Can't quit.")))
      (keyboard-quit)))
  (advice-add 'pop-to-mark-command :after #'my-pulse-on-nav)
  (advice-add 'pop-global-mark :after #'my-pulse-on-nav)
  ;; Configure the flashing color of pulse
  (with-eval-after-load 'pulse
    (set-face-attribute 'pulse-highlight-start-face nil 
                        :background "#f1fa8c"   
                        :weight 'bold))        
    
  ;; Set the title of the frame to the current file - Emacs
  (setq-default frame-title-format '("%b - Emacs"))

  ;; No delay when deleting pairs
  (setopt delete-pair-blink-delay 0)
  (blink-cursor-mode -1)
  ;; change truncation indicators
  (define-fringe-bitmap 'right-curly-arrow
    [#b10000000 #b10000000 #b01000000
                #b01000000 #b00100000 #b00100000
                #b00010000 #b00010000 #b00001000
                #b00001000 #b00000100 #b00000100])
  (define-fringe-bitmap 'left-curly-arrow
    [#b00000100 #b00000100 #b00001000
                #b00001000 #b00010000 #b00010000
                #b00100000 #b00100000 #b01000000
                #b01000000 #b10000000 #b10000000])
  ;;;; Defaults
  ;; Handle long lines
  (setopt bidi-paragraph-direction 'left-to-right)
  (setopt bidi-inhibit-bpa t)
  (global-so-long-mode 1)

  (setopt history-length 1000
          use-dialog-box nil
          delete-by-moving-to-trash t
          create-lockfiles nil
          auto-save-default nil
	  auto-save-list-file-prefix nil
          ring-bell-function 'ignore
          delete-pair-push-mark t)

  ;;;; UTF-8
  (prefer-coding-system 'utf-8)
  ;;;; Remove Extra Ui
  (setopt use-short-answers t) ; don't ask to spell out "yes"
  (setopt show-paren-context-when-offscreen 'overlay) ; Emacs 29
  (show-paren-mode 1)              ; Highlight parenthesis

  ;; don't show welcome page
  (setq inhibit-startup-message t)
  (setq initial-scratch-message "")
  
  ;; close auto backup
  (setq make-backup-files nil)
  (setq-default select-enable-primary t)

  ;; avoid leaving a gap between the frame and the screen
  (setq-default frame-resize-pixelwise t)

  ;; Vim like scrolling
  (setq scroll-step            1
        scroll-conservatively  10000
        next-screen-context-lines 5
        ;; move by logical lines rather than visual lines (better for macros)
        line-move-visual nil)

  ;;TRAMP
  (setq tramp-default-method "ssh"
        shell-file-name "bash")

  ;; line-nubmer
  (global-display-line-numbers-mode 1)
  (setq display-line-numbers-type 'relative)
  
  ;; For using local lsp's with tramp
  ;; (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  ;; recentf
  (setopt recentf-make-menu-items 150)
  (setopt recentf-make-saved-items 150)
  (pixel-scroll-precision-mode t)
  
  (with-current-buffer (get-buffer-create "*scratch*")
    (insert (format ";;  Loading time : %s
;;  Packages     : %s\n"
		    (emacs-init-time)
		    (number-to-string (length features))))
    (run-with-idle-timer
     0 nil
     (lambda ()
       (when (string= (buffer-name) "*scratch*")
         (goto-char (point-max))
         ))))
  ;; setting cache dir 
  :custom
  (ielm-history-file-name (my--cache-path 'ielm-history-file-name)) ; EMACS-31
  (recentf-save-file (my--cache-path 'recentf-save-file))
  (project-list-file (my--cache-path 'project-list-file))
  (savehist-file (my--cache-path 'savehist-file))
  (save-place-file (my--cache-path 'save-place-file))
  (transient-history-file (my--cache-path 'transient-history-file))
  (transient-levels-file (my--cache-path 'transient-levels-file))
  (transient-values-file (my--cache-path 'transient-values-file))
  (setopt tramp-persistency-file-name (my--cache-path 'tramp-persistency-file-name)))

(use-package dired
  :ensure nil
  :config
  ;; dired - reuse current buffer by pressing 'a'
  (put 'dired-find-alternate-file 'disabled nil)

  ;; always delete and copy recursively
  (setq dired-recursive-deletes 'always)
  (setq dired-recursive-copies 'always)

  ;; if there is a dired buffer displayed in the next window, use its
  ;; current subdir, instead of the current subdir of this dired buffer
  (setq dired-dwim-target t)

  ;; drag files from dired to other apps
  (setq dired-mouse-drag-files t)

  ;; enable some really cool extensions like C-x C-j(dired-jump)
  (require 'dired-x))

;;; General Key Bindings
(use-package crux
  :straight t
  :bind (("C-c o" . crux-open-with)
	 ("C-a" . crux-move-beginning-of-line)
         ("C-l" . crux-smart-open-line)
         ("C-c n" . crux-cleanup-buffer-or-region)
         ("C-c f" . crux-recentf-find-file)
         ("C-M-z" . crux-indent-defun)
         ("C-c u" . crux-view-url)
         ("C-c e" . crux-eval-and-replace)
	 ("C-x w v" . crux-swap-windows)
         ("C-c D" . crux-delete-file-and-buffer)
         ("C-c r" . crux-rename-buffer-and-file)
         ("C-c r" . crux-rename-file-and-buffer)
	 ("C-c t" . crux-visit-term-buffer)
	 ("C-c k" . crux-kill-other-buffers)
	 ("C-c TAB" . crux-indent-rigidly-and-copy-to-clipboard)
	 ("C-c I" . crux-find-user-init-file)
	 ("C-c S" . crux-find-shell-init-file)
	 ("s-r" . crux-recentf-find-file)
	 ("s-j" . crux-top-join-line)
	 ("C-^" . crux-top-join-line)
	 ("C-k" . crux-kill-whole-line)
	 ("C-<backspace>" . crux-kill-line-backwards)
	 ("C-o" . crux-smart-open-line-above)
	 ([remap move-beginning-of-line] . crux-move-beginning-of-line)
         ([(shift return)] . crux-smart-open-line)
         ([(control shift return)] . crux-smart-open-line-above)
         ([remap kill-whole-line] . crux-kill-whole-line)
	 ("C-c s" . crux-ispell-word-then-abbrev)
	 ("C-x B"   . my/org-scratch)
	 ("M-j" . crux-duplicate-current-line-or-region)
	 ("C-c ;" . crux-duplicate-and-comment-current-line-or-region))
  :config
  (defun my/org-scratch ()
    (interactive)
    (let ((initial-major-mode 'org-mode))
      (crux-create-scratch-buffer)))
  (with-eval-after-load 'dired
    (define-key dired-mode-map (kbd "O") #'crux-open-with)))

;; diff-hl - highlight uncommitted changes in the fringe
(use-package diff-hl
  :straight (diff-hl :host github :repo "dgutov/diff-hl")
  :config
  (global-diff-hl-mode +1)
  (add-hook 'dired-mode-hook 'diff-hl-dired-mode))

;; diminish - hide minor modes from the mode line
(use-package diminish
  :straight (diminish :type git :host github :repo "emacsmirror/diminish")
  :init
  :config
  (diminish 'abbrev-mode)
  (diminish 'flyspell-mode)
  (diminish 'flyspell-prog-mode)
  (diminish 'eldoc-mode))

;; paredit - structural editing for s-expressions
(use-package paredit
  :straight (paredit :host github :repo "emacsmirror/paredit")
  :config
  ;; paredit steals RET for auto-newline-and-indent, which is annoying
  (define-key paredit-mode-map (kbd "RET") nil)
  (define-key paredit-mode-map (kbd ";") nil)
  (add-hook 'paredit-mode-hook (lambda () (electric-pair-local-mode -1)))
  (add-hook 'emacs-lisp-mode-hook #'paredit-mode)
  ;; enable in the *scratch* buffer
  (add-hook 'lisp-interaction-mode-hook #'paredit-mode)
  (add-hook 'ielm-mode-hook #'paredit-mode)
  (add-hook 'lisp-mode-hook #'paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'paredit-mode)
  (diminish 'paredit-mode "()"))

;; anzu - show total search matches and current position in mode line
(use-package anzu
  :straight (anzu :host github :repo "emacsorphanage/anzu")
  :bind (("M-%" . anzu-query-replace)
         ("C-M-%" . anzu-query-replace-regexp))
  :config
  (global-anzu-mode))

;; easy-kill - enhanced M-w with easy selection of nearby things
(use-package easy-kill
  :straight t
  :config
  (global-set-key [remap kill-ring-save] 'easy-kill))

;; rainbow-delimiters - colorize nested parentheses by depth
(use-package rainbow-delimiters 
  :straight (rainbow-delimiters :host github :repo "Fanael/rainbow-delimiters")
  :defer t)

;; rainbow-mode - colorize color strings like #ff0000 and rgb(...)
(use-package rainbow-mode
  :straight (rainbow-mode :host github :repo "emacs-straight/rainbow-mode")
  :config
  (add-hook 'prog-mode-hook #'rainbow-mode)
  (diminish 'rainbow-mode))

(use-package font-setup 
  :ensure nil 
  :no-require t
  :demand t
  :when my/my-system
  :init
  ;; Fonts
  ;; The concise one which relies on "implicit fallback values"
  (use-package fontaine
    :straight t
    :unless my/is-terminal
    :config
    (setopt fontaine-presets
            '((regular
	       :default-height 140)
	      (small
	       :default-height 110)
	      (large
	       :default-weight semilight
	       :default-height 180
	       :bold-weight extrabold)
	      (extra-large
	       :default-weight semilight
	       :default-height 210
	       :line-spacing 5
	       :bold-weight ultrabold)
	      (t                    
	       :default-family "JetBrains Mono")))
    (fontaine-set-preset 'small))

  (defun my/setup-chinese-font ()
    "Setup Chinese font fallback."
    (when (display-graphic-p)
      (let ((yahei-font "Microsoft YaHei UI"))
        (dolist (charset '(kana han cjk-misc bopomofo symbol))
          (set-fontset-font
           t
           charset
           (font-spec :family yahei-font))))))
  (add-hook 'after-init-hook #'my/setup-chinese-font))

;;; Themeing
;;; Theme
;; (use-package sublime-themes
;;   :straight t
;;   :config
;;   (load-theme 'brin t))

;; (use-package doom-themes
;;   :straight t
;;   :config
;; (load-theme 'doom-one t))
(use-package modus-themes
  :straight t
  :init
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts t
        modus-themes-variable-pitch-ui nil
        modus-themes-custom-auto-reload t)

  ;; more closer Ubuntu/Yaru Dark
  (setq modus-vivendi-palette-overrides
        '((bg-main "#2b313c")
          (bg-dim "#232831")
          (bg-alt "#303846")
          (fg-main "#d8dee9")
          (accent-0 "#81a1c1")
          (accent-1 "#88c0d0")
          (accent-2 "#a3be8c")
          (accent-3 "#ebcb8b")));
  (load-theme 'modus-vivendi t))

;; (use-package ef-themes
;;   :straight t
;;   :init
;;   ;; This makes the Modus commands listed below consider only the Ef
;;   ;; themes.  For an alternative that includes Modus and all
;;   ;; derivative themes (like Ef), enable the
;;   ;; `modus-themes-include-derivatives-mode' instead.  The manual of
;;   ;; the Ef themes has a section that explains all the possibilities:
;;   ;;
;;   ;; - Evaluate `(info "(ef-themes) Working with other Modus themes or taking over Modus")'
;;   ;; - Visit <https://protesilaos.com/emacs/ef-themes#h:6585235a-5219-4f78-9dd5-6a64d87d1b6e>
;;   (ef-themes-take-over-modus-themes-mode 1)
;;   :bind
;;   (("<f5>" . modus-themes-rotate)
;;    ("C-<f5>" . modus-themes-select))
;;   :config
;;   ;; All customisations here.
;;   (setq modus-themes-mixed-fonts t)
;;   (setq modus-themes-italic-constructs t)

;;   ;; Finally, load your theme of choice (or a random one with
;;   ;; `modus-themes-load-random', `modus-themes-load-random-dark',
;;   ;; `modus-themes-load-random-light').
;;   (modus-themes-load-theme 'ef-summer))
(use-package spacious-padding
  :straight t
  :hook (after-init . spacious-padding-mode)
  :custom
  ;; make the modeline look minimal
  (spacious-padding-subtle-mode-line '( :mode-line-active default
					:mode-line-inactive vertical-border)))

;;; Aligning Text
(use-package align
  :ensure nil
  :defer t
  :bind ("C-x a a" . align-regexp)
  :config
  ;; Align using spaces
  (defun align-regexp-with-spaces (ogfn &rest args)
    (let ((indent-tabs-mode nil))
      (apply ogfn args)))
  (advice-add 'align-regexp :around #'align-regexp-with-spaces))

;;; COMPLETION
(use-package vertico
  :straight (vertico :host github :repo "minad/vertico")
  :init
  ;; Enable vertico using the vertico-flat-mode
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)
  (use-package orderless
    :straight (orderless :host github :repo "oantolin/orderless")
    :commands (orderless)
    :custom (completion-styles '(orderless flex)))
  (use-package marginalia
    :straight (marginalia :host github :repo "minad/marginalia")
    :custom
    (marginalia-annotators
     '(marginalia-annotators-heavy marginalia-annotators-light nil))
    :config
    (marginalia-mode))
  (vertico-mode t)
  :config
  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t)
  (minibuffer-depth-indicate-mode 1))

;;;; Extra Completion Functions
(use-package consult
  :straight (consult :host github :repo "minad/consult")
  :after vertico
  :bind (("C-x b"       . consult-buffer)
         ("C-x C-k C-k" . consult-kmacro)
         ("M-y"         . consult-yank-pop)
         ("M-g g"       . consult-goto-line)
         ("M-g M-g"     . consult-goto-line)
         ("M-g f"       . consult-flymake)
         ("M-g i"       . consult-imenu)
         ("M-g I"       . consult-imenu-multi)
         ("M-s l"       . consult-line)
         ("M-s L"       . consult-line-multi)
         ("M-s u"       . consult-focus-lines)
         ("M-s g"       . consult-ripgrep)
         ("M-s M-g"     . consult-ripgrep)
         ("M-s f"       . consult-find)
         ("M-s M-f"     . consult-find)
         ("C-x C-SPC"   . consult-global-mark)
         ("M-G"   . consult-global-mark)
         ("C-i"   . pop-to-mark-command)
         ("C-x M-:"     . consult-complex-command)
         ("C-c n"       . consult-org-agenda)
         ("M-X"         . consult-mode-command)
         :map minibuffer-local-map
         ("M-r" . consult-history)
         :map Info-mode-map
         ("M-g i" . consult-info)
         ("M-g i" . consult-org-heading))
  :custom
  (completion-in-region-function #'consult-completion-in-region)
  :config
  ;; 1. Expand the capacity of the marking ring (the default is 16, changing it to 64 is more convenient)
  (setq mark-ring-max 64)
  (setq global-mark-ring-max 64)
  (recentf-mode t)
  (defun my/quick-calc ()
    (interactive)
    (insert (consult--read
             (consult--process-collection
		 (lambda (input)
                   (list "qalc" "-t" (string-trim input))))
             :prompt "run qalc: "))))

(use-package consult-dir
  :straight (consult-dir :host github :repo "karthink/consult-dir")
  :defer t
  :bind (("C-x C-j" . consult-dir)
         :map vertico-map
         ("C-x C-j" . consult-dir)))

(use-package consult-recoll
  :straight (consult-recoll :host github :repo "emacsmirror/consult-recoll")
  ;;:vc (:url "https://codeberg.org/jao/consult-recoll.git")
  :bind (("M-s r" . consult-recoll))
  :init
  (setq consult-recoll-inline-snippets t)
  :config
  (defconst recollindex-buffer "*RECOLLINDEX*")
  (defun my/kill-recoll-index ()
    (interactive)
    (let ((proc (get-buffer-process (get-buffer recollindex-buffer))))
      (when (process-live-p proc)
        (kill-process proc))))
  (defun my/recoll-index (&optional _args)
    "Start indexing deamon if there is not one running already.
This way our searches are kept up to date"
    (interactive)
    (let ((recollindex-buffer "*RECOLLINDEX*"))
      (unless (process-live-p (get-buffer-process (get-buffer recollindex-buffer)))
        (make-process :name "recollindex"
		      :buffer recollindex-buffer
		      :command '("recollindex" "-m" "-D")))))
  (eval-after-load 'consult-recoll
    (my/recoll-index))

  ;; Keeping this here until the next release
  (defun consult-recoll--search (&optional initial)
    "Perform an asynchronous recoll search via `consult--read'.
If given, use INITIAL as the starting point of the query."
    (consult--read (consult--async-pipeline
                    (consult--process-collection #'consult-recoll--command)
                    (consult--async-map #'consult-recoll--transformer)
                    (consult--async-filter #'identity))
                   :annotate #'consult-recoll--annotation
                   :prompt consult-recoll-prompt
                   :require-match t
                   :lookup #'consult--lookup-member
                   :sort nil
                   :state (and (not consult-recoll-inline-snippets)
			       #'consult-recoll--preview)
                   :group (and consult-recoll-group-by-mime
			       #'consult-recoll--group)
                   :initial initial
                   :history '(:input consult-recoll-history)
                   :category 'recoll-result)))

(use-package embark
  :straight (embark :host github :repo "oantolin/embark")
  :bind
  ;; pick some comfortable binding
  (("C-="                     . embark-act)
   ([remap describe-bindings] . embark-bindings)
   :map embark-file-map
   ("C-d" . dragon-drop)
   :map embark-defun-map
   ("M-t" . chatgpt-gen-tests-for-defun)
   :map embark-general-map
   ("M-c" . chatgpt-prompt)
   ("z"   . chatgpt-send-to-gptel-session)
   :map embark-region-map
   ("z"   . chatgpt-send-to-gptel-session)
   ("D"   . dictionary-search)
   ("?"   . chatgpt-explain-region)
   ("M-f" . chatgpt-fix-region))
  :custom
  (embark-indicators
   '(embark-highlight-indicator
     embark-isearch-highlight-indicator
     embark-verbose-indicator))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  ;;(setq embark-prompter 'embark-completing-read-prompter)
  :config
  (defun dragon-drop (file)
    (start-process-shell-command "dragon-drop" nil
                                 (concat "dragon-drop " file)))

  ;; Preview any command with M-.
  (keymap-set minibuffer-local-map "M-." 'my-embark-preview)
  (defun my-embark-preview ()
    "Previews candidate in vertico buffer, unless it's a consult command"
    (interactive)
    (unless (bound-and-true-p consult--preview-function)
      (save-selected-window
        (let ((embark-quit-after-action nil))
          (embark-dwim))))))

;; Helpful for editing consult-grep
(use-package wgrep :straight t :after embark
  :bind
  (:map grep-mode-map
        ("C-x C-q" . wgrep-change-to-wgrep-mode)))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :straight t
  :defer t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; For uploading files
(use-package 0x0
  :straight (0x0 :host github :repo "emacsmirror/0x0")
  :after embark
  :bind (
         :map embark-file-map
         ("U"    . 0x0-upload-file)
         :map embark-region-map
         ("U"    . 0x0-dwim))
  :commands (0x0-dwim 0x0-upload-file))

(use-package completion-preview
  :hook (prog-mode . completion-preview-mode)
  :bind (:map completion-preview-active-mode-map
	      ("C-i" . completion-preview-insert)
	      ("M-n" . completion-preview-insert-word)
	      ("M-p" . completion-preview-prev-candidate))
  :custom
  (completion-preview-minimum-symbol-length 1))

;;;; Code Completion
(use-package corfu
  :straight t
  ;; Optional customization
  :custom
  (corfu-cycle t)                 ; Allows cycling through candidates
  (corfu-auto t)                  ; Enable auto completion
  (corfu-auto-prefix 10)
  (corfu-auto-trigger ".")
  (corfu-auto-delay 0.1)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-preview-current 'insert) ; insert previewed candidate
  (corfu-preselect 'prompt)
  (corfu-on-exact-match nil)      ; Don't auto expand tempel snippets
  ;; Optionally use TAB for cycling, default is `corfu-complete'.
  :bind (:map corfu-map
	      ("M-SPC"      . corfu-insert-separator)
	      ("TAB"        . corfu-next)
	      ([tab]        . corfu-next)
	      ("S-TAB"      . corfu-previous)
	      ([backtab]    . corfu-previous)
	      ("S-<return>" . corfu-insert)
	      ("RET"        . nil))
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode)) ; Popup completion info

(use-package keycast
  :straight t
  :defer t
  :commands (keycast-mode-line-mode))

;;; Server Setup
(use-package server
  :ensure nil
  :init
  :config
  (unless (server-running-p)
    (server-start)))

(use-package tramp
  :defer t  
  :config
  (setq tramp-persistency-file-name (my--cache-path 'tramp-persistency-file-name)))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(let ((default-directory (expand-file-name "site-lisp" user-emacs-directory)))
  (normal-top-level-add-subdirs-to-load-path))

(setenv "http_proxy"  "http://127.0.0.1:18080")
(setenv "https_proxy" "http://127.0.0.1:18080")

(use-package elisp-mode
  :ensure nil ; not a real package
  :config
  (defun bozhidar-visit-ielm ()
    "Switch to default `ielm' buffer.
Start `ielm' if it's not already running."
    (interactive)
    (require 'crux)
    (crux-start-or-switch-to 'ielm "*ielm*"))

  (add-hook 'emacs-lisp-mode-hook #'rainbow-delimiters-mode)
  (define-key emacs-lisp-mode-map (kbd "C-c C-z") #'bozhidar-visit-ielm)
  (define-key emacs-lisp-mode-map (kbd "C-c C-c") #'eval-defun)
  (define-key emacs-lisp-mode-map (kbd "C-c C-b") #'eval-buffer))

(use-package cider
  :straight t
  :config
  ;; log nREPL messages for debugging connection issues
  (setq nrepl-log-messages t)
  ;; auto-download Java sources for navigation/documentation
  (setq cider-download-java-sources t)
  (add-hook 'cider-repl-mode-hook #'paredit-mode)
  (add-hook 'cider-repl-mode-hook #'rainbow-delimiters-mode))

;;A minimalist Clojure interactive programming environment for Emacs
(use-package port
  :straight (port :type git :host github :repo "clojure-emacs/port"
                  :files ("lisp/*.el"))
  :hook ((clojure-mode    . port-mode)
         (clojure-ts-mode . port-mode)))

(use-package block-nav
  :straight (block-nav :type git :host github :repo "nixin72/block-nav.el")
  :config
  (progn
    (setf block-nav-move-skip-shallower t
          block-nav-center-after-scroll t)))

(use-package avy
  :straight (avy :host github :repo "abo-abo/avy")
  :defer t
  :bind (("s-." . avy-goto-word-or-subword-1)
         ("s-," . avy-goto-char)
         ("C-c ." . avy-goto-word-or-subword-1)
         ("C-c ," . avy-goto-char)
         ("M-g l" . avy-goto-line)
         ("M-g w" . avy-goto-word-or-subword-1))
  :config
  (setq avy-background t))

(use-package eca
  :straight (eca :host github :repo "editor-code-assistant/eca-emacs")
  :after transient)

(use-package expand-region
  :straight (expand-region :host github :repo "magnars/expand-region.el")
  :bind ("M-=" . er/expand-region))

(use-package multiple-cursors
  :straight t
  :bind (;; Call with a 0 arg to skip one
         ("C-M-." . mc/mark-next-like-this)
         ("C-M-," . mc/mark-previous-like-this))
  :config
  ;; Use phi-search to replace isearch when using multiple cursors
  (defun toggle-corfu-auto-for-mc (&optional _arg)
    (if multiple-cursors-mode
        (corfu-mode -1)
      (corfu-mode 1)))
  (cl-pushnew 'toggle-corfu-auto-for-mc multiple-cursors-mode-hook))

(use-package sort-tab
  :straight (sort-tab :host github :repo "manateelazycat/sort-tab")
  :config
  (sort-tab-mode t)
  (global-set-key (kbd "M-7") #'sort-tab-select-prev-tab)    ;select previous tab
  (global-set-key (kbd "M-8") #'sort-tab-select-next-tab)    ;select next tab
  (global-set-key (kbd "M-s-7") #'sort-tab-select-first-tab) ;select first tab
  (global-set-key (kbd "M-s-8") #'sort-tab-select-last-tab)  ;select last tab
  (global-set-key (kbd "s-k") #'sort-tab-close-current-tab)  ;close current tab
  (global-set-key (kbd "s-q") #'sort-tab-close-other-tabs)   ;close backgroud tabs
  (global-set-key (kbd "s-Q") #'sort-tab-close-all-tabs))    ;close all tabs

(use-package toggle-one-window
  :straight (toggle-one-window :host github :repo "manateelazycat/toggle-one-window")
  :defer t
  :bind (("M-s-o" . toggle-one-window)))

(use-package yasnippet
  :straight (yasnippet :host github :repo "joaotavora/yasnippet")
  :config
  (yas-global-mode 1))

(use-package dirvish			
  :straight (dirvish :host github :repo "alexluigit/dirvish")
  :config
  (dirvish-override-dired-mode 1)
  (setq dired-listing-switches "-Alho --group-directories-first")
  ;; bind hjkl
  (define-key dired-mode-map (kbd "h") 'dired-up-directory)      
  (define-key dired-mode-map (kbd "j") 'dired-next-line)         
  (define-key dired-mode-map (kbd "k") 'dired-previous-line)     
  (define-key dired-mode-map (kbd "l") 'dired-find-file)

  (define-key dired-mode-map (kbd "J")
    (lambda () (interactive) (goto-char (point-max)) (dired-previous-line 1)))
  (define-key dired-mode-map (kbd "K")
    (lambda () (interactive) (goto-char (point-min))))
  
  (define-key dired-mode-map (kbd "n") 'dired-create-empty-file)
  (define-key dired-mode-map (kbd "N") 'dired-create-directory)
    
  ;; l bind to dired-do-redisplay before，now bind to r
  (define-key dired-mode-map (kbd "r") 'dired-do-redisplay))

(require 'init-rime)
(require 'init-tookit)
(require 'init-god-mode)
(require 'init-eaf)
(require 'init-eshell)
(require 'init-translate)
;; (require 'init-fingertip)
;; (require 'init-format)
(require 'init-eglot-java)

(provide 'init)
