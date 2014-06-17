(require 'auto-complete)

(defun cam-ruby-mode-setup ()
  (require 'rspec-mode)
  (require 'ruby-electric)
  (require 'ruby-block)
  (global-mode-setup)
  (ruby-electric-mode t)
  (ruby-block-mode t) ; highlight corresponding openings when cursor is on a closing block statement
  (auto-complete-mode t)
  (paredit-mode t))
(add-hook 'ruby-mode-hook 'cam-ruby-mode-setup)

(mapc (lambda (str)
        (add-to-list 'auto-mode-alist (cons str 'ruby-mode)))
      '("\.podspec$"
        "\.Gemfile$"
        "\.Rakefile$"
        "\.Podfile$"))

(setq ruby-block-highlight-toggle 'overlay) ; highlight ruby block on screen instead of minibuffer
(setq ruby-block-delay 0.01) ; delay before showing matching block; default is 0.5

;; Apparently this function is missing from the version of ruby-electric on MELPA, although it attemps to call it;
;; work around http://stackoverflow.com/questions/10326255/emacs-ruby-electric-does-not-insert-end
(defun ruby-insert-end ()
  "Insert \"end\" at point and reindent current line."
  (interactive)
  (insert "end")
  (ruby-indent-line t)
  (end-of-line))

(provide 'ruby-init)
