;; -*- comment-column: 50; -*-

(cam-setup-autoloads
  ("flycheck" flycheck-mode)
  ("lisp-init" cam-define-lisp-keys cam-lisp-mode-setup)
  ("lisp-mode" emacs-lisp-mode lisp-mode))

;;;; .EL FILES / GENERAL

(defun byte-recompile-this-file ()
  "Recompile the current Emacs Lisp file."
  (interactive)
  (byte-recompile-file (buffer-file-name)
                       t                          ; force recompile
                       0)                         ; 0 = compile even if .elc does not exist
  (eval-buffer))

(defun cam-elisp-mode-setup ()
  (cam-lisp-mode-setup)
  (cam-enable-minor-modes
    elisp-slime-nav-mode
    flycheck-mode)
  (add-hook 'before-save-hook 'untabify-current-buffer nil t)
  (add-hook 'after-save-hook 'byte-recompile-this-file nil t)

  ;; TODO - Extra font-lock keywords for elisp (e.g. cl- stuff)
  ;; (require 'morlock)
  ;; (turn-on-morlock-mode-if-desired)

  ;; use byte-compile-dynamic when compiling files in .emacs.d
  (when (string= default-directory                ; default-directory is buffer-local dir of the current buffer
           (expand-file-name "~/.emacs.d/"))
    (setq-local byte-compile-dynamic t)))

(add-hook 'emacs-lisp-mode-hook 'cam-elisp-mode-setup)
(add-hook 'ielm-mode-hook 'cam-elisp-mode-setup)

;;;; FUNCTIONS

(defun cam/wrapping-flycheck-next-error ()
  "Call flycheck-next-error, wrap around if we've reached end of buffer."
  (interactive)
  (condition-case nil
      (flycheck-next-error)
    (error (beginning-of-buffer))))


;;;; KEY MAPS

(defun cam-define-elisp-keys (mode-map)
  (cam-define-lisp-keys mode-map)
  (define-keys mode-map
    '(("<f5>" flycheck-display-errors)
      ("<f6>" cam/wrapping-flycheck-next-error)
      ("<f7>" flycheck-mode)
      ("C-x C-e" pp-eval-last-sexp)  ; pretty-print eval'd expressions
      ("<s-mouse-1>" elisp-slime-nav-find-elisp-thing-at-point))))

(add-hook 'emacs-lisp-mode-hook (lambda () (cam-define-elisp-keys emacs-lisp-mode-map)))


;;;; IELM SPECIFIC

(add-hook 'ielm-mode-hook
          (lambda ()
            (cam-define-elisp-keys ielm-map)
            (define-keys ielm-map
              '(("RET" ielm-return)))))

(provide 'elisp-init)
;;; elisp-init ends here
