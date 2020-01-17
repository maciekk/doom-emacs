;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; refresh' after modifying this file!


;; These are used for a number of things, particularly for GPG configuration,
;; some email clients, file templates and snippets.
(setq user-full-name "Maciej Kalisiak"
      user-mail-address "maciej.kalisiak@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Input Mono" :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. These are the defaults.
(setq doom-theme 'doom-one)

;; If you intend to use org, it is recommended you change this!
;;(setq org-directory "~/org/")

(use-package! org
  :config
  (setq org-cycle-separator-lines 2
        org-startup-folded 'content)

  (setq org-directory "~/org/GTD/"  ; used for capture, agenda
        org-archive-location "archives/%s_archive::"
        org-default-notes-file (concat org-directory "inbox.org"))

  ;; Agenda
  (setq
        org-agenda-span 1
        org-agenda-start-day "."
        org-agenda-window-setup 'only-window
        org-agenda-tags-column 'auto
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
            (tags "REFILE"
                  ((org-agenda-overriding-header "Tasks to Refile")
                   (org-tags-match-list-sublevels 'indented)))))
          ))

  ;; Patterned on:
  ;;  http://doc.norang.ca/org-mode.html
  (setq org-todo-keywords
        (quote ((sequence
                 "NEXT(n)"
                 "TODO(t)"
                 "WAIT(w@/!)"
                 "|"
                 "DONE(d!/!)"
                 "DROP(c@/!)"))))
  ;; Do not use fast tag selection if want to default to helm for this.
  ;; See: https://github.com/emacs-helm/helm/issues/1890
  ;; (setq org-tag-alist
  ;;      '(("desk" . ?d)
  ;;        ("work" . ?w)
  ;;        ("garden" . ?g)
  ;;        ("errands" . ?e)
  ;;        ("basement" . ?b)
  ;;        ("kitchen" . ?k)
  ;;        ("Net" . ?n)
  ;;        ("leisure" . ?l)
  ;;        ))
  ;;(setq org-global-properties
  ;;'(("Effort_ALL" .
  ;;"0 0:15 0:30 1:00 2:00 3:00 4:00 5:00 6:00 8:00")))
  (setq org-capture-templates
        `(("t" "Todo" entry (file+headline ,(concat org-directory "inbox.org") "Tasks")
           "* TODO %?\n")
          ("T" "Todo w/context" entry (file+headline ,(concat org-directory "inbox.org") "Tasks")
           "* TODO %?\n  %a")
          ("j" "Journal" entry (file+datetree ,(concat org-directory "journal.org"))
           "* %?\n%c\nEntered on %U\n")))

  ;; Refiling
  ;;(setq org-refile-use-outline-path 'file)
  ;;(setq org-outline-path-complete-in-steps nil)
  ;;(setq org-completion-use-ido t)
  ;;(setq org-refile-targets
  ;;'((nil :maxlevel . 1)
  ;;  (org-agenda-files :maxlevel . 2)))

  ;; From https://zzamboni.org/post/beautifying-org-mode-in-emacs/
  ;; Specifically, use actual bullet chars in bullet lists.
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
  )

;; If you want to change the style of line numbers, change this to `relative' or
;; `nil' to disable it:
(setq display-line-numbers-type 'relative)


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
(after! org (setq
             org-id-track-globally nil
             org-id-locations-file nil
             org-id-locations-file-relative nil
             ))

;; Try NotGate's hack for now.
(defun create-todo (s)
  (interactive "sTODO ")
  ;; [#A] [#B] [#C]
  (append-to-file (format "** TODO %s\n" s) nil (concat org-directory "inbox.org")))
(map! (:leader :desc "Create a TODO" "T" #'create-todo))

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
