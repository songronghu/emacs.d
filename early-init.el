;;; -------------------- PERFORMANCE & HACKS
;; HACK: inscrease startup speed

(setq package-enable-at-startup nil)

(defcustom avoid-flash-options
  '((enabled          . t)
    (background       . "#2b313c")        ;; Catppuccin "#1e1e2e" / Crafters "#292D3E" / GITS #050810
    (foreground       . "#d8dee9")
    (reset-background . "#2b313c")
    (reset-foreground . "#EEFFFF"))       ;; Catppuccin "#cdd6f4" / Crafters "#EEFFFF" / GITS #68b8cc
  "Options to avoid flash of light on Emacs startup.
- `enabled`: Whether to apply the workaround.
- `background`, `foreground`: Initial colors to use.
- `reset-background`, `reset-foreground`: Optional explicit colors to restore after startup.

NOTE: The default values here presented are set for the default
`emacs-solo' custom theme.  If you'd like to turn this ON with another
theme, change the background/foreground variables.

If reset values are nil, nothing is reset."
  :type '(alist :key-type symbol :value-type (choice (const nil) string))
  :group 'emacs-solo)

;; Delay garbage collection while Emacs is booting
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Schedule garbage collection sensible defaults for after booting
(add-hook 'after-init-hook
          (lambda ()
            (setq gc-cons-threshold (* 100 1024 1024)
                  gc-cons-percentage 0.1)))

(setq load-prefer-newer t)

;; Do not native compile if on battery power
(setopt native-comp-async-on-battery-power nil) ; EMACS-31

;; HACK: avoid being flashbanged
(defun avoid-initial-flash-of-light ()
  "Avoid flash of light when starting Emacs, based on `emacs-solo-avoid-flash-options`."
  (when (alist-get 'enabled avoid-flash-options)
    (setq mode-line-format nil)
    (set-face-attribute 'default nil
                        :background (alist-get 'background avoid-flash-options)
                        :foreground (alist-get 'foreground avoid-flash-options))))

(defun reset-default-colors ()
  "Reset any explicitly defined reset values in `emacs-solo-avoid-flash-options`."
  (when (alist-get 'enabled avoid-flash-options)
    (let ((bg (alist-get 'reset-background avoid-flash-options))
          (fg (alist-get 'reset-foreground avoid-flash-options)))
      (when bg
        (set-face-attribute 'default nil :background bg))
      (when fg
        (set-face-attribute 'default nil :foreground fg)))))

(avoid-initial-flash-of-light)
(add-hook 'after-init-hook #'reset-default-colors)

;; Always start Emacs and new frames maximized
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Better Window Management handling
(setq frame-resize-pixelwise t
      frame-inhibit-implied-resize t
      frame-title-format
      '(:eval
        (let ((project (project-current)))
          (if project
              (concat "Emacs - [p] " (project-name project))
            (concat "Emacs - " (buffer-name))))))

(setq inhibit-compacting-font-caches t)

;; Disables unused UI Elements
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'tooltip-mode) (tooltip-mode -1))
(if (fboundp 'fringe-mode) (fringe-mode -1))
