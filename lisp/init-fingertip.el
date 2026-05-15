(use-package fingertip
  :straight (fingertip :host github :repo "manateelazycat/fingertip")
  :hook ((c-mode-common . fingertip-mode)
         (c-mode-common-hook . fingertip-mode)
         (c-mode-hook . fingertip-mode)
         (c++-mode-hook . fingertip-mode)
         (java-mode-hook . fingertip-mode)
         (haskell-mode-hook . fingertip-mode)
         (emacs-lisp-mode-hook . fingertip-mode)
         (lisp-interaction-mode-hook . fingertip-mode)
         (lisp-mode-hook . fingertip-mode)
         (clojure-mode-hook . fingertip-mode)
         (sh-mode-hook . fingertip-mode)
         (makefile-gmake-mode-hook . fingertip-mode)
         (php-mode-hook . fingertip-mode)
         (python-mode-hook . fingertip-mode)
         (js-mode-hook . fingertip-mode)
         (go-mode-hook . fingertip-mode)
         (qml-mode-hook . fingertip-mode)
         (css-mode-hook . fingertip-mode)
         (ruby-mode-hook . fingertip-mode)
         (coffee-mode-hook . fingertip-mode)
         (rust-mode-hook . fingertip-mode)
         (rust-ts-mode-hook . fingertip-mode)
         (qmake-mode-hook . fingertip-mode)
         (lua-mode-hook . fingertip-mode)
         (swift-mode-hook . fingertip-mode)
         (web-mode-hook . fingertip-mode)
         (markdown-mode-hook . fingertip-mode)
         (llvm-mode-hook . fingertip-mode)
         (conf-toml-mode-hook . fingertip-mode)
         (nim-mode-hook . fingertip-mode)
         (typescript-mode-hook . fingertip-mode)
         (c-ts-mode-hook . fingertip-mode)
         (c++-ts-mode-hook . fingertip-mode)
         (cmake-ts-mode-hook . fingertip-mode)
         (toml-ts-mode-hook . fingertip-mode)
         (css-ts-mode-hook . fingertip-mode)
         (js-ts-mode-hook . fingertip-mode)
         (json-ts-mode-hook . fingertip-mode)
         (python-ts-mode-hook . fingertip-mode)
         (bash-ts-mode-hook . fingertip-mode)
         (typescript-ts-mode-hook . fingertip-mode))
  :bind (:map fingertip-mode-map
              ("%" . fingertip-match-paren)            ;括号跳转
              ("(" . fingertip-open-round)             ;智能 (
              ("[" . fingertip-open-bracket)           ;智能 [
              ("{" . fingertip-open-curly)             ;智能 {
              (")" . fingertip-close-round)            ;智能 )
              ("]" . fingertip-close-bracket)          ;智能 ]
              ("}" . fingertip-close-curly)            ;智能 }
              ("（" . fingertip-open-chinese-round)    ;智能 （
              ("「" . fingertip-open-chinese-bracket)  ;智能 「
              ("【" . fingertip-open-chinese-curly)    ;智能 【
              ("）" . fingertip-close-chinese-round)   ;智能 ）
              ("」" . fingertip-close-chinese-bracket) ;智能 」
              ("】" . fingertip-close-chinese-curly)   ;智能 】
              ("\"" . fingertip-double-quote)          ;智能 "
              ("'" . fingertip-single-quote)           ;智能 '
              ("=" . fingertip-equal)                  ;智能 =
              ("SPC" . fingertip-space)                ;智能 space
              ("RET" . fingertip-newline)              ;智能 newline
              ;; 删除
              ;; ("M-o" . fingertip-backward-delete) ;向后删除
              ;; ("C-d" . fingertip-forward-delete)  ;向前删除
              ("C-k" . fingertip-kill)            ;向前kill
              ;; 包围
              ("M-\"" . fingertip-wrap-double-quote) ;用 " " 包围对象, 或跳出字符串
              ("M-'" . fingertip-wrap-single-quote) ;用 ' ' 包围对象, 或跳出字符串
              ("M-[" . fingertip-wrap-bracket)      ;用 [ ] 包围对象
              ("M-{" . fingertip-wrap-curly)        ;用 { } 包围对象
              ("M-(" . fingertip-wrap-round)        ;用 ( ) 包围对象
              ("M-)" . fingertip-unwrap)            ;去掉包围对象
              ;; 跳出并换行缩进
              ("M-:" . fingertip-jump-out-pair-and-newline) ;跳出括号并换行
              ;; 向父节点跳动
              ("C-j" . fingertip-jump-up))
  :defer t)

(provide 'init-fingertip)
;;;init-fingertip.el ends here
