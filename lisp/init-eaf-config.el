(use-package eaf
  :bind (("s-w" . my/bm)
         ("s-f" . my/fm)
         ("s-g" . my/gm)
         ("s-n" . my/pdf)
         ("s-b" . my/eaf-save-bookmark))
  :load-path "/home/ronghusong/lazycat-emacs/site-lisp/extensions/emacs-application-framework/"
  :defer t
  :init
  :config
  (add-to-list 'load-path "/home/ronghusong/lazycat-emacs/site-lisp/extensions/emacs-application-framework/app/browser/")
  (add-to-list 'load-path "/home/ronghusong/lazycat-emacs/site-lisp/extensions/emacs-application-framework/app/file-manager/")
  (add-to-list 'load-path "/home/ronghusong/lazycat-emacs/site-lisp/extensions/emacs-application-framework/app/git/")
  (add-to-list 'load-path "/home/ronghusong/lazycat-emacs/site-lisp/extensions/emacs-application-framework/app/pdf-viewer/")
  (require 'eaf-browser)
  (require 'eaf-file-manager)
  (require 'eaf-git)
  (require 'eaf-pdf-viewer)
  (defun slurp (f)
    (with-temp-buffer
      (insert-file-contents f)
      (buffer-substring-no-properties
       (point-min)
       (point-max))))
  (defun my/bm ()
    (interactive)
    (let ((selected (completing-read
                     "Select URL: " (split-string
                                     (slurp "~/.config/bookmarks") "\n" t))))
      (let ((url (car (split-string
                       selected
                       " " t))))
        (if (string-match-p "\\http.*\\'" url)
            ;; Open selected url
            (eaf-open-browser url)
          ;; Search entered text
          (eaf-search-it selected)))))

  (defun my/eaf-save-bookmark ()
    (interactive)
    (let* ((url (eaf-get-path-or-url))
           (title (buffer-name))
           (file "~/.config/bookmarks"))
      (unless (file-exists-p file)
        (make-directory (file-name-directory file) t)
        (write-region "" nil file))
      (with-temp-buffer
        (insert-file-contents file)
        (unless (search-forward url nil t)
          (goto-char (point-max))
          (insert (format "%s %s\n" url title))
          (write-region (point-min) (point-max) file)))
      (message "Saved bookmark: %s" title)))

  (defun my/fm ()
    (interactive)
    (eaf-open-in-file-manager))

  (defun my/gm ()
    (interactive)
    (eaf-open-git))

  (defun my/pdf ()
    (interactive)
     (let ((file (read-file-name "Open PDF: ")))
    (eaf-open file)))

  (setq eaf-browser-continue-where-left-off t)
  (setq eaf-browser-default-search-engine "duckduckgo")
  (setq eaf-browser-enable-adblocker "true")
  (setq eaf-proxy-type "http")
  (setq eaf-proxy-host "127.0.0.1")
  (setq eaf-proxy-port "18080"))

(provide 'init-eaf-config)
