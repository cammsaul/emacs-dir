;;; cam-functions -- Utility function used by other init files
;;; Commentary:
;;; Code:

(defun cam/popup-cam-menu ()
  "Show the 'CAM :)' menu as a popup menu."
  (interactive)
  (popup-menu cam-menu))

(defun cam/join-next-line ()
  "Basically like C-e C-k then deleting leftover space."
  (interactive)
  (join-line -1))

(defun cam/untabify-current-buffer ()
  "Run untabify over the entire current buffer."
  (interactive)
  (untabify (point-min) (point-max)))

(defun cam/lorem-ipsum ()
  "Insert a lorem ipsum."
  (interactive)
  (insert "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do "
          "eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim"
          "ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut "
          "aliquip ex ea commodo consequat. Duis aute irure dolor in "
          "reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla "
          "pariatur. Excepteur sint occaecat cupidatat non proident, sunt in "
          "culpa qui officia deserunt mollit anim id est laborum."))

(defun cam/mark-whole-sexp ()
  (progn
    (backward-sexp)
    (mark-sexp)))

(defun cam/current-token ()
  "Returns the entire current sexp"
  (save-excursion
    (cam/mark-whole-sexp)
    (buffer-substring (region-beginning) (region-end))))

(defun cam/active-region-or-prompt (prompt)
  (url-hexify-string (if mark-active
                         (buffer-substring (region-beginning) (region-end))
                       (read-string prompt))))

(defun cam/coffee-house ()
  "You are working in a coffee house."
  (interactive)
  (browse-url "http://www.coffitivity.com/"))

(defun cam/bing-search ()
  "Bings a query or region if any."
  (interactive)
  (browse-url
   (concat
    "http://www.bing.com/search?setmkt=en-US&q="
    (cam/active-region-or-prompt "Search Bing for: "))))

(defun cam/stackoverflow-search ()
  "Searches Stack Overflow for current region, or prompts for query if none exists."
  (interactive)
  (browse-url
   (concat
    "http://stackoverflow.com/search?q="
    (cam/active-region-or-prompt "Search Stack Overflow for: "))))

(defun cam/backward-kill-line ()
  "Calls (kill-line 0), which kills line from current cursor position to beginning of line."
  (interactive)
  (kill-line 0))

(defun eval-and-replace ()
  "Replace the preceding sexp with its value"
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

(defun cam/force-indent-region ()
  "Indent a region, overriding normal indentation behavior."
  (interactive)
  (indent-rigidly (region-beginning) (region-end) 4))

(defun cam/force-unindent-region ()
  "Unindent a region, overriding normal indentation behavior."
  (interactive)
  (indent-rigidly (region-beginning) (region-end) -4))

(defun cam/windmove-left-or-other-frame ()
  "Move one window to the left, or to the frame one position before the current frame."
  (interactive)
  (condition-case nil
      (windmove-left)
    (error (other-frame -1))))

(defun cam/windmove-right-or-other-frame ()
  "Move one window to the right, or to the frame one position before the current frame."
  (interactive)
  (condition-case nil
      (windmove-right)
    (error (other-frame 1))))

(defun cam/switch-to-nav-buffer-other-window ()
  "Switch to the *nav* buffer"
  (interactive)
  (switch-to-buffer-other-window "*nav*"))

(defun menu-edit-file (str f)
  (vector str (list 'lambda '() '(interactive) (list 'find-file f))))

(defun menu-edit-init-file (f)
  (menu-edit-file (file-name-base f) f))

(defun cam/is-init-file-p (filename)
  "Return t if FILENAME is ~/.emacs.d/init.el or in ~/.emacs.d/ directory; nil in any other case."
  (condition-case nil
      (or (file-equal-p filename "~/.emacs.d/init.el")
          (unless (string-match "flycheck" filename)
            (and (string= (file-name-extension filename)
                          "el")
                 (file-in-directory-p filename "~/.emacs.d/lisp"))))
    (error nil)))

(defun cam/noop (&rest args)
  "A function that ignores ARGS and doesn't do anything."
  nil)

(defun sandbox/install-and-require (package &rest more-packages)
  "Install PACKAGE if needed, require it for sandbox testing."
  (let ((package-name (symbol-name package)))
    (condition-case err
        (progn
          (unless (package-installed-p package)
            (message "--SANDBOX-- Installing package: %s..." package-name)
            (cam/refresh-package-contents-once)
            (package-install package))
          (package-activate package)
          (require package)
          (message "--SANDBOX-- Loaded package %s." package-name))
      (error (warn "--SANDBOX-- Failed to install %s: %s" package-name (error-message-string err)))))
  (when more-packages
    (apply 'sandbox/install-and-require more-packages)))

(defun cam/add-semicolon-to-eol ()
  "Add a semicolon to the end of current line without affecting point."
  (interactive)
  (save-excursion
    (end-of-line)
    (insert ";")))

(defun cam/insert-newline-below ()
  "Insert a newline below and move to it." ; OH THIS IS NICE
  (interactive)
  (end-of-line)
  (newline-and-indent))

(defmacro cam/funcall-for-key-binding (keys)
  "Call the fn bound to KEYS."
  `(funcall (key-binding ,(kbd keys))))

(defun cam/comment-current-line ()
  "Comment/uncomment the current line."
  (interactive)
  (save-excursion
    (end-of-line)
    (set-mark (point))
    (beginning-of-line)
    (cam/funcall-for-key-binding "M-;")))

(defun cam/projectile-recentf ()
  "Start projectile-mode if needed then call projectile-recentf."
  (interactive)
  (projectile-mode 1) ; this is not always on just for performance reasons
  (projectile-recentf))

(provide 'cam-functions)
;;; cam-functions.el ends here
