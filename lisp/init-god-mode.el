;;;; init-god-mode.el --- God-mode configuration

;;; Commentary:
;;
;; This file contains the configuration for god-mode,
;; a global minor mode for Emacs that provides a vi-like modal editing experience.

;;; Code:

(use-package god-mode
  :straight (god-mode :host github :repo "emacsorphanage/god-mode")
  :config
  (setq god-exempt-major-modes nil)
  (setq god-exempt-predicates nil)

  (defvar my-god-scroll-count 1
    "Current number of accelerated scrolling steps。")

  (defvar my-god-last-command-time 0.0
    "The time when the acceleration movement command was last executed。")

  (defvar my-god-last-accel-cmd nil
    "Independently record the last movement direction to avoid being
intercepted by the bottom layer of Viper。")

  (defun my-god--accelerated-step (current-cmd)
    "Dynamically calculate scroll steps based on consecutive keystroke
speed and independent command history.。"
    (let* ((now (float-time))
           (delta (- now my-god-last-command-time)))
      ;; 1. Determine whether they are consecutive in the same direction (eq current-cmd my-viper-last-accel-cmd)
      ;; 2. The time difference is relaxed to 0.35 seconds, which is enough to cover the initial delay of human manual double press and system long press
      (if (and (eq current-cmd my-god-last-accel-cmd)
               (< delta 0.18))
          (setq my-god-scroll-count (min (+ my-god-scroll-count 1) 8))
        ;; If direction changes or pauses for too long, reset to 1.
        (setq my-god-scroll-count 1))
      ;; update state record
      (setq my-god-last-command-time now)
      (setq my-god-last-accel-cmd current-cmd)
      my-god-scroll-count))

  (defun my-god-next-line (&optional arg)
    "move down，Supports prefix parameters and continuous key acceleration。"
    (interactive "p")
    (if current-prefix-arg
        (progn
          ;; If a numeric prefix is ​​used（eg: 5j），Actively clear our acceleration pool records
          (setq my-god-last-accel-cmd nil)
          (next-line arg))
      ;; pass 'j to get the number of acceleration steps
      (next-line (my-god--accelerated-step 'j))))

  (defun my-god-previous-line (&optional arg)
    "move up，Supports prefix parameters and continuous key acceleration。"
    (interactive "p")
    (if current-prefix-arg
        (progn
          (setq my-god-last-accel-cmd nil)
          (previous-line arg))
      ;; pass 'k to get the number of acceleration steps.
      (previous-line (my-god--accelerated-step 'k))))

  (defun my-god-backward-char (&optional arg)
    "move left，Supports prefix parameters and continuous key acceleration。"
    (interactive "p")
    (if current-prefix-arg
        (progn
          (setq my-god-last-accel-cmd nil)
          (backward-char arg))
      ;; pass 'h to get the number of acceleration steps.
      (backward-char (my-god--accelerated-step 'h))))

  (defun my-god-forward-char (&optional arg)
    "move right，Supports prefix parameters and continuous key acceleration。"
    (interactive "p")
    (if current-prefix-arg
        (progn
          (setq my-god-last-accel-cmd nil)
          (forward-char arg))
      ;; pass 'l to get the number of acceleration steps.
      (forward-char (my-god--accelerated-step 'l))))

  ;; cursor type
  (defun my-god-mode-update-cursor-type ()
    (setq cursor-type (if (or god-local-mode buffer-read-only) 'box 'bar)))

  (add-hook 'post-command-hook #'my-god-mode-update-cursor-type)

  ;; insert one char
  (define-key god-local-mode-map (kbd "o") 'insert-one-character)

  (defun insert-one-character (times)
    (interactive "p")
    (overwrite-mode 1)
    (dotimes (x times) (quoted-insert 1))
    (overwrite-mode 0))

  ;; overight-insert
  (define-key god-local-mode-map (kbd ">") 'overwrite-insert)

  (defun overwrite-insert (times)
    (interactive "p")
    (delete-char times)
    (insert-one-character times))

  ;; insert spc
  (define-key god-local-mode-map (kbd "O") 'spacer)

  (defun spacer (times)  (interactive "p") (dotimes (x times) (insert " ")))

  ;; h as backspace key
  (define-key god-local-mode-map (kbd "h") 'my-dumb-del)

  (defun my-dumb-del ()
    (interactive)
    (setq unread-command-events (listify-key-sequence "\C-\?")))

  ;; (define-key god-local-mode-map (kbd "i") 'type-quickly-or-incarnate)
  (define-key god-local-mode-map (kbd "i") 'incarnate)

  (defun unincarnate ()
    (interactive)
    (cond (completion-in-region-mode
           (call-interactively #'corfu-insert))
          (t
           (incarnate-mode -1)
           (setq cursor-type 'box)
           (god-local-mode 1)
           (set-cursor-color "#b0381e"))))

  (defun incarnate ()
    (interactive)
    (when (bound-and-true-p god-local-mode)
      (god-local-mode 0)
      (incarnate-mode 1)
      (set-cursor-color "black")
      (setq cursor-type 'bar)))

  (define-minor-mode incarnate-mode
    "As normal but toggle to God mode on RET"
    :lighter " God-Inc"
    :keymap (let ((map (make-sparse-keymap)))
              (define-key map (kbd "<return>") 'unincarnate)
              map))

  (defun type-something-quickly ()
    (interactive)
    (run-with-idle-timer 2 nil #'(lambda () (god-local-mode 1)))
    (god-local-mode -1))

  (defun type-quickly-or-incarnate ()
    (interactive)
    (if (display-graphic-p)
        (type-something-quickly)
      (incarnate)))

  (define-key incarnate-mode-map (kbd "S-<return>") 'newline-and-indent)

  (define-key ctl-x-map (kbd "C-b") 'consult-buffer)

  (define-key god-local-mode-map (kbd "n") #'my-god-next-line)
  (define-key god-local-mode-map (kbd "p") #'my-god-previous-line)
  (define-key god-local-mode-map (kbd "b") #'my-god-backward-char)
  (define-key god-local-mode-map (kbd "f") #'my-god-forward-char)

  ;; block-nav
  (define-key god-local-mode-map (kbd "J")  'block-nav-next-block)
  (define-key god-local-mode-map (kbd "K")  'block-nav-previous-block)
  (define-key god-local-mode-map (kbd "H")  'block-nav-previous-indentation-level)
  (define-key god-local-mode-map (kbd "L")  'block-nav-next-indentation-level)

  (define-key god-local-mode-map (kbd "C-;") (lambda () (interactive) (insert ";")))
  (global-set-key (kbd ";") #'(lambda () (interactive) (god-local-mode 1)))
  (define-key god-local-mode-map (kbd ".") #'repeat)
  (define-key god-local-mode-map (kbd "[") #'backward-paragraph)
  (define-key god-local-mode-map (kbd "]") #'forward-paragraph)

  (global-set-key (kbd "C-x C-1") #'delete-other-windows)
  (global-set-key (kbd "C-x C-2") #'split-window-below)
  (global-set-key (kbd "C-x C-3") #'split-window-right)
  (global-set-key (kbd "C-x C-0") #'delete-window))

(provide 'init-god-mode)
;;; init-god-mode.el ends here
