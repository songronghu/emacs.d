(defvar my/eshell-where-file
  "/home/ronghusong/src/github/emacs-solo/eshell/.where")

(defvar my/eshell-where-cache '())
(defvar my/eshell-where-dirty nil)

(defun my/eshell--load-where ()
  "启动时加载一次文件"
  (when (file-exists-p my/eshell-where-file)
    (with-temp-buffer
      (insert-file-contents my/eshell-where-file)
      (setq my/eshell-where-cache (split-string (buffer-string) "\n" t)))))

(defun my/eshell--save-where ()
  "将缓存写入磁盘（仅在有变化时建议调用）"
   (when my/eshell-where-dirty
    (setq my/eshell-where-dirty nil)
    (let ((dir (file-name-directory my/eshell-where-file)))
      (unless (file-directory-p dir) (make-directory dir t)))
    (with-temp-file my/eshell-where-file
      (insert (mapconcat #'identity my/eshell-where-cache "\n")))))

(defun my/eshell--add-path (path)
  "更新缓存：排重并置顶最新路径"
  (let ((abs (directory-file-name (expand-file-name path))))
    ;; 只有当路径不在首位时才操作，减少不必要的重绘/写入
    (unless (string= abs (car my/eshell-where-cache))
      (setq my/eshell-where-cache (cons abs (delete abs my/eshell-where-cache)))
      (setq my/eshell-where-dirty t)
      ;; 限制 3000 条最常用记录，保证搜索速度
      (when (> (length my/eshell-where-cache) 3000)
        (setcdr (nthcdr 2999 my/eshell-where-cache) nil)))))

(defun my/eshell--match-history (input)
  "在历史中进行关键词过滤"
  (let ((kws (split-string input " " t)))
    (seq-filter
     (lambda (path)
       (cl-every (lambda (k) (string-search k path)) kws))
     my/eshell-where-cache)))

(defun my/eshell-smart-cd (orig-fun &rest args)
  "核心 cd 逻辑"
  (let* ((input (string-join args " "))
         (abs-input (and (not (string-empty-p input)) (expand-file-name input))))
    (cond
     ;; 1. 如果输入已经是存在的目录，直接去，不搜索历史
     ((and abs-input (file-directory-p abs-input))
      (apply orig-fun (list abs-input)))

     ;; 2. 如果输入不是目录，尝试在历史中模糊匹配
     ((not (string-empty-p input))
      (let ((matches (my/eshell--match-history input)))
        (pcase (length matches)
          (0 (apply orig-fun args)) ;; 没找到，交给原函数（报错）
          (1 (apply orig-fun (list (car matches)))) ;; 唯一匹配
          (_ (let ((choice (completing-read "Jump to: " matches nil t))) ;; 多个匹配
               (when choice (apply orig-fun (list choice))))))))

     ;; 3. 无参数 cd (回主目录)
     (t (apply orig-fun args)))))

;;ssh主机列表
(defvar my/eshell-ssh-host-cache nil)

(defun my/eshell--load-ssh-hosts ()
  (unless my/eshell-ssh-host-cache
    (let ((ssh-config (expand-file-name "~/.ssh/config")))
      (when (file-exists-p ssh-config)
        (with-temp-buffer
          (insert-file-contents ssh-config)
          (let (res)
            (goto-char (point-min))
            (while (re-search-forward
                    "^[ \t]*Host[ \t]+\\([^ \t\n\*]+\\)" nil t)
              (push (match-string 1) res))
            (setq my/eshell-ssh-host-cache
                  (delete-dups (nreverse res))))))))
  my/eshell-ssh-host-cache)

(defun my/term-ssh ()
  "用 ansi-term 连接 ssh（带补全）"
  (interactive)
  (let* ((hosts (my/eshell--load-ssh-hosts))
         (host (completing-read "SSH to: " hosts nil t)))
    (when (and host (not (string-empty-p host)))
      ;; 打开 term
      (let ((buf (ansi-term "/bin/bash")))
        (with-current-buffer buf
          ;; 重命名 buffer
          (rename-buffer (format "*ssh:%s*" host) t)
          ;; 发送 ssh 命令
          (term-send-raw-string (format "ssh %s\n" host)))))))

;; 初始化加载
(my/eshell--load-where)

;; 运行 30 秒空闲时才写入磁盘，避免高频操作
(run-with-idle-timer 30 t #'my/eshell--save-where)

(with-eval-after-load 'eshell
  ;; 拦截 cd 命令
  (advice-add 'eshell/cd :around #'my/eshell-smart-cd)

  ;; 挂载钩子：只要目录变了就记录（涵盖了 cd, pushd, 以及插件跳转）
  (add-hook 'eshell-directory-change-hook
            (lambda () (when default-directory (my/eshell--add-path default-directory))))

  (add-hook 'eshell-mode-hook
            (lambda ()
              (local-set-key (kbd "<f8>") #'my/term-ssh))))

(provide 'init-eshell)
