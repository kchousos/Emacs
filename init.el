;; -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package System & use-package Setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Miscellaneous Settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq gc-cons-threshold (* 50 1000 1000))

(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s seconds with %d garbage collections."
                     (emacs-init-time "%.2f")
                     gcs-done)))

(setq native-comp-async-report-warnings-errors nil)
(add-to-list 'native-comp-eln-load-path (expand-file-name "eln-cache/" user-emacs-directory))

(setq inhibit-startup-message t)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq delete-by-moving-to-trash t)

(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)

(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)

(setq x-select-enable-clipboard t)
(setq view-read-only t)
(setq ring-bell-function #'ignore)
(defalias 'yes-or-no-p 'y-or-n-p)
(setq column-number-mode t)
(setq-default fringe-indicator-alist nil)
(fringe-mode 0)
(blink-cursor-mode 1)
(setq cursor-type 'box)
(global-hl-line-mode 0)

(global-set-key (kbd "M-<f3>") 'scroll-bar-mode)
(scroll-bar-mode 0)
(window-divider-mode 0)

(setq scroll-bar-adjust-thumb-portion t)
(set-window-scroll-bars (minibuffer-window) nil nil nil nil t)

(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-follow-mouse 't)
(setq scroll-step 1)

(pixel-scroll-precision-mode t)

(setq make-backup-files nil)
(setq auto-save-default nil)

(setq-default indent-tabs-mode nil
              tab-width 4)
(setq indent-line-function #'insert-tab)

(setq electric-pair-pairs '((?\{ . ?\}) (?\( . ?\)) (?\[ . ?\]) (?\" . ?\")))
(electric-pair-mode t)

(global-display-line-numbers-mode 0)
(setq display-line-numbers-type 'relative)
(setq warning-minimum-level :emergency)

(recentf-mode 1)
(setq recentf-max-menu-items 25
      recentf-max-saved-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)
(run-at-time nil (* 5 60) 'recentf-save-list)

(setq isearch-lazy-count t)
(setq auto-revert-avoid-polling t)
(global-auto-revert-mode)

(setq bookmark-save-flag 1)
(delete-selection-mode 1)

(save-place-mode 1)

(setq tab-always-indent 'complete)
(setq read-extended-command-predicate #'command-completion-default-include-p)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fonts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun set-font-faces ()
        (message "Setting faces!")
        (set-fontset-font t 'symbol (font-spec :family "Noto Color Emoji" :size 24))
        (set-face-attribute 'default nil :family "Iosevka" :height 120)
        (set-face-attribute 'fixed-pitch nil :family "Iosevka" :height 120)
        (set-face-attribute 'variable-pitch nil :family "Lato" :height 130))

(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame
                  (set-font-faces))))
  (set-font-faces))

(setq line-spacing 0.0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Keybinds
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key (kbd "M-o") 'other-window)

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(with-eval-after-load "ispell"
  (setq ispell-program-name "hunspell")
  (setq ispell-dictionary "el_GR,en_US")
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "el_GR,en_US")
  (setq ispell-personal-dictionary "~/.hunspell_personal"))

(setq dictionary-server "dict.org")

(use-package which-key
  :config (which-key-mode))

(setq modus-themes-headings
              '((1 . (1.6))
                (2 . (1.4))
                (3 . (1.2))
                (4 . (1.1))
                (t . (1.0))))

(use-package emacs
  :esnure nil
  :config
  (require-theme 'modus-themes)
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts t
        modus-themes-subtle-line-numbers t
        modus-themes-deuteranopia nil
        modus-themes-variable-pitch-ui nil)
  (load-theme 'modus-operandi))

(defvar mine:dark-theme 'modus-vivendi)
(defvar mine:light-theme 'modus-operandi)

(defun mine:theme-from-dbus (value)
  (load-theme (if (= 2 (car (flatten-list value)))
                  mine:light-theme
                mine:dark-theme)
              t))

(use-package dbus
  :config
  (dbus-call-method-asynchronously
   :session "org.freedesktop.portal.Desktop"
   "/org/freedesktop/portal/desktop"
   "org.freedesktop.portal.Settings"
   "Read"
   #'mine:theme-from-dbus
   "org.freedesktop.appearance"
   "color-scheme")
  (dbus-register-signal
   :session "org.freedesktop.portal.Desktop"
   "/org/freedesktop/portal/desktop"
   "org.freedesktop.portal.Settings"
   "SettingChanged"
   (lambda (_path var value)
     (when (string-equal var "color-scheme")
       (mine:theme-from-dbus value)))))

(use-package vundo
  :bind ("C-x C-u" . vundo)
  :config
  (setq vundo-glyph-alist vundo-unicode-symbols
        vundo-window-max-height 5))

(use-package dashboard
  :config
  (setq dashboard-startup-banner 'logo
        dashboard-center-content t
        dashboard-vertically-center-content t
        dashboard-startupify-list '(dashboard-insert-banner))
  (dashboard-setup-startup-hook)
  (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*"))))

(use-package project
  :config
  (setq project-vc-extra-root-markers '(".project")))

(use-package vertico
  :config (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; (use-package evil
;;   :config (evil-mode 1))

(defun my/mixed-pitch-cursor-fix ()
  (setq-local cursor-type 'box))

(use-package olivetti
  :custom
  (olivetti-body-width 120))

(use-package markdown-mode
  :mode "\\.md\\'"
  :hook ((markdown-mode . olivetti-mode))
  :init
  (setq-default markdown-enable-math t
                markdown-asymmetric-header t
                markdown-fontify-code-blocks-natively t
                markdown-enable-highlighting-syntax t
                markdown-enable-wiki-links t
                markdown-wiki-link-alias-first nil))

(use-package darkroom
  :hook (;;(darkroom-mode . variable-pitch-mode)
         (darkroom-mode . mixed-pitch-mode)
         (mixed-pitch-mode . my/mixed-pitch-cursor-fix))
  :init
  (setq darkroom-text-scale-increase 1))

(defun my-prose-setup ()
  (visual-line-mode 1)
  (setq truncate-lines nil))
(add-hook 'text-mode-hook #'my-prose-setup)

(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
(setq-default fill-column 80)

(use-package tree-sitter
  :config (global-tree-sitter-mode))

(use-package tree-sitter-langs)

(use-package zk
  :init
  (add-hook 'completion-at-point-functions #'zk-completion-at-point 'append)
  :custom
  (defun zk-new-note-header (title new-id &optional orig-id)
    "Insert header in new notes with args TITLE and NEW-ID.
Optionally use ORIG-ID for backlink."
    (insert (format "# %s %s\n\n#inbox\n\n" new-id title)))
      (zk-directory "~/Documents/02 Areas/Slipbox")
  (zk-file-extension "md")
  (zk-id-time-string-format "%Y%m%d%H%M%S")
  (zk-id-regexp "\\([0-9]\\{14\\}\\)")
  :config
  (zk-setup-auto-link-buttons))

(use-package vterm
  :custom
  (vterm-shell "fish"))

(use-package corfu
  :custom
  (corfu-cycle t) ;; Enable cycling for `corfu-next/previous'
  :bind
  ;; Configure SPC for separator insertion
  (:map corfu-map ("SPC" . corfu-insert-separator))
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode))

(use-package cape
  :ensure t
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

(global-set-key (kbd "M-/") #'completion-at-point)

(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

(defvar org-cite-csl--fallback-locales-dir "~/HDD/Library/Zotero data/styles/")

(use-package citar
  :custom
  (citar-bibliography '("~/HDD/Library/References/biblio.bib"))
  (citar-format-reference-function 'citar-citeproc-format-reference)
  (citar-markdown-prompt-for-extra-arguments nil)
  (citar-indicators
  (list citar-indicator-files ; plain text
        citar-indicator-notes-icons)) ; icon
  (citar-file-open-functions '(("html" . citar-file-open-external) ("pdf" . citar-file-open-external) (t . find-file)))
  (citar-citeproc-csl-styles-dir "~/HDD/Library/Zotero data/styles/")
  :hook
  (markdown-mode . citar-capf-setup))

(with-eval-after-load 'citar
  (with-eval-after-load 'zk
    (require 'zk-citar)))

(setq citar-notes-source 'zk)

(setq zk-citar-citekey-regexp "^[0-9]+[[:space:]]+L1[[:space:]]+\\(\\S-+\\)[[:space:]]+-.*")
(setq zk-citar-title-template "L1 ${=key=} - ${title}")

(global-font-lock-mode t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(cape cdlatex citar citeproc corfu darkroom dashboard evil marginalia
          mixed-pitch modus-themes olivetti orderless org-xlatex pandoc-mode
          quarto-mode rust-mode tree-sitter-langs undo-tree vertico vterm vundo
          xenops yaml yaml-mode zk-index)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'dired-find-alternate-file 'disabled nil)
