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

(provide 'init-sort-tab)
