(require 'highlight-parentheses)
(require 'auto-complete)
(require 'hl-sexp)

(defun cam-lisp-mode-setup ()
  (cam-enable-minor-modes
    (auto-complete-mode . nil)
    (highlight-parentheses-mode . nil)    ; highlight parentheses that surround the current sexpr
    hl-sexp-mode                        ; hl-sexp-mode highlights the current sexp
    (paredit-mode . " π")
    )
  (turn-on-eldoc-mode)
  (diminish 'eldoc-mode)
  (pretty-lambdas)
  (set-face-background 'hl-sexp-face "#DDFFDD"))

(defun backward-paredit-kill ()
  "calls paredit-kill with prefix arg 0 which effectively makes it kill backwards."
  (interactive)
  (paredit-kill 0))

(defun cam-define-lisp-keys (mode-map)
  (define-key mode-map (kbd "RET") 'reindent-then-newline-and-indent)
  (define-key mode-map (kbd "<f11>") 'paredit-mode)
  (define-key mode-map (kbd "C-S-k") 'backward-paredit-kill)
  (define-key mode-map (kbd "TAB") 'lisp-complete-symbol)) ; tab to complete symbol)

;; pretty-lambdas turns the word Lambda (lowercase) into a lambda. Credit: emacs-starter-kit on github
(defun pretty-lambdas ()
  (font-lock-add-keywords
   nil `(("(?\\(lambda\\>\\)"
          (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                    ,(make-char 'greek-iso8859-7 107))
                    nil))))))

(provide 'lisp-init)
