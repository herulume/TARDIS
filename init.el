;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; NOTE: init.el is now generated from Emacs.org.  Please edit that file
;;       in Emacs and init.el will be generated automatically!

(defvar herulume/default-font-size 130)
(defvar herulume/default-variable-font-size 130)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Change the user-emacs-directory to keep unwanted things out of ~/.emacs.d
(setq user-emacs-directory (expand-file-name "~/.cache/emacs/")
      url-history-file (expand-file-name "url/history" user-emacs-directory))

;; Use no-littering to automatically set common paths to the new user-emacs-directory
(use-package no-littering)
(require 'no-littering)

;; Keep customization settings in a temporary file (thanks Ambrevar!)
(setq custom-file
      (if (boundp 'server-socket-dir)
	  (expand-file-name "custom.el" server-socket-dir)
	(expand-file-name (format "emacs-custom-%s.el" (user-uid)) temporary-file-directory)))
(load custom-file t)

(global-auto-revert-mode t)

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

;; Column and line numbers
(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
		 org-agenda-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                dired-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(global-set-key (kbd "<C-down>") 'shrink-window)
(global-set-key (kbd "<C-up>") 'enlarge-window) 
(global-set-key (kbd "<C-right>") 'shrink-window-horizontally)
(global-set-key (kbd "<C-left>") 'enlarge-window-horizontally)

(set-face-attribute 'default nil :font "Fira Code" :height herulume/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "Fira Code" :height herulume/default-font-size)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "Cantarell" :height herulume/default-font-size :weight 'regular)

(use-package doom-themes
  :init (load-theme 'doom-tomorrow-night t))

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-initial-inputs-alist nil) ;; Don't start searches with ^
  (counsel-mode 1))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(defun herulume/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(defvar +org-habit-graph-padding 2
  "The padding added to the end of the consistency graph")

(defvar +org-habit-min-width 30
  "Hides the consistency graph if the `org-habit-graph-column' is less than this value")

(defvar +org-habit-graph-window-ratio 0.3
  "The ratio of the consistency graphs relative to the window width")

(defun +org-habit-resize-graph-h ()
  "Right align and resize the consistency graphs based on `+org-habit-graph-window-ratio'"
  (when (featurep 'org-habit)
    (let* ((total-days (float (+ org-habit-preceding-days org-habit-following-days)))
           (preceding-days-ratio (/ org-habit-preceding-days total-days))
           (graph-width (floor (* (window-width) +org-habit-graph-window-ratio)))
           (preceding-days (floor (* graph-width preceding-days-ratio)))
           (following-days (- graph-width preceding-days))
           (graph-column (- (window-width) (+ preceding-days following-days)))
           (graph-column-adjusted (if (> graph-column +org-habit-min-width)
                                      (- graph-column +org-habit-graph-padding)
                                    nil)))
          (setq-local org-habit-preceding-days preceding-days)
          (setq-local org-habit-following-days following-days)
          (setq-local org-habit-graph-column graph-column-adjusted))))

(defun herulume/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :hook ((org-mode . herulume/org-mode-setup)
         (org-agenda-mode . +org-habit-resize-graph-h))
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture))
  :config
  (require 'org-habit)
  (require 'org-timer)
  (add-to-list 'org-modules 'org-habit)

  (setq org-clock-sound "~/dev/TARDIS/bell.wav")

  (setq org-ellipsis " ▾")
  (herulume/org-font-setup)

  (setq org-directory "~/dev/Personal/org/")
  (setq org-agenda-files (directory-files-recursively "~/dev/Personal/org/" "\\.org$"))
  (setq org-agenda-window-setup 'current-window)

  (setq org-todo-keywords '((sequence "TODO(t)" "IN-PROGRESS(i)" "NEXT(n)" "WAITING(w@/!)" "|" "DONE(d!)" "SKIP(@)" "CANCELED(c@)")))

  (setq org-agenda-custom-commands
        '(("d" "Today's Tasks"
           ((tags-todo
             "GHD+ACTIVE+PRIORITY=\"A\""
             ((org-agenda-files '("~/dev/Personal/org/goals.org"))
              (org-agenda-overriding-header "Primary goals for this month")))
            (tags-todo
             "GHD+ACTIVE+PRIORITY=\"C\""
             ((org-agenda-files '("~/dev/Personal/org/goals.org"))
              (org-agenda-overriding-header "Secondary goals for this month")))
            (agenda "" ((org-agenda-start-day ".")
                        (org-agenda-span 1)
                        (org-agenda-overriding-header "Today")))
            (tags "remember"))) 

          ("w" "This Week's Tasks"
           ((tags-todo
             "GHD+ACTIVE+PRIORITY=\"A\""
             ((org-agenda-files '("~/dev/Personal/org/goals.org"))
              (org-agenda-overriding-header "Primary goals for this month")))
            (tags-todo
             "GHD+ACTIVE+PRIORITY=\"C\""
             ((org-agenda-files '("~/dev/Personal/org/goals.org"))
              (org-agenda-overriding-header "Secondary goals for this month")))
            (agenda)))))

  (setq org-agenda-prefix-format '((agenda . " %i %-20:c%?-12t%-6e% s")
                                   (todo   . " %i %-20:c %-6e")
                                   (tags   . " %i %-20:c")
                                   (search . " %i %-20:c")))


  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-tag-alist
        '((:startgroup)
           ; Put mutually exclusive tags here
          (:endgroup)
          ("errand" . ?E)
          ("home" . ?H)
              ("health" . ?h)
          ("work" . ?W)
          ("university" . ?U)
          ("pleasure" . ?P)))

  (setq org-capture-templates
        '(
          ;; Bujo workflow
          ("d" "Dailies Workflow")
          ("dj" "Daily TODOS" entry
           (file+olp+datetree "~/dev/Personal/org/journal.org")
           "** Summary \n#+BEGIN: clocktable :scope tree4 :maxlevel 5 :block untilnow \n#+END: \n** Daily TODOS [\%] \n" :tree-type day)
          ("dt" "Daily TODO" plain
           (file "~/dev/Personal/org/journal.org")
           "***** TODO %? \nSCHEDULED: %^t \n:PROPERTIES:\n:Category: Daily\n:Effort:   %^{Effort} \n:END: \n")
          ;; Remeinder workflow
          ("r" "Remember Workflow")
          ("rt" "TODO" entry (file+headline "~/dev/Personal/org/remember.org" "Tasks")
           "** TODO %?                     :remember:\nSCHEDULED: %^T \n")
          ("re" "Event" entry (file+headline "~/dev/Personal/org/remember.org" "Events")
           "** %? \n %^T                     :remember:\n")
          ("rn" "Note" entry (file+headline "~/dev/Personal/org/remember.org" "Notes")
           "** %<%H:%M> %?                     :remember:\n")
          ;; Email workflow
          ("m" "Email Workflow")
          ("mf" "Follow Up" entry (file+olp "~/dev/Personal/org/Mail.org" "Follow Up")
           "* TODO Follow up with %:fromname on %a\nSCHEDULED:%^t\n\n%i")
          ("mr" "Read Later" entry (file+olp "~/dev/Personal/org/Mail.org" "Read Later")
           "* TODO Read %:subject\nSCHEDULED:%^t\n%a\n\n%i")))

  (setq org-refile-targets '((nil :maxlevel . 1)
                             (org-agenda-files :maxlevel . 1))))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun herulume/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . herulume/org-mode-visual-fill))

(org-babel-do-load-languages
  'org-babel-load-languages
  '((emacs-lisp . t)
    (python . t)
    (shell . t)))

(push '("conf-unix" . conf-unix) org-src-lang-modes)

;; Automatically tangle our Emacs.org config file when we save it
(defun herulume/org-babel-tangle-config ()
  (interactive)
  (when (string-equal (buffer-file-name)
                      (expand-file-name "~/dev/TARDIS/Emacs.org"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'herulume/org-babel-tangle-config)))

(use-package org-fancy-priorities
    :hook
    (org-mode . org-fancy-priorities-mode)
    :config
    (setq org-fancy-priorities-list '((?A . "❗")
                                      (?B . "⬆")
                                      (?C . "⬇")
                                      (?D . "☕")
                                      (?1 . "⚡")
                                      (?2 . "⮬")
                                      (?3 . "⮮")
                                      (?4 . "☕")
                                      (?I . "Important"))))

(use-package mu4e
  :ensure nil
  :load-path "/usr/share/emacs/site-lisp/mu4e"
  :defer 20
  :bind ("C-c M" . mu4e)
  :config
  (add-to-list 'mu4e-view-actions '("ViewInBrowser" . mu4e-action-view-in-browser) t)

  (setq mu4e-change-filenames-when-moving t)
  (setq mu4e-headers-skip-duplicates t)

  ;; Refresh mail using isync every 10 minutes
  (setq mu4e-update-interval (* 10 60))
  (setq mu4e-get-mail-command "mbsync -a")
  (setq mu4e-maildir "~/Mail")

  (setq mu4e-compose-context-policy 'ask)

  ;; Make sure plain text mails flow correctly for recipients
  (setq mu4e-compose-format-flowed t)

  ;; Configure the function to use for sending mail
  (setq message-send-mail-function 'smtpmail-send-it)

  (setq mu4e-compose-signature
    (concat
      "(Sent from Emacs)"))



  (setq mu4e-contexts
    (list
      ;; Work account
      (make-mu4e-context
        :name "Social"
        :match-func
          (lambda (msg)
            (when msg
              (string-prefix-p "/Social" (mu4e-message-field msg :maildir))))
        :vars '((user-mail-address . "social.herulume@gmail.com")
                (user-full-name    . "Eduardo Jorge Barbosa")
                (smtpmail-smtp-server  . "smtp.gmail.com")
                (smtpmail-smtp-service . 587)
                (smtpmail-stream-type  . starttls)
                (mu4e-drafts-folder  . "/Social/[Gmail]/Drafts")
                (mu4e-sent-folder  . "/Social/[Gmail]/Sent Mail")
                (mu4e-refile-folder  . "/Social/All Mail")
                (mu4e-trash-folder  . "/Social/[Gmail]/Trash")))

       ;; Work account
       (make-mu4e-context
        :name "Personal"
        :match-func
          (lambda (msg)
            (when msg
              (string-prefix-p "/Herulume" (mu4e-message-field msg :maildir))))
        :vars '((user-mail-address . "herulume@gmail.com")
                (user-full-name    . "Eduardo Barbosa")
                (smtpmail-smtp-server  . "smtp.gmail.com")
                (smtpmail-smtp-service . 465)
                (smtpmail-stream-type  . ssl)
                (mu4e-drafts-folder  . "/Herulume/[Gmail]/Drafts")
                (mu4e-sent-folder  . "/Herulume/[Gmail]/Sent Mail")
                (mu4e-refile-folder  . "/Herulume/All Mail")
                (mu4e-trash-folder  . "/Herulume/[Gmail]/Trash")))))

  (setq mu4e-maildir-shortcuts
    '((:maildir "/Herulume/Inbox"             :key ?i)
      (:maildir "/Herulume/[Gmail]/Sent Mail" :key ?s)
      (:maildir "/Herulume/[Gmail]/Trash"     :key ?t)
      (:maildir "/Herulume/[Gmail]/Drafts"    :key ?d)
      (:maildir "/Herulume/[Gmail]/All Mail"  :key ?a)))

  (setq herulume/mu4e-inbox-query
        "(maildir:/Herulume/Inbox OR maildir:/Social/Inbox) AND flag:unread"))

(use-package mu4e-alert
    :after mu4e
    :config
    ;; Use libnotify
    (mu4e-alert-set-default-style 'libnotify)

    ;; Show unread emails from all inboxes
    (setq mu4e-alert-interesting-mail-query herulume/mu4e-inbox-query)

    ;; Show notifications for mails already notified
    (setq mu4e-alert-notify-repeated-mails nil)

    (mu4e-alert-enable-notifications))

(use-package org-mime
  :config
  (setq org-mime-export-options '(:section-numbers nil
                                  :with-author nil
                                  :with-toc nil)))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/dev")
    (setq projectile-project-search-path '("~/dev")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((lsp-mode . efs/lsp-mode-setup)
         (elixir-mode . lsp)
         (go-mode . lsp))
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-ivy)

(use-package dap-mode
  ;; :custom
  ;; (dap-auto-configure-features '(sessions locals tooltip))
  :commands dap-debug
  :config
  (dap-ui-mode 1)
  ;; Set up Go debugging
  (require 'dap-go)
  (dap-go-setup))

(use-package company
  ;;      :after lsp-mode
  ;;    :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
  (:map lsp-mode-map
        ("<tab>" . company-indent-or-complete-common))
  :bind (("C-x C-j" . dired-jump))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0)
  (global-company-mode 1))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package yasnippet
   :config
   (yas-global-mode))

(use-package yasnippet-snippets)

;;  (use-package agda2-mode
;;    :if (file-directory-p "/home/herulume/Downloads/Agda-nightly/data/emacs-mode")
;;    :config
;;    (load-file (let ((coding-system-for-read 'utf-8))
;;            (shell-command-to-string "agda-mode locate")))
;;    (setq agda2-directory "/home/herulume/Downloads/Agda-nightly/data/emacs-mode/")
;;    (setq agda2-program-args
;;          (quote
;;           ("+RTS" "-K256M" "-H6G" "-M6G" "-A128M" "-RTS"))))

(use-package elixir-mode)

(use-package exunit
  :init (add-hook 'elixir-mode-hook 'exunit-mode))

(add-to-list 'exec-path "~/.local/bin/elixir-lsp")

(use-package go-mode)

(use-package yaml-mode)

(use-package dockerfile-mode)

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first")
           (dired-dwim-target t))
  :if (memq window-system '(mac ns))
  :config
  (setq insert-directory-program "gls" dired-use-ls-dired t))

(use-package dired-single)

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :config
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode))

(defun herulume/margo ()
  "i'M A biG BelIEVer iN ranDoM caPitALIZaTION."
  (interactive)
  (let ((i 0)
        (return-string "")
        (input (buffer-substring-no-properties (point-min) (point-max))))
    (while (< i (- (point-max) (point-min)))
      (let ((current-char (substring input i (+ i 1))))
        (if (= (random 2) 0)
            (setq return-string
                  (concat return-string (upcase current-char)))
          (setq return-string
                (concat return-string (downcase current-char)))))
      (setq i (+ i 1)))
    (let ((l (point)))
      (delete-region (point-min) (point-max))
      (insert return-string)
      (goto-char l))))

(defun herulume/pomodoro ()
  "Start a pomodoro sequence"
  (interactive)

  (setq pomodoro-session 0)
  (while (< pomodoro-session 3)
    (herulume/pomodoro-work)
    (herulume/pomodoro-short-break)
    (setq pomodoro-session (1+ pomodoro-session)))

  (herulume/pomodoro-work)
  (herulume/pomodoro-long-break))

(defun herulume/pomodoro-work ()
  "Start a pomodoro work timer"
  (interactive)
  (org-timer-set-timer 25))

(defun herulume/pomodoro-short-break ()
  "Start a pomodoro short break timer"
  (interactive)
  (org-timer-set-timer 5))

(defun herulume/pomodoro-long-break ()
  "Start a pomodoro long break timer"
  (interactive)
  (org-timer-set-timer 20)) ; 15-30

(defun herulume/pomodoro-stop ()
  "Stop a pomodoro timer"
  (interactive)
  (org-timer-stop))

(defun herulume/pomodoro-pause-or-continue ()
  "Pause or continue a pomodoro timer"
  (interactive)
  (org-timer-pause-or-continue))

(defun herulume/pomodoro-show-timer ()
  "Show pomodoro timer"
  (interactive)
  (org-timer-show-remaining-time))

(when (memq window-system '(mac ns))
      (setq mac-option-modifier nil
            mac-right-command-modifier 'super
            mac-command-modifier 'meta
            x-select-enable-clipboard t))

(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))

(use-package flyspell
  :hook
  (text-mode . flyspell-mode)
  (prog-mode . flyspell-mode))

(use-package flyspell-correct
  :after flyspell
  :bind (:map flyspell-mode-map ("C-;" . flyspell-correct-wrapper)))

(use-package flyspell-correct-ivy
  :after flyspell-correct)

(use-package undo-tree
:config
(global-undo-tree-mode))

(use-package pdf-tools
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-annot-activate-created-annotations t)
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward)
  (define-key pdf-view-mode-map (kbd "C-r") 'isearch-backward))

(use-package auto-dictionary
  :init(add-hook 'flyspell-mode-hook (lambda () (auto-dictionary-mode 1))))

(setq gc-cons-threshold (* 2 1000 1000))
