;; -*- lexical-binding: t; -*-

;; Package system setup
;; Must come before any package use
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Install use-package if not already installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
;; Always ensure packages are installed
(setq use-package-always-ensure t)

;; ;; Custom file setup - create if doesn't exist
;; (setq custom-file "~/.emacs.d/custom-file.el")
;; (unless (file-exists-p custom-file)
;;   (write-region "" nil custom-file))
;; (load custom-file)

;; Miscellaneous settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The default is 800 kilobytes. Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s seconds with %d garbage collections."
                     (emacs-init-time "%.2f")
                     gcs-done)))

;; Silence compiler warnings as they can be pretty disruptive
(setq native-comp-async-report-warnings-errors nil)

;; Set the right directory to store the native comp cache
(add-to-list 'native-comp-eln-load-path (expand-file-name "eln-cache/" user-emacs-directory))

(setq user-full-name "Konstantinos Chousos")

(setq inhibit-startup-message t)

;; (add-to-list 'default-frame-alist '(height . 60))
;; (add-to-list 'default-frame-alist '(width . 220))
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)

(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)

(setq x-select-enable-clipboard t)

;; use `view-mode` for read-only files
(setq view-read-only t)

(setq ring-bell-function #'ignore)

(defalias 'yes-or-no-p 'y-or-n-p)

(setq column-number-mode t)

;; Remove the line-wrap fringe indicators
(setq-default fringe-indicator-alist nil)

(fringe-mode 0)

;; Replace with proper word wrap configuration
(use-package visual-fill-column
  :config
  (setq-default visual-fill-column-center-text t
                 visual-fill-column-width 120))

(defun my-prose-setup ()
  "Enable visual line wrapping and visual fill column for prose."
  (visual-line-mode 1)                         ;; Soft wraps at word boundaries
  (visual-fill-column-mode 1)                 ;; Visually wrap at fill-column
  (setq truncate-lines nil))                  ;; Ensure lines are not truncated

(add-hook 'text-mode-hook #'my-prose-setup)

(blink-cursor-mode 1)

(global-hl-line-mode 0)

(global-set-key (kbd "M-<f3>") 'scroll-bar-mode)
(scroll-bar-mode 0)
(window-divider-mode 0)

(setq scroll-bar-adjust-thumb-portion t)

(set-window-scroll-bars (minibuffer-window) nil nil nil nil t)

(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling

(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

(setq scroll-step 1) ;; keyboard scroll one line at a time

(pixel-scroll-precision-mode t)

(setq make-backup-files nil)
(setq auto-save-default nil)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function #'insert-tab)

(setq electric-pair-pairs '(
                            (?\{ . ?\})
                            (?\( . ?\))
                            (?\[ . ?\])
                            (?\" . ?\")
                            ))
(electric-pair-mode t)

(global-display-line-numbers-mode 0)

(setq display-line-numbers-type 'relative)

(setq warning-minimum-level :emergency)

(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)
(run-at-time nil (* 5 60) 'recentf-save-list)

(setq isearch-lazy-count t)

(setq auto-revert-avoid-polling t)
(global-auto-revert-mode)

(setq bookmark-save-flag 1)

(delete-selection-mode 1)

;; FONTS
(defun set-font-faces ()
        (message "Setting faces!")
        (set-fontset-font t 'symbol (font-spec :family "Noto Color Emoji" :size 24))
        (set-face-attribute 'default nil :family "Iosevka" :height 120)
        (set-face-attribute 'fixed-pitch nil :family "Iosevka" :height 1.0)
        (set-face-attribute 'variable-pitch nil :family "Inter"))

(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame
                  (set-font-faces))))
    (set-font-faces))

(setq line-spacing 0.0)

;; Keybinds
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key (kbd "M-<f2>") #'(lambda () (interactive) (display-line-numbers-mode #'toggle)))

(defun split-and-follow-vertically ()
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))

(global-set-key (kbd "C-x 3") #'split-and-follow-vertically)

(defun split-and-follow-horizontally ()
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))

(global-set-key (kbd "C-x 2") #'split-and-follow-horizontally)

(add-hook 'after-init-hook (lambda () (setq default-input-method "greek")))

(defun my-kill-this-buffer ()
  (interactive)
  (catch 'quit
    (save-window-excursion
      (let (done)
        (when (and buffer-file-name (buffer-modified-p))
          (while (not done)
            (let ((response (read-char-choice
                             (format "Save file %s? (y, n, d, q) " (buffer-file-name))
                             '(?y ?n ?d ?q))))
              (setq done (cond
                          ((eq response ?q) (throw 'quit nil))
                          ((eq response ?y) (save-buffer) t)
                          ((eq response ?n) (set-buffer-modified-p nil) t)
                          ((eq response ?d) (diff-buffer-with-file) nil))))))
        (kill-buffer (current-buffer))))))
(global-set-key (kbd "C-x C-k") #'my-kill-this-buffer)

;; Show syntax highlighting
(global-font-lock-mode t)

;; Install and enable tree-sitter
(use-package tree-sitter
  :config
  (use-package tree-sitter-langs)
  (global-tree-sitter-mode))

;; Packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package which-key
  :init (which-key-mode))

(recentf-mode t)

(defvar mine:dark-theme 'modus-vivendi
  "Default dark theme.")

(defvar mine:light-theme 'modus-operandi
  "Default light theme.")

(defun mine:theme-from-dbus (value)
  "Change the theme based on a D-Bus property.

VALUE should be an integer or an arbitrarily nested list that
contains an integer.  When VALUE is equal to 2 then a light theme
will be selected, otherwise a dark theme will be selected."
  (load-theme (if (= 2 (car (flatten-list value)))
                  mine:light-theme
                mine:dark-theme)
              t))

(setq modus-themes-headings
      '((1 . (1.1))
        (2 . (1.075))
        (3 . (1.05))
        (4 . (1.025))
        (t . (1.0))))

(use-package dbus)
;; Set the current theme based on what the system theme is right now:
(dbus-call-method-asynchronously
   :session "org.freedesktop.portal.Desktop"
   "/org/freedesktop/portal/desktop"
   "org.freedesktop.portal.Settings"
   "Read"
   #'mine:theme-from-dbus
   "org.freedesktop.appearance"
   "color-scheme")
;; Register to be notified when the system theme changes:
(dbus-register-signal
   :session "org.freedesktop.portal.Desktop"
   "/org/freedesktop/portal/desktop"
   "org.freedesktop.portal.Settings"
   "SettingChanged"
   (lambda (path var value)
     (when (and (string-equal path "org.freedesktop.appearance")
                (string-equal var "color-scheme"))
       (mine:theme-from-dbus value))))

(use-package undo-tree
  :init
  (setq undo-tree-auto-save-history t)

  (defadvice undo-tree-make-history-save-file-name
      (after undo-tree activate)
    (setq ad-return-value (concat ad-return-value ".gz")))

  (setq undo-tree-visualizer-diff t)
  (setq undo-tree-history-directory-alist '(("." . "~/.config/emacs/undo")))
  
  ;; Create the directory if it doesn't exist
  (unless (file-exists-p "~/.config/emacs/undo")
    (make-directory "~/.config/emacs/undo" t))

  (global-undo-tree-mode))

(use-package dashboard
  :config
  ;; Set the banner
  (setq dashboard-startup-banner 'logo)
  ;; Value can be
  ;; 'official which displays the official emacs logo
  ;; 'logo which displays an alternative emacs logo
  ;; 1, 2 or 3 which displays one of the text banners
  ;; "path/to/your/image.png" or "path/to/your/text.txt" which displays whatever image/text you would prefer
  ;; Content is not centered by default. To center, set
  (setq dashboard-center-content t)
  (setq dashboard-vertically-center-content t)
  ;; (setq dashboard-set-navigator nil)
  ;; (setq dashboard-banner-logo-title nil)
  ;; (setq dashboard-show-shortcuts nil)
  ;; (setq dashboard-set-heading-icons nil)
  ;; (setq dashboard-set-file-icons nil)
  ;; (setq dashboard-set-init-info nil)
  ;; (setq dashboard-set-footer nil)
  ;; (setq dashboard-week-agenda nil)
  ;; (setq dashboard-page-separator "\n\n")
  ;; (setq dashboard-items nil)
  (setq dashboard-startupify-list '(dashboard-insert-banner
                                    ;; dashboard-insert-newline
                                    ;; dashboard-insert-banner-title
                                    ;; dashboard-insert-newline
                                    ;; dashboard-insert-init-info
                                    ;; dashboard-insert-items
                                    ;; dashboard-insert-newline
                                  ;; dashboard-insert-footer
                                  ))
  ;; (setq dashboard-items '(;;(bookmarks . 20)
  ;;                         ;; (projects . 5)
  ;;                         ;; (recents . 5)
  ;;                         ;; (agenda . 10)
  ;;                         ))

  (dashboard-setup-startup-hook))
(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

(use-package markdown-mode)

;; Make sure all packages are installed at startup
(unless package-archive-contents
  (package-refresh-contents))
(put 'dired-find-alternate-file 'disabled nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(dashboard markdown-mode quarto-mode tree-sitter-langs undo-tree visual-fill-column)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Prog mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
(setq-default fill-column 80)
