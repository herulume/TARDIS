;;; pre-early-init.el --- run before early-init -*- no-byte-compile: t; lexical-binding: t; -*-

;; Debug
(setq debug-on-error t)

;; Display startup time
(defun display-startup-time ()
  "Display the startup time and number of garbage collections."
  (message "Emacs init loaded in %.2f seconds (Full emacs-startup: %.2fs) with %d garbage collections."
           (float-time (time-subtract after-init-time before-init-time))
           (time-to-seconds (time-since before-init-time))
           gcs-done))

(add-hook 'emacs-startup-hook #'display-startup-time 100)

;; Reducing clutter in ~/.emacs.d by redirecting files to ~/.emacs.d/var/
;; IMPORTANT: This part should be in the pre-early-init.el file
(setq minimal-emacs-var-dir (expand-file-name "var/" minimal-emacs-user-directory))
(setq package-user-dir (expand-file-name "elpa" minimal-emacs-var-dir))
(setq user-emacs-directory minimal-emacs-var-dir)

;; Elpaca
(setq minimal-emacs-package-initialize-and-refresh nil)
