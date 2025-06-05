;; -*- lexical-binding: t; -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Performance Optimization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Increase GC threshold during startup
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Reset GC threshold after startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 2 1000 1000)
                  gc-cons-percentage 0.1)
            (message "*** Emacs loaded in %s seconds with %d garbage collections."
                     (emacs-init-time "%.2f")
                     gcs-done)))

;; Native compilation settings
(when (featurep 'native-compile)
  (setq native-comp-async-report-warnings-errors nil
        native-comp-deferred-compilation t)
  (add-to-list 'native-comp-eln-load-path 
               (expand-file-name "eln-cache/" user-emacs-directory)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package System & use-package Setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("gnu"   . "https://elpa.gnu.org/packages/"))
      package-archive-priorities
      '(("melpa" . 10)
        ("nongnu" . 5)
        ("gnu" . 0)))

(package-initialize)

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t
      use-package-verbose t
      use-package-expand-minimally t)

;; Add custom lisp directory to load path
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Core UI Settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Disable startup screen and maximize frame
(setq inhibit-startup-message t
      inhibit-startup-screen t
      inhibit-startup-echo-area-message t)

(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Disable unnecessary UI elements
(tool-bar-mode -1)
(tooltip-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode 1)

;; Better defaults
(setq-default cursor-type 'box
              ring-bell-function #'ignore
              use-dialog-box nil
              use-file-dialog nil
              pop-up-windows t
              delete-by-moving-to-trash t
              column-number-mode t
              fringe-indicator-alist nil)

(fringe-mode 0)
(window-divider-mode 0)
(defalias 'yes-or-no-p 'y-or-n-p)

;; Encoding
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; Clipboard integration
(setq x-select-enable-clipboard t
      x-select-enable-primary t
      save-interprogram-paste-before-kill t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Scrolling and Navigation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq scroll-bar-adjust-thumb-portion t
      mouse-wheel-progressive-speed nil
      mouse-wheel-follow-mouse t
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode t))

;; Better scrollbar handling
(set-window-scroll-bars (minibuffer-window) nil nil nil nil t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File Handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Disable backup and auto-save files
(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil)

;; Recent files
(use-package recentf
  :ensure nil
  :init
  (recentf-mode 1)
  :custom
  (recentf-max-menu-items 25)
  (recentf-max-saved-items 100)
  (recentf-exclude '("~/.emacs.d/elpa/"))
  :bind ("C-x C-r" . recentf-open-files)
  :config
  (run-at-time nil (* 5 60) 'recentf-save-list))

;; Auto-revert buffers when files change
(use-package autorevert
  :ensure nil
  :diminish auto-revert-mode
  :init
  (global-auto-revert-mode 1)
  :custom
  (auto-revert-avoid-polling t)
  (auto-revert-verbose nil)
  (global-auto-revert-non-file-buffers t))

;; Save place in files
(use-package saveplace
  :ensure nil
  :init
  (save-place-mode 1))

;; Bookmarks
(setq bookmark-save-flag 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Editing Behavior
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Indentation
(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80)

;; Electric pairs
(use-package electric
  :ensure nil
  :init
  (electric-pair-mode 1)
  :custom
  (electric-pair-pairs '((?\{ . ?\}) (?\( . ?\)) (?\[ . ?\]) (?\" . ?\"))))

;; Delete selection mode
(delete-selection-mode 1)

;; Tab completion
(setq tab-always-indent 'complete
      read-extended-command-predicate #'command-completion-default-include-p)

;; Search settings
(setq isearch-lazy-count t
      search-highlight t
      search-whitespace-regexp ".*?"
      isearch-lax-whitespace t
      isearch-regexp-lax-whitespace nil)

;; Line numbers (disabled by default, can be toggled)
(setq display-line-numbers-type 'relative)

;; Warnings
(setq warning-minimum-level :error)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fonts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun set-font-faces ()
  "Set font faces for different contexts."
  (message "Setting font faces...")
  (when (find-font (font-spec :name "Noto Color Emoji"))
    (set-fontset-font t 'symbol (font-spec :family "Noto Color Emoji" :size 24)))
  (when (find-font (font-spec :name "Iosevka"))
    (set-face-attribute 'default nil :family "Iosevka" :height 120)
    (set-face-attribute 'fixed-pitch nil :family "Iosevka" :height 120))
  (when (find-font (font-spec :name "Lato"))
    (set-face-attribute 'variable-pitch nil :family "Lato" :height 130)))

(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame
                  (set-font-faces))))
  (set-font-faces))

(setq line-spacing 0.1) ; Slightly increased for better readability

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Key Bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Window navigation
(global-set-key (kbd "M-o") 'other-window)

;; Line numbers toggle
(global-set-key (kbd "M-<f2>") 
                (lambda () (interactive) (display-line-numbers-mode 'toggle)))

;; Scrollbar toggle
(global-set-key (kbd "M-<f3>") 'scroll-bar-mode)

;; Improved window splitting
(defun split-and-follow-vertically ()
  "Split window vertically and follow to new window."
  (interactive)
  (split-window-right)
  (balance-windows)
  (other-window 1))

(defun split-and-follow-horizontally ()
  "Split window horizontally and follow to new window."
  (interactive)
  (split-window-below)
  (balance-windows)
  (other-window 1))

(global-set-key (kbd "C-x 3") #'split-and-follow-vertically)
(global-set-key (kbd "C-x 2") #'split-and-follow-horizontally)

;; Input method
(add-hook 'after-init-hook (lambda () (setq default-input-method "greek")))

;; Improved buffer killing
(defun my-kill-this-buffer ()
  "Kill current buffer with save prompt if modified."
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

;; Completion
(global-set-key (kbd "M-/") #'completion-at-point)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spell Checking
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package ispell
  :ensure nil
  :defer t
  :config
  (when (executable-find "hunspell")
    (setq ispell-program-name "hunspell"
          ispell-dictionary "el_GR,en_US"
          ispell-personal-dictionary "~/.hunspell_personal")
    (ispell-set-spellchecker-params)
    (ispell-hunspell-add-multi-dic "el_GR,en_US")))

(setq dictionary-server "dict.org")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Theme and Appearance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package modus-themes
  :ensure t
  :init
  (setq modus-themes-headings
        '((1 . (1.6))
          (2 . (1.4))
          (3 . (1.2))
          (4 . (1.1))
          (t . (1.0)))
        modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts t
        modus-themes-subtle-line-numbers t
        modus-themes-deuteranopia nil
        modus-themes-variable-pitch-ui nil)
  :config
  (load-theme 'modus-operandi t)
  (define-key global-map (kbd "<f5>") #'modus-themes-toggle))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Essential Packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package which-key
  :diminish which-key-mode
  :init
  (which-key-mode 1)
  :custom
  (which-key-idle-delay 0.5)
  (which-key-idle-secondary-delay 0.05))

(use-package vundo
  :bind ("C-x C-u" . vundo)
  :custom
  (vundo-glyph-alist vundo-unicode-symbols)
  (vundo-window-max-height 10)
  :config
  (vundo-popup-mode))

(use-package dashboard
  :custom
  (dashboard-startup-banner 'logo)
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-startupify-list '(dashboard-insert-banner))
  (dashboard-items '((recents . 10)
                     (projects . 5)))
  :config
  (dashboard-setup-startup-hook)
  (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Completion Framework
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package vertico
  :init
  (vertico-mode)
  :custom
  (vertico-cycle t)
  (vertico-count 10))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

(use-package corfu
  :custom
  (corfu-cycle t)
  (corfu-auto nil)
  (corfu-separator ?\s)
  (corfu-quit-no-match 'separator)
  :bind (:map corfu-map
              ("SPC" . corfu-insert-separator))
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Project Management
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package project
  :ensure nil
  :custom
  (project-vc-extra-root-markers '(".project" ".git")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Direnv
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package direnv)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Programming
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; tree-sitter
(use-package tree-sitter
  :config
  (global-tree-sitter-mode))

(use-package tree-sitter-langs
  :after tree-sitter)

(use-package treesit-auto
  :config
  (global-treesit-auto-mode))

;; Eglot (lsp-server)
(use-package eglot
  :config
  (add-to-list 'eglot-server-programs '((python-base-mode)
                                        "basedpyright-langserver" "--stdio")))

;; Python
(use-package ruff-format)
(add-hook 'python-base-mode-hook 'ruff-format-on-save-mode)
(add-hook 'python-base-mode-hook 'direnv-mode)

;; Programming mode hooks
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Terminal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package vterm
  :custom
  (vterm-shell "fish")
  (vterm-max-scrollback 100000))

(defun my-project-shell ()
  "Start an inferior shell in the current project's root directory.
If a buffer already exists for running a shell in the project's root,
switch to it.  Otherwise, create a new shell buffer.
With \\[universal-argument] prefix arg, create a new inferior shell buffer even
if one already exists."
  (interactive)
  (require 'comint)
  (let* ((default-directory (project-root (project-current t)))
         (default-project-shell-name (project-prefixed-buffer-name "shell"))
         (shell-buffer (get-buffer default-project-shell-name)))
    (if (and shell-buffer (not current-prefix-arg))
        (if (comint-check-proc shell-buffer)
            (switch-to-buffer-other-window shell-buffer)
          (progn
            (switch-to-buffer-other-window shell-buffer)
            (vterm-mode)))
      (let ((new-buf (generate-new-buffer default-project-shell-name)))
        (switch-to-buffer-other-window new-buf)
        (vterm-mode)))))

(advice-add 'project-shell :override #'my-project-shell)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Writing and Note-taking
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package olivetti
  :custom
  (olivetti-body-width 120))

(use-package darkroom
  :hook ((darkroom-mode . mixed-pitch-mode))
  :custom
  (darkroom-text-scale-increase 1))

(defun my/mixed-pitch-cursor-fix ()
  "Fix cursor type in mixed-pitch mode."
  (setq-local cursor-type 'box))

(add-hook 'mixed-pitch-mode-hook #'my/mixed-pitch-cursor-fix)

;; Text mode setup
(defun my-prose-setup ()
  "Setup for prose writing."
  (visual-line-mode 1)
  (setq truncate-lines nil))

(add-hook 'text-mode-hook #'my-prose-setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Markdown
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package markdown-mode
  :mode "\\.md\\'"
  :hook ((markdown-mode . olivetti-mode)
         (markdown-mode . save-place-local-mode)
         (markdown-mode . my/markdown-highlight-tags))
  :custom
  (markdown-enable-math t)
  (markdown-max-image-size '(800 . 600))
  (markdown-asymmetric-header t)
  (markdown-fontify-code-blocks-natively t)
  (markdown-enable-highlighting-syntax t)
  (markdown-enable-wiki-links t)
  (markdown-wiki-link-alias-first nil))

;; Markdown customizations
(with-eval-after-load 'markdown-mode
  ;; Highlight pandoc-style citations
  (font-lock-add-keywords 'markdown-mode
                          '(("\\(@[^]]+\\)" 1 font-lock-keyword-face)))

  ;; Tag highlighting
  (defface my/tag-face
    '((t :foreground "#6c7086"))
    "Face for tags like #inbox or #projects/name.")

  (defun my/markdown-highlight-tags ()
    "Highlight tags in markdown mode."
    (font-lock-add-keywords
     nil
     '(("\\(#+[A-Za-z][A-Za-z0-9_/\\-]*\\)" 1 'my/tag-face))))

  ;; Markup hiding functionality
  (defvar nb/current-line '(0 . 0)
    "(start . end) of current line in current buffer")
  (make-variable-buffer-local 'nb/current-line)

  (defun nb/unhide-current-line (limit)
    "Font-lock function to unhide current line."
    (let ((start (max (point) (car nb/current-line)))
          (end (min limit (cdr nb/current-line))))
      (when (< start end)
        (remove-text-properties start end
                                '(invisible t display "" composition ""))
        (goto-char limit)
        t)))

  (defun nb/refontify-on-linemove ()
    "Post-command-hook to refontify on line move."
    (let* ((start (line-beginning-position))
           (end (line-beginning-position 2))
           (needs-update (not (equal start (car nb/current-line)))))
      (setq nb/current-line (cons start end))
      (when needs-update
        (font-lock-fontify-block 3))))

  (defun nb/markdown-unhighlight ()
    "Enable markdown concealing with current line unhiding."
    (interactive)
    (markdown-toggle-markup-hiding 'toggle)
    (font-lock-add-keywords nil '((nb/unhide-current-line)) t)
    (add-hook 'post-command-hook #'nb/refontify-on-linemove nil t))

  (add-hook 'markdown-mode-hook #'nb/markdown-unhighlight))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bibliography and Citations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar org-cite-csl--fallback-locales-dir "~/HDD/Library/Zotero data/styles/")

(use-package citar
  :custom
  (citar-bibliography '("~/HDD/Library/References/biblio.bib"))
  (citar-format-reference-function 'citar-citeproc-format-reference)
  (citar-markdown-prompt-for-extra-arguments nil)
  (citar-file-open-functions '(("html" . citar-file-open-external) 
                               ("pdf" . citar-file-open-external) 
                               (t . find-file)))
  (citar-open-entry-function #'citar-open-entry-in-zotero)
  (citar-citeproc-csl-styles-dir "~/HDD/Library/Zotero data/styles/")
  :hook
  (markdown-mode . citar-capf-setup))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PDF handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package doc-view
  :ensure nil
  :custom
  (doc-view-dvipdfm-program "mutool")
  (doc-view-continuous t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Zettelkasten (ZK)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package zk
  :init
  (add-hook 'completion-at-point-functions #'zk-completion-at-point 'append)
  (defun zk-new-note-header (title new-id &optional orig-id)
    "Insert header in new notes with TITLE and NEW-ID. Optionally use ORIG-ID for backlink."
    (insert (format "# %s %s\n\n" new-id title)))
  :custom
  (zk-directory "~/Documents/02-Areas/Slipbox")
  (zk-file-extension "md")
  (zk-id-time-string-format "%Y%m%d%H%M%S")
  (zk-id-regexp "\\([0-9]\\{14\\}\\)")
  (zk-tag-regexp "\\s#\\+[A-Za-z_/\\-][A-Za-z0-9_/\\-]*")
  (zk-new-note-link-insert 'zk)
  (zk-link-and-title nil)
  :config
  (zk-setup-auto-link-buttons))

(use-package zk-index 
  :after zk)

;; ZK-Citar integration
(with-eval-after-load 'citar
  (with-eval-after-load 'zk
    (require 'zk-citar)
    (setq citar-notes-source 'zk
          zk-citar-citekey-regexp "^[0-9]+[[:space:]]+L1[[:space:]]+\\(\\S-+\\)[[:space:]]+-.*"
          zk-citar-title-template "L1 ${=key=} - ${title}")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LaTeX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package cdlatex
  :hook ((latex-mode . cdlatex-mode)
         (LaTeX-mode . cdlatex-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom Settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ignored-local-variable-values
   '((eval add-hook 'after-save-hook
           (lambda nil (if (y-or-n-p "Tangle?") (org-babel-tangle))) nil t)))
 '(package-selected-packages
   '(cape cdlatex citar corfu darkroom dashboard direnv marginalia markdown-mode
          modus-themes olivetti orderless pet reformatter ruff-format
          tree-sitter-langs treesit-auto vertico vterm vundo zk-index)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Enable previously disabled commands
(put 'dired-find-alternate-file 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Startup Message
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-hook 'after-init-hook
          (lambda ()
            (message "Emacs configuration loaded successfully!")))
