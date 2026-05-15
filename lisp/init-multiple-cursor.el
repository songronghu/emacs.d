(use-package multiple-cursors
  :straight (multiple-cursors :host github :repo "magnars/multiple-cursors.el")
  :commands (mc/edit-lines
             mc/edit-ends-of-lines
             mc/edit-beginnings-of-lines
             ;; Mark additional regions matching current region
             mc/mark-all-dwim
             mc/mark-all-like-this
             mc/mark-previous-like-this
             mc/mark-next-like-this
             mc/mark-more-like-this-extended
             mc/mark-all-in-region
             ;; Symbol and word specific mark-more
             mc/mark-next-word-like-this
             mc/mark-previous-word-like-this
             mc/mark-all-words-like-this
             mc/mark-next-symbol-like-this
             mc/mark-previous-symbol-like-this
             mc/mark-all-symbols-like-this
             ;; Extra multiple cursors stuff
             mc/reverse-regions
             mc/sort-regions
             mc/insert-numbers
             mc/add-cursor-on-click)
  :bind (
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)
         ("C-S-c C-S-c" . mc/edit-lines)
         ("C-S-c C-e" . mc/edit-ends-of-lines)
         ("C-S-c C-a" . mc/edit-beginnings-of-lines)))

(provide 'init-multiple-cursor)
