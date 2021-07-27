;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; refresh' after modifying this file!

;; These are used for a number of things, particularly for GPG configuration,
;; some email clients, file templates and snippets.
(setq user-full-name "Maciej Kalisiak"
      user-mail-address "maciej.kalisiak@gmail.com")

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. These are the defaults.
;(setq doom-theme 'doom-spacegrey)
(setq doom-theme 'doom-solarized-light)

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;;(setq mk/font "Fira Code")
;;(setq mk/font "Input Mono")
(setq mk/font "Fantasque Sans Mono")
(setq doom-font (font-spec :family mk/font :size 16))
(setq doom-big-font (font-spec :family mk/font :size 24))
;;(setq doom-variable-pitch-font (font-spec :family "ETBembo" :size 18))
(setq doom-variable-pitch-font (font-spec :family "Alegreya" :size 16))

(add-hook! 'org-mode-hook #'mixed-pitch-mode)
(setq mixed-pitch-variable-pitch-cursor nil)

;; variable pitch causes autocomplete popup to render wrong, and is just
;; annoying in Org (does dict matching), so just turn it off.
(setq company-global-modes '(not org-mode org-journal-mode))

(setq display-line-numbers-type 'nil)
(setq-default left-margin-width 1)

(setq calendar-week-start-day 1)
(setq display-time-default-load-average nil)
(display-time-mode)

;;; Helper functions
(defun mk/org-next-open-task ()
  "Advance point to next taks that is 'not done'."
  (interactive)
  (while (not (looking-at org-not-done-heading-regexp))
    (org-next-visible-heading 1)))

(defun mk/org-resort-todos ()
  "Sort the tasks in subtree under point; order:
  - first, by TODO keyword (e.g., DONE > STARTED > NEXT > TODO)
  - second, by PRIORITY"
  (interactive)
  (outline-up-heading 10)
  (org-sort-entries t ?p)
  (org-sort-entries t ?o)
  (org-overview)
  (org-cycle)
  (mk/org-next-open-task))

(defun mk/jump-to-end-of-journal ()
  "Jumps to end of my journal file (thus presumably to latest entry)."
  (interactive)
  (find-file "~/org/GTD/journal.org")
  )

(defun mk/org-narrow-to-subtree ()
  "Narrows buffer to the current subtree I am within.
   Non-nil prefix widens buffer."
  (interactive)
  (if (equal current-prefix-arg nil)
      (progn
        (outline-up-heading 1)
        (org-narrow-to-subtree))
      (widen)))

(use-package! org
  :config
  (setq org-directory "~/org/GTD/"  ; used for capture, agenda
        org-archive-location "archives/%s_archive::"
        org-default-notes-file (concat org-directory "inbox.org")
        org-reverse-note-order t)

  ;; simple, general settings
  (setq org-cycle-separator-lines 0
        org-startup-folded 'content
        org-pretty-entities t
        org-hidden-keywords '(title)
        org-catch-invisible-edits 'show-and-error
        )

  ;; Agenda
  (setq
        org-agenda-span 3
        org-agenda-start-day "."
        org-agenda-window-setup 'only-window
        org-agenda-tags-column 'auto
        org-priority-start-cycle-with-default nil
        ;org-use-speed-commands t
        ;; Not sure why need to use todo-state-up when want to use the TODO
        ;; keyword sort order; thought org-todo-keywords would be interpreted in
        ;; prio descending order.
        org-agenda-sorting-strategy '(
                                      (agenda habit-down time-up todo-state-up priority-down category-keep)
                                      (todo priority-down category-keep)
                                      (tags priority-down category-keep)
                                      (search category-keep))
        ;; other options: ➥ ▼ → ▾
        org-ellipsis "▼"
        org-hide-emphasis-markers t)

  (setq org-agenda-files (list org-directory
                               (concat org-directory "projects")))
  (setq org-agenda-custom-commands
        '(
          ;; ("n" "NOW view"
          ;; ((tags "now/!-DONE-WAIT"
          ;; ((org-agenda-overriding-header "  --== NOW! ==--")))
          ;; (agenda "" ((org-agenda-span 7)
          ;; (org-agenda-start-on-weekday nil)))))
          ;; ("h" "Hotlist" tags "hot"
          ;; ((org-agenda-overriding-header "  === HOTLIST ===")))
          ("z" "Agenda"
           ((agenda "" nil)
            (tags-todo "REFILE"
                  ((org-agenda-overriding-header "Tasks to Refile")
                   (org-tags-match-list-sublevels 'indented)))))
          ("N" "-= NOW =-"
           ((todo "NEXT"
                  ((org-agenda-skip-function '(org-agenda-skip-entry-if 'notscheduled))))))
          ))

  ;; (setq org-super-agenda-groups
  ;;      '(;; Each group has an implicit boolean OR operator between its selectors.
  ;;        (:name "Today"  ; Optionally specify section name
  ;;               :time-grid t  ; Items that appear on the time grid
  ;;               :todo "NEXT")  ; Items that have this TODO keyword
  ;;        (:name "Important"
  ;;               ;; Single arguments given alone
  ;;               :tag "bills"
  ;;               :priority "A")
  ;;        ;; Groups supply their own section names when none are given
  ;;        (:todo "WAIT" :order 8)  ; Set order of this section
  ;;        (:priority<= "B"
  ;;                     ;; Show this section after "Today" and "Important", because
  ;;                     ;; their order is unspecified, defaulting to 0. Sections
  ;;                     ;; are displayed lowest-number-first.
  ;;                     :order 1)
  ;;        ;; After the last group, the agenda will display items that didn't
  ;;        ;; match any of these groups, with the default order position of 99
  ;;        ))

  ;; Patterned on:
  ;;  http://doc.norang.ca/org-mode.html
  (setq org-todo-keywords
        (quote ((sequence
                 "WAIT(w@)"
                 "WIP(s)"
                 "NEXT(n)"
                 "TODO(t)"
                 "|"
                 "DONE(d)"
                 "DROP(c@)"))))
  ;;(setq org-global-properties
  ;;'(("Effort_ALL" .
  ;;"0 0:15 0:30 1:00 2:00 3:00 4:00 5:00 6:00 8:00")))
  (setq org-capture-templates
        `(("t" "Todo" entry (file+headline ,(concat org-directory "inbox.org") "Tasks")
           "* TODO %?\n")
          ("T" "Todo w/context" entry (file+headline ,(concat org-directory "inbox.org") "Tasks")
           "* TODO %?\n  %a")
          ("j" "Journal" entry (file+datetree ,(concat org-directory "journal.org"))
           "* %?\n")))

  ;; Switch to Insert mode whenever entering context note (e.g., TODO -> WAIT transition)
  ;; Source: https://emacs.stackexchange.com/questions/41265/how-do-i-automatically-enter-evil-insert-state-after-running-the-org-add-note-co
  (add-hook 'org-log-buffer-setup-hook 'evil-insert-state)

  ;; Refiling
  ;;(setq org-refile-use-outline-path 'file)
  ;;(setq org-outline-path-complete-in-steps nil)
  ;;(setq org-completion-use-ido t)
  ;;(setq org-refile-targets
  ;;'((nil :maxlevel . 1)
  ;;  (org-agenda-files :maxlevel . 2)))

  ;; TODO: should this be outside the use-package?
  (require 'org-superstar)
  (add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))
  (setq org-superstar-item-bullet-alist
        '((?* . ?•)
          (?+ . ?-)
          (?- . ?∙)))

  ;; From https://zzamboni.org/post/beautifying-org-mode-in-emacs/
  ;; Specifically, use actual bullet chars in bullet lists.
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
  :bind (
   ;; global map mappings
   ("C-c s" . mk/org-resort-todos)
   ("C-c j" . mk/jump-to-end-of-journal)
   :map org-mode-map
   ;; org-mode map mappings (useful for overrides)
   ("C-c n" . mk/org-narrow-to-subtree)
   )
  )  ;; end of "use-package! org"

;; Disabled for now because breaks navigation in org-roam.
;; (use-package! evil-org
;;   :config
;;   (map! :map evil-org-mode-map
;;         ;; revent RET binding in normal mode to just RET (was +org/dwim-at-point)
;;         :n [return] #'evil-ret
;;         :n "RET"    #'evil-ret))

(use-package! org-fancy-priorities ; priority icons
  :hook (org-mode . org-fancy-priorities-mode)
  :config (setq org-fancy-priorities-list '("■" "■" "■")))

;; Problematic symbols (chars too tall, resulting in inconsistent line spacing)
;;   ⊡⊠⚫⧗⧖
;; Safe symbols:
;;   ■□◷⌛⌚
(define-abbrev-table 'global-abbrev-table '(
    ("xpomo" "◷")  ;; used to represent 1 pomodoro in TODOs
    ))
(advice-add 'org-mode :after #'abbrev-mode)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', where Emacs
;;   looks when you load packages with `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

;; Set default window size at startup.
(add-to-list 'default-frame-alist '(height . 45))
(add-to-list 'default-frame-alist '(width . 120))

(setq mac-option-key-is-meta nil
      mac-command-key-is-meta t
      mac-command-modifier 'meta
      mac-option-modifier 'none)

;; Fixes

;; Work-around suggested for https://github.com/hlissner/doom-emacs/issues/2039
(setq-hook! 'eshell-mode-hook company-idle-delay nil)

;; Amend various jump shortcut target keys to be Dvorak-friendly.
(after! avy
  (setq avy-keys '(?a ?e ?o ?u ?i ?d ?h ?t ?n)))
(after! ace-window
  (setq aw-keys '(?a ?e ?o ?u ?i ?d ?h ?t ?n)))

;; Disable addition of :ID:s to captured TODO items.
;; Alas, doesn't fix things.
;(after! org (setq
;             org-id-track-globally nil
;             org-id-locations-file nil
;             org-id-locations-file-relative nil
;             ))

;; Put back C-d and C-u bindings to scroll Ivy minibuffer.
;; But don't be too shy to try out more advanced options using M-o.
(after! ivy
  (define-key ivy-minibuffer-map (kbd "C-u") 'ivy-scroll-down-command)
  (define-key ivy-minibuffer-map (kbd "C-d") 'ivy-scroll-up-command)
  (define-key ivy-minibuffer-map (kbd "S-<return>") 'ivy-alt-done)
  )

(setq deft-extensions '("org"))
(setq deft-directory "~/org")
(setq deft-recursive t)
(setq deft-use-filename-as-title t)
(setq deft-use-filter-string-for-filename t)

;; `smartparens' config
;; Turning off, it's more trouble then its worth.
;; (As suggested on https://github.com/hlissner/doom-emacs/issues/1094)
(after! smartparens
  (smartparens-global-mode -1))

;; (bind-keys
;;  :map smartparens-mode-map
;;  ("C-M-a" . sp-beginning-of-sexp)
;;  ("C-M-e" . sp-end-of-sexp)
;;
;;  ("C-M-d" . sp-down-sexp)
;;  ("C-M-u" . sp-up-sexp)
;;  ("C-M-S-d" . sp-backward-down-sexp)
;;  ("C-M-S-u" . sp-backward-up-sexp)
;;
;;  ("C-M-f" . sp-forward-sexp)
;;  ("C-M-b" . sp-backward-sexp)
;;
;;  ("C-M-n" . sp-next-sexp)
;;  ("C-M-p" . sp-previous-sexp)
;;
;;  ("C-S-f" . sp-forward-symbol)
;;  ("C-S-b" . sp-backward-symbol))

;; Might help with some issues w/blocked rendering, unresponsiveness.
;; See: https://github.com/hlissner/doom-emacs/issues/216
(add-to-list 'default-frame-alist '(inhibit-double-buffering . t))

(use-package org-roam
      :after org
      ;:hook
      ;((org-mode . org-roam-mode)
      ; (after-init . org-roam--build-cache-async) ;; optional!
      ; )
      ;;:straight (:host github :repo "jethrokuan/org-roam" :branch "develop")
      :custom
      (org-roam-directory "~/org/zettels")
      (org-roam-link-title-format "R:%s")
      :bind
      ("C-c z l" . org-roam)
      ("C-c z t" . org-roam-today)
      ("C-c z f" . org-roam-find-file)
      ("C-c z i" . org-roam-insert)
      ("C-c z g" . org-roam-show-graph)
      ("C-c (" . org-mark-ring-goto))

;; The following are based org-roam "ecosystem" suggestions.
;; See: https://org-roam.readthedocs.io/en/latest/ecosystem/

;; Also, read: https://blog.jethro.dev/posts/how_to_take_smart_notes_org/

;; Use 'deft' in conjunction with 'org-roam'.
(use-package deft
  :after org
  :bind
  ("C-c z d" . deft)
  :custom
  (deft-recursive t)
  (deft-use-filter-string-for-filename t)
  (deft-default-extension "org")
  (deft-directory "~/org/zettels"))

;; Use 'org-journal' in conjunction with 'org-roam'.
;; TODO: actually try this out. May involve installing 'org-journal'.
;; Link for latter: https://github.com/bastibe/org-journal
(use-package org-journal
  :bind
  ("C-c J" . org-journal-new-entry)
  :custom
  (org-journal-date-prefix "#+TITLE: ")
  (org-journal-file-format "%Y-%m-%d.org")
  (org-journal-dir "~/org/journal")
  (org-journal-date-format "%A, %d %B %Y"))

;; Turn on auto-fill-mode for key major modes.
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'org-mode-hook 'turn-on-auto-fill)

;; Stop the warnings about depending on 'cl'. (does this actually work?)
;; More info: https://github.com/hlissner/doom-emacs/issues/3372
(setq byte-complile-warnings '(not cl-functions))

;; Set this so redo (C-r) works.
;(set-evil-undo-system 'undo-fu)         ; alternative: 'undo-tree

(add-hook 'org-mode-hook 'org-appear-mode)
(setq org-appear-autolinks t
      org-appear-autoentities t
      org-appear-autokeywords t
      org-appear-delay 0.5)

;; focus-mode setup
;; Based on: https://orgmode.org/list/87r1wd32kg.fsf@gmail.com/T/
(defun forward-subtree (&optional N)
   "Forward one orgmode-heading for thing-at-point"
   (interactive "p")
   (if (= N -1)
       (org-backward-heading-same-level 1)
     (org-forward-heading-same-level 1)))

(setq focus-mode-to-thing '((org-mode . subtree)))
;; now just run focus-mode
