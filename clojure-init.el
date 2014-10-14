;; -*- comment-column: 60; -*-

(cam-setup-autoloads
  ("lisp-init" cam-define-lisp-keys))

(defun cam-clojure-mode-setup ()
  (require 'cider)
  (require 'company)
  (require 'clojure-mode-extra-font-locking)
  (cam-lisp-mode-setup)
  (cam-enable-minor-modes
    cider-mode
    subword-mode ; enable CamelCase support for editor movement
    company-mode)
  (pretty-fn)
  (cider-turn-on-eldoc-mode))

(add-hook 'nrepl-repl-mode-hook 'cam-clojure-mode-setup)
(add-hook 'clojure-mode-hook 'cam-clojure-mode-setup)
(add-hook 'cider-mode-hook 'cam-clojure-mode-setup)

;; custom keyboard shortcuts
(defun cam-define-clojure-keys (mode-map)
  (cam-define-lisp-keys mode-map)
  (define-keys mode-map
    '(("<f12> c" clojure-docs-search)
      ("<f12> i" instant-clojure-cheatsheet-search)
      ("<f12> j" javadocs-search)
      ("<f12> s" stackoverflow-search)
      ("<f12> <f12> p" paredit-cheatsheet)
      ("<f12> <f12> c" clojure-cheatsheet)
      ("C-c C-d" ac-nrepl-popup-doc)
      ("<C-M-return>" switch-to-nrepl-in-current-ns))))

(eval-after-load "clojure-mode"
  '(progn
     (cam-define-clojure-keys clojure-mode-map)
     (define-clojure-indent ; better indenting for compojure stuff
       (defroutes 'defun)
       (sqlfn 'defun)
       (k/sqlfn 'defun)
       (GET 2)
       (POST 2)
       (PUT 2)
       (DELETE 2)
       (HEAD 2)
       (ANY 2)
       (context 2))))

(eval-after-load "cider"
  '(progn
     (setq cider-repl-pop-to-buffer-on-connect t                    ; start NREPL in separate window
      cider-auto-select-error-buffer nil                       ; don't auto-switch to error buffer
      cider-show-error-buffer 'only-in-repl                    ; alternatively, set to nil or 'except-in-nrepl
      cider-stacktrace-default-filters '(java, clj, repl, tooling, dup)
      cider-repl-display-in-current-window nil                 ; C-c C-z switches to CIDER repl?? (cider-switch-to-repl)
      )))

(eval-after-load "nrepl"
  '(progn
     (require 'lisp-init)
     (cam-define-clojure-keys nrepl-interaction-mode-map)
     (setq nrepl-hide-special-buffers t                        ; hide the *nrepl-connection* and *nrepl-server* buffers
           nrepl-use-pretty-printing t
           nrepl-error-handler nil)))


(add-to-list 'auto-mode-alist '("\.cljs$" . clojure-mode)) ; ClojureScript Files should be edited in Clojure-mode

(defun nrepl-stacktrace ()
  "Helper method to jump over to the nrepl and call clojure.stacktrace/e, which will print the stacktrace
  For the last exception"
  (interactive)
  (end-of-buffer)
  (insert "clojure.stacktrace/e")
  (nrepl-return))

(defun pretty-fn ()
  "turns fn into a fancy f symbol. credit: emacs-starter-kit on github"
  (font-lock-add-keywords
   nil `(("(\\(\\<fn\\>\\)"
          (0 (progn (compose-region (match-beginning 1)
                                    (match-end 1)
                                    "\u0192"
                                    'decompose-region)))))))

(defun nice-ns (namespace)
  "Returns the path of the src file for the given test namespace."
  (interactive)
  (let* ((namespace (clojure-underscores-for-hyphens namespace)))
    (concat (car (last (split-string namespace "\\."))) ".clj")))

(defun strip-clj-cljs (namespace-str)
  (interactive)
  "Strips clj. or cljs. from the beginning on a namespace string generated by clojure-mode's clojure-expeceted-ns "
  "function (e.g. when separating Clojure and ClojureScript source in Leiningen)"
  (cond
   ((string= "clj." (substring namespace-str 0 4)) (substring namespace-str 4))
   ((string= "cljs." (substring namespace-str 0 5)) (substring namespace-str 5))
   (t namespace-str)))

;;; get the environment set up
(defun switch-to-nrepl-in-current-ns ()
  (interactive)
  (if (string= major-mode "nrepl-repl-mode")
      (nrepl-switch-to-last-clojure-buffer)
    (progn
      (let (nmspace (cider-get-current-ns))
        (cider-load-current-buffer)
        (cider-switch-to-relevant-repl-buffer)
        (nrepl-set-ns nmspace)))))

(defun paredit-cheatsheet ()
  (interactive)
  (browse-url "http://www.emacswiki.org/emacs/PareditCheatsheet"))

(defun clojure-cheatsheet ()
  (interactive)
  (browse-url "http://clojuredocs.org/quickref/Clojure%20Core"))

(defun clojure-docs-search ()
  "Searches clojuredocs.org for a query or selected region if any."
  (interactive)
  (browse-url
   (concat
    "http://clojuredocs.org/search?x=0&y=0&q="
    (active-region-or-prompt "Search clojuredocs.org for: "))))

(defun javadocs-search ()
  "Searches javadocs.org for a query or selected region if any."
  (interactive)
  (browse-url
   (concat
    "http://javadocs.org/"
    (active-region-or-prompt "Search javadocs.org for: "))))

(defun instant-clojure-cheatsheet-search ()
  "Searches Instant Clojure Cheatsheet query or selected region if any."
  (interactive)
  (browse-url
   (concat
    "http://cammsaul.github.io/instant-clojure-cheatsheet/?"
    (active-region-or-prompt "Search Instant Clojure Cheatsheet for: "))))

(provide 'clojure-init)
