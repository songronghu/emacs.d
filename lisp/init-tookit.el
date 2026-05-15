;;; init-tookit.el --- Edit files as root via TRAMP  -*- lexical-binding: t; -*-
(use-package tookit
  :ensure nil
  :defer t
  :init
  (require 'auto-save)
  (auto-save-enable)
  (require 'subword)
  (require 'automagic-dark-mode)
  (defun open-newline-above (arg)
    "Move to the previous line (like vi) and then opens a line."
    (interactive "p")
    (beginning-of-line)
    (open-line arg)
    (if (not (member major-mode '(haskell-mode org-mode literate-haskell-mode)))
        (indent-according-to-mode)
      (beginning-of-line)))

  (defun open-newline-below (arg)
    "Move to the next line (like vi) and then opens a line."
    (interactive "p")
    (end-of-line)
    (open-line arg)
    (call-interactively 'next-line arg)
    (if (not (member major-mode '(haskell-mode org-mode literate-haskell-mode)))
        (indent-according-to-mode)
      (beginning-of-line)))

  (defun delete-block-forward ()
    (interactive)
    (if (eobp)
        (message "End of buffer")
      (let* ((syntax-move-point
              (save-excursion
                (skip-syntax-forward (string (char-syntax (char-after))))
                (point)
                ))
             (subword-move-point
              (save-excursion
                (subword-forward)
                (point))))
        (kill-region (point) (min syntax-move-point subword-move-point)))))

  (defun delete-block-backward ()
    (interactive)
    (if (bobp)
        (message "Beginning of buffer")
      (let* ((syntax-move-point
              (save-excursion
                (skip-syntax-backward (string (char-syntax (char-before))))
                (point)
                ))
             (subword-move-point
              (save-excursion
                (subword-backward)
                (point))))
        (kill-region (point) (max syntax-move-point subword-move-point)))))

  (defun scroll-up-one-line()
    "Scroll up one line."
    (interactive)
    (scroll-up 1))

  (defun scroll-down-one-line()
    "Scroll down one line."
    (interactive)
    (scroll-down 1))

  (defun forward-word-begin ()
    "Move point to beginning of next word."
    (interactive)
    (forward-to-word 1)
    (skip-syntax-forward " "))

  (defun move-text-internal (arg)
    (cond
     ((and mark-active transient-mark-mode)
      (if (> (point) (mark))
          (exchange-point-and-mark))
      (let ((column (current-column))
            (text (delete-and-extract-region (point) (mark))))
        (forward-line arg)
        (move-to-column column t)
        (set-mark (point))
        (insert text)
        (exchange-point-and-mark)
        (setq deactivate-mark nil)))
     (t
      (let ((column (current-column)))
        (beginning-of-line)
        (when (or (> arg 0) (not (bobp)))
          (forward-line)
          (when (or (< arg 0) (not (eobp)))
            (transpose-lines arg)
            (when (and
                   ;; Account for changes to transpose-lines in Emacs 24.3
                   (eval-when-compile
                     (not (version-list-<
                           (version-to-list emacs-version)
                           '(24 3 50 0))))
                   ;; Make `move-text-up' works with Emacs 26.0
                   (eval-when-compile
                     (version-list-<
                      (version-to-list emacs-version)
                      '(26 0 50 1)))
                   (< arg 0))
              (forward-line -1)))
          (forward-line -1))
        (move-to-column column t)))))

  (defun move-text-down (arg)
    "Move region (transient-mark-mode active) or current line
  arg lines down."
    (interactive "*p")
    (move-text-internal arg))

  (defun move-text-up (arg)
    "Move region (transient-mark-mode active) or current line
  arg lines up."
    (interactive "*p")
    (move-text-internal (- arg)))
  (global-set-key (kbd "C-c b") 'automagic-dark-mode)
  (global-set-key (kbd "C-M-y") #'up-list)
  (global-set-key (kbd "s-P") #'move-text-up)
  (global-set-key (kbd "s-N") #'move-text-down)
  (global-set-key (kbd "M-p") #'forward-word-begin)
  (global-set-key (kbd "s-J") #'scroll-up-one-line)
  (global-set-key (kbd "s-K") #'scroll-down-one-line)
  (global-set-key (kbd "C-o") #'open-newline-above)
  (global-set-key (kbd "C-l") #'open-newline-below)
  (global-set-key (kbd "M-m") #'delete-block-forward)
  (global-set-key (kbd "M-n") #'delete-block-backward))
 
(provide 'init-tookit)
;;; init-tookit.el ends here
