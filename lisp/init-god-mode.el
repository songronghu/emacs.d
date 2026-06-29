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

  ;; A as backspace key
  (define-key god-local-mode-map (kbd "A") 'my-dumb-del)

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
      (set-cursor-color "red")
      (setq cursor-type 'bar)))

  (define-minor-mode incarnate-mode
    "As normal but toggle to God mode on RET"
    :lighter " God-Inc"
    :keymap (let ((map (make-sparse-keymap)))
              (define-key map (kbd "S-<return>") 'unincarnate)
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

  (defun my-move-to-window-top ()
    (interactive)
    (move-to-window-line 0))

  (defun my-move-to-window-bottom ()
    (interactive)
    (move-to-window-line -1))

  ;; (define-key incarnate-mode-map (kbd "S-<return>") 'newline-and-indent)
  (define-key ctl-x-map (kbd "C-b") 'consult-buffer)

  (define-key god-local-mode-map (kbd "j") 'next-line)
  (define-key god-local-mode-map (kbd "k") 'previous-line)
  (define-key god-local-mode-map (kbd "h") (lambda () (interactive) (forward-word -1)))
  (define-key god-local-mode-map (kbd "l") #'forward-word)

  (define-key god-local-mode-map (kbd "N") #'my-move-to-window-top)
  (define-key god-local-mode-map (kbd "M") #'my-move-to-window-bottom)

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
