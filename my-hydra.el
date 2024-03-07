;;; my-hydra.el --- Personal Emacs keybindings using Pretty Hydra  -*- lexical-binding: t; -*-

;; Author: Frederick Giasson <fred@fgiasson.com>
;; Version: 0.1.0
;; Package-Requires: ((major-mode-hydra) (hydra-posframe) (pretty-hydra))
;; Keywords: keybindings hydra pretty-hydra
;; URL: https://github.com/fgiasson/my-hydra

;; Require dependency packages
(require 'major-mode-hydra)
(require 'hydra-posframe)

;; Enable the posframe support for hydra
(hydra-posframe-mode)

;; Define useful utility functions to create icons for the hydra heads
;; Shamelessly copied from the work of mbuczko: https://gist.github.com/mbuczko/e15d61363d31cf78ff17427072e0c325
;;

(defun with-faicon (icon str &optional height v-adjust)
  (s-concat (all-the-icons-faicon icon :v-adjust (or v-adjust 0) :height (or height 1)) " " str))

(defun with-fileicon (icon str &optional height v-adjust)
  (s-concat (all-the-icons-fileicon icon :v-adjust (or v-adjust 0) :height (or height 1)) " " str))

(defun with-octicon (icon str &optional height v-adjust)
  (s-concat (all-the-icons-octicon icon :v-adjust (or v-adjust 0) :height (or height 1)) " " str))

(defun with-material (icon str &optional height v-adjust)
  (s-concat (all-the-icons-material icon :v-adjust (or v-adjust 0) :height (or height 1)) " " str))

(defun with-mode-icon (mode str &optional height nospace face)
  (let* ((v-adjust (if (eq major-mode 'emacs-lisp-mode) 0.0 0.05))
         (args     `(:height ,(or height 1) :v-adjust ,v-adjust))
         (_         (when face
                      (lax-plist-put args :face face)))
         (icon     (apply #'all-the-icons-icon-for-mode mode args))
         (icon     (if (symbolp icon)
                       (apply #'all-the-icons-octicon "file-text" args)
                     icon)))
    (s-concat icon (if nospace "" " ") str)))

;; Define the main hydra of hydras
(defvar hydra-of-hydras--title (with-faicon "sitemap" "Hydra of Hydras" 1 -0.05))
(pretty-hydra-define hydra-main
  (:color blue :quit-key ("q" "SPC") :title hydra-of-hydras--title)
  ("Misc"
   (("b" hydra-bookmarks/body "bookmarks")
    ("d" hydra-dogears/body "dogears")
    ("a" hydra-applications/body "applications")
    ("m" hydra-multicursor/body "multi-cursor")
    ("/" hydra-smartshift/body "smart shift")
    ("u" undo-tree-visualize "undo")
    ("j" consult-imenu "jump")
    ("." major-mode-hydra "major mode heads"))

   "Spaces"
   (("e" eyebrowse-switch-to-window-config "switch workspace")
    ("E" hydra-eyebrowse/body "eyebrowse")
    ("D" hydra-desktop/body "desktop")
    ("w" hydra-windows/body "windows"))

   "File"
   (("f" dired-jump "open directory")
    ("F" major-mode-hydras/dired-mode/body "dired")
    ("s" hydra-search/body "search"))

   "Development"
   (("c" hydra-docker/body "docker")
    ("l" hydra-lsp/body "lsp")
    ("L" hydra-linter/body "linter")
    ("g" hydra-magit/body "magit")
    ("p" hydra-project/body "project")
    ("t" org-babel-tangle-jump-to-org "jump to Org block"))

   "Emacs"
   (("h" hydra-help/body "help")
    ("M" hydra-modes/body "modes"))))

;; Enable the "." leader key for the main hydra in multiple different modes
;; We use "." to be aligne with Spacemacs's "," leader key
(evil-set-leader '(normal visual operator motion emacs) (kbd "."))
(define-key evil-normal-state-map (kbd ".") 'hydra-main/body)

;; we also define M-. that is used if "t" is used in the current major mode
(define-key evil-normal-state-map (kbd "M-.") 'hydra-main/body)

(defvar hydra-dogears--title (with-faicon "compass" "Dogears" 1 -0.05))
(pretty-hydra-define hydra-dogears
  (:color blue :quit-key ("q" "SPC") :title hydra-dogears--title)
  ("Actions"
   (("g" dogears-go "go")
    ("r" dogears-remember "remember")
    ("j" dogears-list "list")
    ("h" dogears-back "back")
    ("l" dogears-forward "forward")
    ("m" dogears-mode "mode" :toggle t)
    )))

(defvar hydra-org--title (with-mode-icon 'org-mode " Org" 1 -0.05))
(major-mode-hydra-define org-mode
  (:color blue :quit-key ("q" "SPC") :title hydra-org--title)
  ("Apps"
   (("r" hydra-org-roam/body "roam")
    ("R" hydra-org-remark/body "remark")
    ("c" hydra-org-citar/body "citar")
    ("e" hydra-org-pandoc/body "export"))
   "Edit"
   (("i" org-toggle-inline-images "toggle images")
    ("t" hydra-org-todo/body "todo")
    ("T" hydra-org-tags/body "tags")
    ("d" org-time-stamp "date/time")
    ("l" org-insert-link "link")
    ("a" org-archive-subtree "archive")
    ("I" org-inlinetask-insert-task "inline task")
    ("L" org-lint "lint")
    ("m" org-margin-mode "margin" :toggle t))
   "Development"
   (("b" hydra-org-babel/body "babel"))))

(defvar hydra-footnote--title (with-mode-icon 'org "Babel" 1 -0.05))
(pretty-hydra-define hydra-footnote
  (:color blue :quit-key ("q" "SPC") :title hydra-footnote--title)
  ("Edit"
   (("a" footnote-add-footnote "add")
    ("d" footnote-delete-footnote "delete"))
   "Motion"
   (("g" footnote-go-to-footnote "goto footnote")
    ("b" footnote-back-to-message "back to message"))
   "Mode"
   (("f" footnote-mode "mode")
    ("s" footnote-set-style "style"))))

(defvar hydra-org-babel--title (with-mode-icon 'org "Babel" 1 -0.05))
(pretty-hydra-define hydra-org-babel
  (:color blue :quit-key ("q" "SPC") :title hydra-org-babel--title)
  ("Tangle"
   (("t" org-babel-tangle "tangle")
    ("T" org-babel-tangle-block "tangle block")
    ("d" org-babel-detangle "detangle"))
   "Motion"
   (("n" org-babel-next-src-block "next")
    ("p" org-babel-previous-src-block "previous"))
   "Execute"
   (("b" org-babel-execute-buffer "buffer")
    ("B" org-babel-execute-src-block "block"))
   "Action"
   (("j" org-babel-tangle-jump "jump to tangled code")
    ("m" org-edit-special "edit in major mode"))))

(defvar hydra-org-tags--title (with-mode-icon 'org "Tags" 1 -0.05))
(pretty-hydra-define hydra-org-tags
  (:color blue :quit-key ("q" "SPC") :title hydra-org-tags--title)
  ("Actions"
   (("t" org-set-tags-command "add tag")
    ("v" org-tags-view "tags view")
    ("s" org-roam-search-tags "search roam nodes by tags"))))

(defvar hydra-org-remark--title (with-mode-icon 'org "Remark" 1 -0.05))
(pretty-hydra-define hydra-org-remark
  (:color blue :quit-key ("q" "SPC") :title hydra-org-remark--title)
  ("Actions"
   (("m" org-remark-mark "mark")
    ("y" org-remark-mark-yellow "mark yellow")
    ("r" org-remark-mark-red-line "mark red")
    ("o" org-remark-open "open")
    ("v" org-remark-view "view")
    ("d" org-remark-delete "delete")
    ("c" org-remark-change "change")
    ("s" org-remark-toggle "show/hide remarks"))
   "Mode"
   (("M" org-remark-mode "org remark mode" :toggle t)
    ("e" org-remark-eww-mode "eww mode" :toggle t)
    ("i" org-remark-icon-mode "icon mode" :toggle t)
    ("I" org-remark-info-mode "info mode" :toggle t))))

(defvar hydra-org-todo--title (with-mode-icon 'org "Todo" 1 -0.05))
(pretty-hydra-define hydra-org-todo
  (:color blue :quit-key ("q" "SPC") :title hydra-org-todo--title)
  ("Actions"
   (("t" org-todo "add todo")
    ("p" org-priority "add priority")
    ("l" org-todo-list "list todos"))))

(defvar hydra-org-citar--title (with-mode-icon 'org "Citar" 1 -0.05))
(pretty-hydra-define hydra-org-citar
  (:color blue :quit-key ("q" "SPC") :title hydra-org-citar--title)
  ("Insert"
   (("c" citar-insert-citation "citation")
    ("f" citar-insert-reference "reference")
    ("b" citar-insert-bibtex "bibtex")
    )
   "Open"
   (("e" citar-open-entry "bibtex entry")
    ("o" citar-open "open anything available")
    ("l" citar-open-links "links")
    ("f" citar-open-files "files")
    ("n" citar-open-note "note")
    ("N" citar-open-notes "notes"))
   "Create"
   (("+" citar-create-note "note"))
   "Mode"
   (("m" citar-org-roam-mode "citar org roam" :toggle t)
    ("E" citar-embark-mode "citar embark mode" :toggle t))))

(defvar hydra-org-roam--title (with-mode-icon 'org-mode "Roam" 1 -0.05))
(pretty-hydra-define hydra-org-roam
  (:color blue :quit-key ("q" "SPC") :title hydra-org-roam--title)
  ("Edit"
   (("c" org-roam-capture "capture new note")
    ("f" org-roam-node-find "find")
    ("i" org-roam-node-insert "insert" )
    ("a" org-roam-alias-add "alias")
    )
   "Tools"
   (("b" org-roam-buffer-toggle "roam buffer")
    ("d" org-roam-links-depth "links depth"))
   "Operations"
   (("s" org-roam-db-sync "sync")
    ("x" org-roam-db-clear-all "clear db"))))

(defvar hydra-org--title (with-mode-icon 'org-mode " Org" 1 -0.05))
(major-mode-hydra-define org-agenda-mode
  (:color blue :quit-key ("q" "SPC") :title hydra-org-agenda--title)
  ("Options"
   (("n" org-agenda-add-note "note")
    ("r" org-agenda-refile "refile")
    ("x" org-agenda-archive "archive"))))

(defvar hydra-org-pandoc--title (with-octicon "circuit-board" "Pandoc" 1 -0.05))
(pretty-hydra-define hydra-org-pandoc
  (:color blue :quit-key ("q" "SPC") :title hydra-org-pandoc--title)
  ("Export"
   (("d" org-pandoc-export-to-docx "docx")
    ("h" org-html-export-to-html "html")
    ("o" org-odt-export-to-odt "odt")
    ("m" org-pandoc-export-to-markdown "markdown")
    )))

(defvar hydra-dired--title (with-faicon "folder" "Dired" 1 -0.05))
(major-mode-hydra-define dired-mode
  (:color blue :quit-key ("q" "SPC") :title hydra-dired--title)
  ("Open in"
   (("." dired-jump "current directory")
    ("~" (lambda () (interactive) (dired "~/")) "home directory")
    ("/" (lambda () (interactive) (dired "/")) "root directory")
    ("p" (lambda () (interactive) (dired (projectile-project-root))))
    ("e" open-in-system-explorer "system explorer"))))

(defvar hydra-smartshift--title (with-faicon "arrow-circle-up" "Smart Shift" 1 -0.05))
(pretty-hydra-define hydra-smartshift
  (:color blue :quit-key ("q" "SPC") :title hydra-smartshift--title)
  ("←"
   (("h" smart-shift-left "←"))
   "↓"
   (("j" smart-shift-down "↓"))
   "→"
   (("l" smart-shift-left "→"))
   "↑"
   (("k" smart-shift-up "↑"))))

(defvar hydra-applications--title (with-octicon "circuit-board" "Applications" 1 -0.05))
(pretty-hydra-define hydra-applications
  (:color blue :quit-key ("q" "SPC") :title hydra-applications--title)
  ("Tools"
   (("v" vterm "vterm")
    ("a" org-agenda "agenda")
    ("r" hydra-org-roam/body "roam")
    ("f" hydra-footnote/body "footnote"))))

(defvar hydra-modes--title (with-material "check" "Modes" 1 -0.05))
(pretty-hydra-define hydra-modes
  (:color blue :quit-key ("q" "SPC") :title hydra-modes--title)
  ("Buffers"
   (("l" global-display-line-numbers-mode "show line numbers" :toggle t)
    ("i" spacemacs/toggle-fill-column-indicator "column indicator" :toggle t))
   "Tools"
   (("c" copilot-mode "copilot" :toggle t)
    ("t" flycheck-mode "flycheck" :toggle t))))

(defvar hydra-python--title (with-mode-icon 'python-mode "Python" 1 -0.05))
(major-mode-hydra-define python-mode
  (:color blue :quit-key ("q" "SPC") :title hydra-python--title)
  ("Tests"
   (("t" spacemacs/python-test-all "run all tests")
    ("m" spacemacs/python-test-module "run module tests"))
   "Actions"
   (("l" hydra-linter/body "Linter")
    ("s" python-sort-imports "sort imports"))))

(defvar hydra-flycheck--title (with-material "check" "Linter" 1 -0.05))
(pretty-hydra-define hydra-linter
  (:color blue :quit-key ("q" "SPC") :title hydra-flycheck--title)
  ("Flycheck"
   (("v" flycheck-verify-setup "verify setup")
    ("c" flycheck-describe-checker "describe checker")
    ("s" flycheck-select-checker "select checker")
    ("t" flycheck-mode "toggle" :toggle t))

   "Error"
   (("<" flycheck-previous-error "previous")
    (">" flycheck-next-error "next")
    ("l" flycheck-list-errors "list")
    ("o" nil "open in browser")
    ("i" pylint-disable-current-warning "ignore"))))

(defvar hydra-lsp--title (with-material "developer_board" "LSP" 1 -0.05))
(pretty-hydra-define hydra-lsp
  (:color blue :quit-key ("q" "SPC") :title hydra-lsp--title)
  ("Server"
   (("w" lsp-describe-session "Describe session"))

   "Navigation"
   (("d" lsp-find-definition "Jump to definition")
    ("r" lsp-find-references "Find references")
    ("i" lsp-ui-imenu "Menu")
    ("s" consult-lsp-file-symbols "File symbols")
    ("S" consult-lsp-symbols "Workspace symbols"))

   "Documentation"
   (("D" lsp-describe-thing-at-point "Show documentation"))

   "Refactoring"
   (("R" lsp-rename "Rename this thing"))))

(defvar hydra-magit--title (with-faicon "git" "Magit" 1 -0.05))
(pretty-hydra-define hydra-magit
  (:color blue :quit-key ("q" "SPC") :title hydra-magit--title)
  ("Open in"
   (("g" magit-status "magit")
    ("b" magit-branch-checkout "branch checkout")
    ("d" magit-diff "diff")
    ("l" magit-log-buffer-file "log")
    )
   "Blame"
   (("b" magit-blame "blame")
    ("q" magit-blame-quit "quit"))
   "Help"
   (("m" (execute-kbd-macro (kbd "SPC h j magit")) "manual"))))

(defvar hydra-docker--title (with-fileicon "dockerfile" "Docker" 1 -0.05))
(pretty-hydra-define hydra-docker
  (:color blue :quit-key ("q" "SPC") :title hydra-docker--title)
  ("Docker"
   (("d" docker "docker")
    ("c" (execute-kbd-macro (kbd "SPC a t d c")) "containers")
    ("i" (execute-kbd-macro (kbd "SPC a t d i")) "images")
    ("n" (execute-kbd-macro (kbd "SPC a t d n")) "networks")
    ("v" (execute-kbd-macro (kbd "SPC a t d v")) "volumes")
    ("x" (execute-kbd-macro (kbd "SPC a t d x")) "contexts"))
   "Build"
   (("b" dockerfile-build-buffer "build")
    ("B" dockerfile-build-no-cache-buffer "build (no cache)"))))

(defvar hydra-multicursor--title (with-faicon "i-cursor" "Multi-cursor" 1 -0.05))
(pretty-hydra-define hydra-multicursor
  (:color blue :quit-key ("q" "SPC") :title hydra-multicursor--title)
  ("Set"
   (("c" #'evil-mc-make-all-cursors "Make cursor of selection")
    ("q" #'evil-mc-undo-all-cursors "Remove all cursors"))))

(defvar hydra-search--title (with-faicon "search" "Search" 1 -0.05))
(pretty-hydra-define hydra-search
  (:color blue :quit-key ("q" "SPC") :title hydra-search--title)
  ("In File"
   (("j" #'consult-imenu "jump")
    ("w" #'spacemacs/symbol-overlay "word under cursor"))

   "In Folder"
   (("p" #'spacemacs/compleseus-search-projectile "project")
    ("o" #'spacemacs/compleseus-search-auto "folder")
    ("l" #'org-ql-open-link-in-org-directory "org links"))
   "In Buffers"
   (("b" #'consult-line-multi "buffer"))))

(defvar hydra-windows--title (with-faicon "windows" "Help" 1 -0.05))
(pretty-hydra-define hydra-windows
  (:color blue :quit-key ("q" "SPC") :title hydra-windows--title)
  ("Split"
   (("v" #'split-window-vertically "vertical")
    ("h" #'split-window-horizontally "horizontal"))

   "Misc"
   (("d" #'delete-window "delete")
    ("o" #'delete-other-windows "delete others")
    ("s" #'window-swap-states "swap"))))

(defvar hydra-help--title (with-faicon "wrench" "Help" 1 -0.05))
(pretty-hydra-define hydra-help
  (:color blue :quit-key ("q" "SPC") :title hydra-help--title)
  ("Help"
   (("h" #'help "help"))

   "Describe"
   (("m" #'describe-mode "mode")
    ("F" #'describe-face "face")
    ("k" #'describe-key "key")
    ("v" #'describe-variable "variable")
    ("f" #'describe-function "function")
    ("c" #'describe-command "command"))))

(defvar hydra-project--title (with-faicon "balance-scale" "Project" 1 -0.05))
(pretty-hydra-define hydra-project
  (:color blue :quit-key ("q" "SPC") :title hydra-project--title)
  ("Actions"
   (("s" projectile-switch-open-project "switch open project")
    ("S" projectile-switch-project "switch project")
    ("i" projectile-project-info "info")
    ("a" projectile-add-known-project "add")
    ("r" projectile-find-references "find references")
    ("f" projectile-find-file "find file")
    ("v" projectile-shell "vterm")
    ("d" projectile-discover-projects-in-directory "discover new projects")
    ("c" projectile-comander "help (commander)"))))

(defvar hydra-bookmark--title (with-faicon "bookmark" "Bookmark" 1 -0.05))
(pretty-hydra-define hydra-bookmarks
  (:color blue :quit-key ("q" "SPC") :title "Bookmarks")
  ("Manage"
   (("c" bookmark-set "Create a bookmark")
    ("u" bmkp-url-target-set "Create a URL bookmark")
    ("s" bmkp-set-snippet-bookmark "Create a snippet bookmark")
    ("j" bookmark-jump "Jump to bookmark")
    ("e" edit-bookmarks "Edit bookmarks")
    ("l" consult-bookmark "List and jump bookmarks")
    ("S" bookmark-save "Save bookmarks to disk")
    ("r" bookmark-rename "Rename a bookmark")
    ("d" bookmark-delete "Delete a bookmark"))))

(defvar hydra-eyebrowse--title (with-faicon "eye" "Eyebrowse" 1 -0.05))
(pretty-hydra-define hydra-eyebrowse
  (:color blue :quit-key ("q" "SPC") :title hydra-eyebrowse--title)
  ("Eyebrowse"
   (("e" eyebrowse-switch-to-window-config "Switch to config")
    ("l" eyebrowse-last-window-config "Switch to the latest window config")
    ("c" eyebrowse-create-named-window-config "Create a new config")
    ("r" eyebrowse-rename-window-config "Rename a new config")
    ("d" eyebrowse-close-window-config "Destroy a window config"))))

(defvar hydra-desktop--title (with-faicon "desktop" "Desktop" 1 -0.05))
(pretty-hydra-define hydra-desktop
  (:color blue :quit-key ("q" "SPC") :title hydra-desktop--title)
  ("Desktop"
   (("s" desktop-save "Save desktop")
    ("r" desktop-read "Read desktop")
    ("c" desktop-clear "Clear desktop")
    ("k" desktop-remove "Remove desktop"))))

(provide 'my-hydra)
