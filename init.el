;; -*- lexical-binding: t; eval: (outline-minor-mode 1) -*-

;;; Locale settings

(setenv "LC_TIME" "el_GR.UTF-8")
(setq system-time-locale "el_GR.UTF-8")

(setq calendar-week-start-day 1
      calendar-day-name-array ["Κυριακή" "Δευτέρα" "Τρίτη" "Τετάρτη"
                               "Πέμπτη" "Παρασκευή" "Σάββατο"]
      calendar-month-name-array ["Ιανουάριος" "Φεβρουάριος" "Μάρτιος"
                                 "Απρίλιος" "Μάιος" "Ιούνιος"
                                 "Ιούλιος" "Αύγουστος" "Σεπτέμβριος"
                                 "Οκτώβριος" "Νοέμβριος" "Δεκέμβριος"])

;; Time display
(setq display-time-format "%H:%M %Y-%m-%d"
      display-time-day-and-date t
      display-time-24hr-format t
      display-time-default-load-average nil)
(display-time-mode 0)

;;; Performance Optimization

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


;; Disable Bidirectional Text Scanning
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

;; Skip Fontification During Input
(setq redisplay-skip-fontification-on-input t)

;; Increase Process Output Buffer for LSP
(setq read-process-output-max (* 4 1024 1024)) ; 4MB

;; Save the Clipboard Before Killing
(setq save-interprogram-paste-before-kill t)

;; No Duplicates in the Kill Ring
(setq kill-do-not-save-duplicates t)

;; Proportional Window Resizing
(setq window-combination-resize nil)

;; Faster Mark Popping
(setq set-mark-command-repeat-pop t)

;;; Package System & use-package Setup

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

(use-package org :load-path "~/.config/emacs/elpa/org-mode/lisp/")

;;; Core UI Settings

(setq initial-major-mode #'org-mode)

;; ;; Disable startup screen
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t)

;; Maximize frame
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Disable unnecessary UI elements
(tool-bar-mode -1)
(tooltip-mode 1)
(menu-bar-mode 1)
(scroll-bar-mode -1)
(blink-cursor-mode 1)

;; Better defaults
(setq-default cursor-type 'box
              ring-bell-function #'ignore
              use-dialog-box nil
              use-file-dialog nil
              pop-up-windows t
              delete-by-moving-to-trash t
              line-number-mode nil
              column-number-mode nil
              fringe-indicator-alist nil)


(fringe-mode '(1 . 1))  ;; minimal fringes on both sides
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

(setq initial-scratch-message nil)
(global-set-key (kbd "C-x x s") #'scratch-buffer)

;; Hide minor modes in modeline
(setq-default mode-line-format '("%e" mode-line-front-space
                                 (:propertize
                                  ("" mode-line-mule-info mode-line-client mode-line-modified mode-line-remote)
                                  display
                                  (min-width
                                   (0.0)))
                                 mode-line-frame-identification
                                 mode-line-buffer-identification
                                 (vc-mode vc-mode)
                                 "  "
                                 mode-line-position
                                 "  "
                                 "  "
                                 mode-name
                                 "  "
                                 mode-line-misc-info
                                 mode-line-end-spaces))

;; Will work in Emacs versions >= 31
;; (setq mode-line-collapse-minor-modes '(not))

;;; Scrolling and Navigation

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

;;; File Handling

;; Disable backup and auto-save files
(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil)

(auto-save-visited-mode 1)

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
  (save-place-mode 1)
  :custom
  (save-place-limit 50))

;; Bookmarks
(setq bookmark-save-flag 1
      bookmark-default-file "~/Documents/03-Resources/Emacs/bookmarks")

(savehist-mode 1)

;;; Editing Behavior

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

;;; Fonts

(defun set-font-faces ()
  "Set font faces for different contexts."
  (message "Setting font faces...")
  (when (find-font (font-spec :name "Noto Color Emoji"))
    (set-fontset-font t 'symbol (font-spec :family "Noto Color Emoji" :size 24)))
  (when (find-font (font-spec :name "Iosevka"))
    (set-face-attribute 'default nil :family "Iosevka" :height 110)
    (set-face-attribute 'fixed-pitch nil :family "Iosevka" :height 110))
  (when (find-font (font-spec :name "Iosevka Aile"))
    (set-face-attribute 'variable-pitch nil :family "Iosevka Aile" :height 110)))

(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame
                  (set-font-faces))))
  (set-font-faces))

;;; Buffers

(with-eval-after-load 'quail (defun quail-completion ()))

(setq-default message-log-max nil
              quail-completion-max-depth nil)
;; (kill-buffer "*Messages*")
(with-eval-after-load 'quail (defun quail-completion ()))

(winner-mode 1)

;;; Key Bindings

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
  ;; (balance-windows)
  (other-window 1))

(defun split-and-follow-horizontally ()
  "Split window horizontally and follow to new window."
  (interactive)
  (split-window-below)
  ;; (balance-windows)
  (other-window 1))

(global-set-key (kbd "C-x 3") #'split-and-follow-vertically)
(global-set-key (kbd "C-x 2") #'split-and-follow-horizontally)

;; ;;resizing windows
;; (global-set-key (kbd "C-<left>") 'shrink-window-horizontally)
;; (global-set-key (kbd "C-<right>") 'enlarge-window-horizontally)
;; (global-set-key (kbd "C-<up>") 'enlarge-window)
;; (global-set-key (kbd "C-<down>") 'shrink-window)

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

;; Compilation
(define-key global-map (kbd "C-c p c") 'compile)

;; Move lines
(defun move-line-up ()
  "Move up the current line."
  (interactive)
  (transpose-lines 1)
  (forward-line -2)
  (indent-according-to-mode))

(defun move-line-down ()
  "Move down the current line."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key (kbd "M-<up>")  #'move-line-up)
(global-set-key (kbd "M-<down>")  #'move-line-down)

;;; Spell Checking

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

;;; Theme and Appearance

(use-package standard-themes
  :ensure t
  :config
  (setq standard-themes-to-toggle '(standard-light standard-dark))
  (define-key global-map (kbd "<f5>") #'standard-themes-toggle)

  (load-theme 'standard-light t))

;; (use-package modus-themes
;;   :ensure t
;;   :init
;;   :config
;;   (setq

;;    ;; modus-themes-headings
;;    ;;      '((1 . (1.2))
;;    ;;        (2 . (1.15))
;;    ;;        (3 . (1.1))
;;    ;;        (4 . (1.05))
;;    ;;        (t . (1.0)))

;;    modus-themes-italic-constructs nil
;;    modus-themes-bold-constructs t
;;    modus-themes-mixed-fonts t
;;    modus-themes-subtle-line-numbers t
;;    modus-themes-fringes nil ; {nil,'subtle,'intense}

;;    ;; mode-line settings
;;    modus-themes-common-palette-overrides
;;    '(
;;      ;;   ;;   ;; make border same color (e.g. borderless)
;;      ;;   ;;   ;; (border-mode-line-active bg-mode-line-active)
;;      ;;   ;;   ;; (border-mode-line-inactive bg-mode-line-inactive)
;;      ;;   ;;   ;; make active window's mode-line purple
;;      ;;   ;;   (bg-mode-line-active bg-lavender)
;;      ;;   ;;   (fg-mode-line-active fg-main)
;;      ;;   ;;   (border-mode-line-active bg-magenta-intense)

;;      (comment fg-alt)

;;      ;; Make line numbers less intense
;;      (fg-line-number-inactive "gray50")
;;      (fg-line-number-active fg-main)
;;      (bg-line-number-inactive unspecified)
;;      (bg-line-number-active unspecified)
;;      ))
;;   (setq modus-themes-to-toggle '(modus-operandi modus-vivendi))
;;   (define-key global-map (kbd "<f5>") #'modus-themes-toggle)
;;   (modus-themes-load-theme 'modus-operandi))

;;; Files

(use-package autorevert)
(global-auto-revert-mode)
(setq auto-revert-use-notify t)
(setq auto-revert-avoid-polling t)

;;; Essential Packages

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
  ;; :config
  ;; (vundo-popup-mode)
  )

(use-package dashboard
  :custom
  (dashboard-startup-banner '(official))
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-startupify-list '(dashboard-insert-banner
                               ;; dashboard-insert-newline
                               ;; dashboard-insert-items
                               ))
  (dashboard-items '((registers    . 10)))
  :config
  (dashboard-setup-startup-hook)
  (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*"))))

;;; Completion Framework

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

;;; Project Management

(use-package project
  :ensure nil
  :custom
  (project-vc-extra-root-markers '(".envrc" ".project" ".git")))

;;; Direnv

(use-package direnv
  :custom
  (direnv-always-show-summary nil))

;;; Programming

(use-package eldoc-box
  ;; :config
  ;; (with-eval-after-load 'eglot
  ;;   (add-hook 'eglot-managed-mode-hook #'eldoc-box-hover-mode nil))
  )
(add-hook 'eldoc-box-buffer-setup-hook #'eldoc-box-prettify-ts-errors 0 t)

(use-package comment-tags
  :custom
  (comment-tags-require-colon nil)
  :hook
  (prog-mode . comment-tags-mode))

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
  ;; :custom
  ;; (eglot-ignored-server-capabilities '(:inlayHintProvider))
  :bind
  (("C-c C-q" . eglot-code-actions))
  :config
  (add-to-list 'eglot-server-programs
               '(python-base-mode . ("basedpyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(solidity-mode . ("nomicfoundation-solidity-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((js-ts-mode typescript-ts-mode tsx-ts-mode)
                 . ("bunx" "typescript-language-server" "--stdio"))))

;; Python
(add-hook 'python-base-mode-hook 'direnv-mode)
(add-hook 'python-mode-hook '(lambda () (set (make-local-variable 'yas-indent-line) 'fixed)))

;; TypeScript/JavaScript

(use-package typescript-mode)

(add-to-list 'exec-path "~/.bun/bin")
(setenv "PATH" (concat "~/.bun/bin:" (getenv "PATH")))

(use-package jsdoc)

;; Yaml
(use-package yaml-mode)

;; Rust
(use-package rust-mode)
;; (add-hook 'rust-mode-hook 'eglot-ensure)
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((rust-ts-mode rust-mode) .
                 ("rust-analyzer" :initializationOptions (:check (:command "clippy"))))))

;; Solidity

(use-package solidity-mode)

(with-eval-after-load 'apheleia
  (setf (alist-get 'forge-fmt apheleia-formatters)
        '("forge" "fmt" "--raw" "-"))
  (setf (alist-get 'solidity-mode apheleia-mode-alist) 'forge-fmt))

;; Lean4

(use-package nael)

;; Datalog

(require 'souffle-mode)

;; Formatting
(use-package apheleia
  :config
  ;; Replace default (black) to use ruff for sorting import and formatting.
  (setf (alist-get 'python-mode apheleia-mode-alist)
        '(ruff-isort ruff))
  (setf (alist-get 'python-ts-mode apheleia-mode-alist)
        '(ruff-isort ruff))
  (apheleia-global-mode))

;; Programming mode hooks
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
(add-hook 'prog-mode-hook #'hl-line-mode)
(add-hook 'prog-mode-hook #'flyspell-prog-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Docs
(use-package devdocs)

;;; Outline-mode

(setq outline-minor-mode-cycle t)

;;; Searching

(use-package rg)

;; https://github.com/dajva/rg.el/issues/132
(defun hrm-rg-mode-hook ()
  "My rg-mode-hook.  Setup outline-minor-mode."
  (setq-local outline-regexp "File:")
  (outline-minor-mode 1))

(add-hook 'rg-mode-hook #'hrm-rg-mode-hook)

;;; Terminal

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

;;; Writing and Note-taking

(use-package centered-cursor-mode)

(use-package olivetti
  :custom
  (olivetti-body-width 130))

(use-package mixed-pitch)

(use-package darkroom
  :hook ((darkroom-mode . mixed-pitch-mode))
  :custom
  (darkroom-text-scale-increase 0))

(defun my/mixed-pitch-cursor-fix ()
  "Fix cursor type in mixed-pitch mode."
  (setq-local cursor-type 'box))

(add-hook 'mixed-pitch-mode-hook #'my/mixed-pitch-cursor-fix)

;; Text mode setup
(defun my-prose-setup ()
  "Setup for prose writing."
  (visual-line-mode 1)
  (variable-pitch-mode 1)
  (setq truncate-lines nil
        line-spacing 0.2 ; Slightly increased for better readability
        ))

(add-hook 'org-mode-hook #'my-prose-setup)
(add-hook 'markdown-mode-hook #'my-prose-setup)

;;; Markdown
(use-package markdown-ts-mode)

(use-package markdown-mode
  :mode ("\\.md\\'" "\\.qmd\\'")
  :hook ((markdown-mode . olivetti-mode)
         (markdown-mode . save-place-local-mode)
         (Info-mode . olivetti-mode)
         ;; (markdown-mode . flyspell-mode)
         (markdown-mode . my/markdown-highlight-tags))
  :bind
  (("C-c C-x @" . citar-insert-citation))
  :custom
  (markdown-enable-math t)
  (markdown-command "pandoc --katex -s")
  (markdown-max-image-size '(800 . 600))
  (markdown-asymmetric-header t)
  (markdown-fontify-code-blocks-natively t)
  (markdown-enable-highlighting-syntax t)
  (markdown-enable-wiki-links t)
  (markdown-unordered-list-item-prefix "- ")
  (markdown-wiki-link-alias-first nil))

(setq-default markdown-hide-markup t)

;; Markdown customizations
(with-eval-after-load 'markdown-mode
  ;; Highlight pandoc-style citations
  (font-lock-add-keywords 'markdown-mode
                          '(("\\(@[^][:space:]]+\\)" 1 font-lock-keyword-face)))

  ;; Tag highlighting
  (defface my/tag-face
    '((t :foreground "#6c7086"))
    "Face for tags like #inbox or #projects/name.")

  (defun my/markdown-highlight-tags ()
    "Highlight tags in markdown mode."
    (font-lock-add-keywords
     nil
     '(("\\(#+[A-Za-zΑ-Ωα-ωΆ-Ώά-ώ][A-Za-zΑ-Ωα-ωΆ-Ώά-ώ0-9_/\\-]*\\)" 1 'my/tag-face))))

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

;;; Bibliography and Citations

(defvar org-cite-csl--fallback-locales-dir "~/Library/Zotero data/styles/")

(use-package citar
  :after org
  :custom
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  (citar-bibliography org-cite-global-bibliography)

  (citar-bibliography '("~/Library/References/biblio.bib"))
  (citar-citeproc-csl-style "IEEE")
  (citar-format-reference-function 'citar-citeproc-format-reference)
  (citar-markdown-prompt-for-extra-arguments nil)
  (citar-file-open-functions '(("html" . citar-file-open-external)
                               ;; ("pdf" . citar-file-open-external)
                               (t . find-file)))
  (citar-open-entry-function #'citar-open-entry-in-zotero)
  (citar-citeproc-csl-styles-dir "~/Library/Zotero data/styles/")
  :hook
  (markdown-mode . citar-capf-setup))

(use-package citar-embark
  :after citar embark
  :no-require
  :config (citar-embark-mode))

;;; PDF handling

(use-package doc-view
  :ensure nil
  :custom
  (doc-view-dvipdfm-program "mutool")
  (doc-view-continuous t))

;;; Zettelkasten (ZK)

(define-prefix-command 'zk-map)
(global-set-key (kbd "C-z") 'zk-map)

(use-package zk
  :init
  (add-hook 'completion-at-point-functions #'zk-completion-at-point 'append)

  (defun my/zk-new-note-header (title new-id &optional orig-id)
    "Insert header in new notes with TITLE and NEW-ID."
    (insert (format "* %s %s\n\n" new-id title)))

  (defun my/zk-copy-current-id ()
    "Call `zk--current-id` and copy its result to the clipboard."
    (interactive)
    (let ((id (zk--current-id)))
      (kill-new id)
      (message "Copied zk id: %s" id)))
  :bind
  (:map zk-map
        ("f" . zk-find-file)
        ("g" . zk-grep)
        ("F" . zk-find-file-by-full-text-search)
        ("B" . zk-backlinks)
        ("l" . zk-links-in-note)
        ("t" . zk-tag-insert)
        ("T" . zk-tag-search)
        ("r" . zk-rename-note)
        ("R" . zk-random-note)
        ("w" . zk-new-note)
        ("n" . zk-network)
        ("G" . zk-graph)
        ("N" . citar-open-notes)
        ("i" . zk-insert-link)
        ("b" . zk-current-notes)
        ("I" . zk-index)
        ("c" . my/zk-copy-current-id)
        ("o" . zk-follow-link-at-point))
  :custom
  (zk-new-note-header-function 'my/zk-new-note-header)
  (zk-directory "~/Documents/03-Resources/Slipbox/")
  (zk-file-extension "org")
  (zk-id-time-string-format "%Y%m%d%H%M%S")
  (zk-id-regexp "\\([0-9]\\{14\\}\\)")
  (zk-tag-regexp "\\s#\\+[0-9A-Za-zΑ-Ωα-ωΆ-Ώά-ώ_/\\-][A-Za-zΑ-Ωα-ωΆ-Ώά-ώ0-9_/\\-]*")
  (zk-new-note-link-insert 'ask)
  (zk-link-and-title 'ask)
  :config
  (zk-setup-auto-link-buttons)
  (zk-setup-embark)
  (defun zk-org-try-to-follow-link (fn &optional arg)
    "When 'org-open-at-point' FN fails, try 'zk-follow-link-at-point'.
    Optional ARG."
    (let ((org-link-search-must-match-exact-headline t))
      (condition-case nil
          (apply fn arg)
        (error (zk-follow-link-at-point)))))
  (advice-add 'org-open-at-point :around #'zk-org-try-to-follow-link)

  (defun zk-graph ()
    "Generate a Zettelkasten graph for the current file."
    (interactive)
    (unless buffer-file-name
      (error "Current buffer is not visiting a file"))

    (let* ((zettel (file-name-nondirectory buffer-file-name))
           ;; Unique temp files
           (dot (make-temp-file "zk-graph-" nil ".dot"))
           (svg (make-temp-file "zk-graph-" nil ".svg"))
           ;; Where your script lives/should run from (edit if needed)
           (default-directory zk-directory))

      (unwind-protect
          (progn
            ;; 1) Run: ruby extract_associated_zettel.rb <zettel>  -> dot file
            (with-temp-file dot
              (let ((exit (process-file "ruby" nil (current-buffer) nil
                                        "extract_associated_zettel.rb" zettel)))
                (unless (and (integerp exit) (zerop exit))
                  (error "ruby script failed (exit %S). See %s" exit dot))))

            ;; 2) Run: neato -Tsvg -o <svg> <dot>
            (let ((exit (process-file "neato" nil nil nil
                                      "-T" "svg" "-o" svg dot)))
              (unless (and (integerp exit) (zerop exit))
                (error "neato failed (exit %S)" exit)))

            (message "Wrote graph: %s" svg)

            ;; 3) Open it (platform-aware)
            (cond
             ((eq system-type 'darwin)
              (start-process "zk-graph-open" nil "open" svg))
             ((memq system-type '(gnu/linux linux))
              (start-process "zk-graph-open" nil "xdg-open" svg))
             ((eq system-type 'windows-nt)
              (w32-shell-execute "open" svg))
             (t
              ;; Fallback: open in Emacs
              (find-file svg))))

        ;; Clean up the intermediate dot file; keep the svg.
        (when (and dot (file-exists-p dot))
          (ignore-errors (delete-file dot))))))

  (defun zk-random-note ()
    "Open a random .org file from `zk-directory`."
    (interactive)
    (let* ((files (directory-files zk-directory t "\\.org$"))
           (n (length files)))
      (if (zerop n)
          (user-error "No .org files found in %s" zk-directory)
        (find-file (nth (random n) files))))))

(use-package zk-index
  :after zk
  :custom
  (zk-index-view-hide-cursor nil)
  (zk-index-invisible-ids nil)
  :config
  (zk-index-setup-embark))

(defvar zk-index-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "n") #'zk-index-next-line)
    (define-key map (kbd "p") #'zk-index-previous-line)
    (define-key map (kbd "v") #'zk-index-view-note)
    (define-key map (kbd "o") #'other-window)
    (define-key map (kbd "f") #'zk-index-focus)
    (define-key map (kbd "s") #'zk-index-search)
    (define-key map (kbd "g") #'zk-index-query-refresh)
    (define-key map (kbd "c") #'zk-index-current-notes)
    (define-key map (kbd "i") #'zk-index-refresh)
    (define-key map (kbd "I") #'zk-index-insert-link)
    (define-key map (kbd "S") #'zk-index-sort-size)
    (define-key map (kbd "M") #'zk-index-sort-modified)
    (define-key map (kbd "C") #'zk-index-sort-created)
    (define-key map (kbd "RET") #'zk-index-open-note)
    (define-key map (kbd "q") #'delete-window)
    (make-composed-keymap map tabulated-list-mode-map))
  "Keymap for ZK-Index buffer.")

(use-package zk-desktop
  :after zk-index
  :config
  (zk-desktop-setup-embark)
  :init
  (setq zk-desktop-directory zk-directory)
  (setq zk-desktop-invisible-ids nil)
  (setq zk-desktop-basename "ZK-Desktop:")
  (setq zk-desktop-major-mode 'org-mode))

;; ZK-Citar integration
(with-eval-after-load 'citar
  (with-eval-after-load 'zk
    (require 'zk-citar)
    (setq citar-notes-source 'zk
          zk-citar-citekey-regexp "^[0-9]+[[:space:]]+L1[[:space:]]+\\(\\S-+\\)[[:space:]]+-.*"
          zk-citar-title-template "L1 ${=key=} - ${title}")))

;;; LaTeX

(use-package cdlatex
  :hook ((latex-mode . cdlatex-mode)
         (LaTeX-mode . cdlatex-mode)))

(setq cdlatex-math-symbol-alist '((93 ("\\Rightarrow" "\\implies"))))

;;; Math rendering

(use-package math-preview
  ;; :hook ((markdown-mode . math-preview-all))
  :custom
  (math-preview-mathjax-tags "ams"))

(advice-add #'math-preview-all :before (lambda () (math-preview-reset-numbering 1)))

;;; Org-Mode

;; (package-vc-install '(org-mode :url "https://code.tecosaur.net/tec/org-mode" :branch "dev"))
(use-package org :load-path "~/.config/emacs/elpa/org-mode/lisp/"
  :hook ((org-mode . olivetti-mode)
         (org-mode . my/markdown-highlight-tags)
         (org-mode . save-place-local-mode)
         ;; (org-mode . flyspell-mode)
         (org-mode . org-cdlatex-mode))
  :config
  (setq org-image-actual-width (list 0.5)
        org-export-with-broken-links 'mark
        org-image-align 'center
        org-ellipsis "…"
        org-startup-indented t
        org-indent-mode-turns-on-hiding-stars nil
        org-startup-numerated nil
        org-pretty-entities nil
        org-level-color-stars-only t
        org-export-with-sub-superscripts nil
        org-tags-column 0
        org-footnote-auto-adjust t
        org-support-shift-select t
        org-startup-with-inline-images t
        org-display-remote-inline-images 'download
        org-fontify-quote-and-verse-blocks nil
        org-link-file-path-type 'relative
        org-use-speed-commands t
        org-footnote-section "Footnotes"
        org-list-demote-modify-bullet '(("-" . "+") ("+" . "-")  ("*" . "-"))
        org-link-descriptive nil
        org-return-follows-link nil)

  ;; Attachments handling
  (setq org-yank-image-save-method "./Attachments/"
        org-yank-dnd-method 'ask
        org-attach-id-dir ".data/"
        org-attach-method 'lns
        org-attach-auto-tag nil)

  ;; Spacing
  (setq org-blank-before-new-entry '((heading . auto) (plain-list-item . auto)))

  (setq org-highlight-latex-and-related '(latex entities))

  ;; Export options
  (setq org-cite-csl-styles-dir "~/Library/Zotero data/styles/"
        org-export-with-toc nil
        org-html-checkbox-type 'html
        org-html-postamble nil
        org-export-with-broken-links 'mark
        org-export-with-section-numbers nil
        org-export-with-smart-quotes t
        org-cite-csl-link-cites t
        org-cite-export-processors '((latex . (csl "ieee.csl" "ieee.csl")) (t . (csl "ieee.csl" "ieee.csl")))
        org-cite-global-bibliography '("~/Library/References/biblio.bib")
        org-html-toplevel-hlevel 1
        org-html-footnotes-section
        "<div id=\"footnotes\">
<hr/>
<h2 class=\"footnotes\">%s </h2>
<div id=\"text-footnotes\">
%s
</div>
</div>"

        ))

(require 'ox-beamer)
;; (setq org-beamer-frame-default-options "allowframebreaks")

(use-package oc-csl
  :ensure nil)

(add-hook 'org-mode-hook
          (lambda ()
            ;; (setq-local electric-pair-pairs '((?* . ?*) (?/ . ?/) (?+ . ?+) (?~ . ?~)))
            (setq-local electric-pair-text-pairs electric-pair-pairs)))

(require 'org-protocol)

(global-set-key (kbd "C-c l") #'org-store-link)

;;;; Agenda/GTD

;; (setq org-directory "~/Documents/03-Resources/Agenda")

(setq org-todo-keywords
      '((sequence "RUNNING(r)" "NEXT(n)" "TODO(t)" "PROJ(p)" "IDEA(i)" "MAYBE(m)" "WAIT(w)" "|" "DONE(d!)" "CANC(c)")))

(setq org-stuck-projects '("/+PROJ-MAYBE-DONE" ("NEXT" "RUNNING") nil "SCHEDULED:"))

(global-set-key (kbd "C-c a") #'org-agenda)
(setq org-agenda-files '("~/Documents/01-Projects/Projects.org"
                         "~/Documents/02-Areas/Areas.org"
                         "~/Documents/00-Inbox/Inbox.org"))

(setq org-log-done 'time
      org-agenda-current-time-string "← Now ─────────────────────────────────────────────────────────"
      org-archive-location "%s_archive::"
      org-lowest-priority ?C
      org-default-priority ?B
      org-agenda-block-separator 9472
      org-agenda-tags-column 'auto
      org-agenda-hide-tags-regexp "noexport\\|ignore"
      org-agenda-use-time-grid nil
      org-agenda-start-with-log-mode nil
      org-agenda-log-mode-items '(clock)
      org-log-into-drawer t
      org-log-state-notes-insert-after-drawers t
      org-agenda-include-deadlines t
      org-agenda-todo-ignore-scheduled 'all
      org-agenda-skip-deadline-prewarning-if-scheduled 2
      org-agenda-skip-scheduled-if-deadline-is-shown 'not-today
      org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-skip-timestamp-if-done t
      org-agenda-span 'day
      org-agenda-remove-tags nil
      ;; org-agenda-scheduled-leaders '("[S]: " "[S] %2d days ago: ")
      ;; org-agenda-deadline-leaders '("[D]: " "[D] in %2d days: " "[D] %2d days ago: ")
      org-agenda-deadline-faces '((0.9 . org-imminent-deadline) (0.7 . org-upcoming-deadline)
                                  (0.0 . org-upcoming-distant-deadline))
      org-habit-graph-column 46
      org-extend-today-until 4
      org-sort-agenda-notime-is-late nil
      org-agenda-entry-text-leaders "    "
      org-use-property-inheritance '( "ID")
      )

(setf (cdr (assoc 'note org-log-note-headings)) "%t")

(setq org-agenda-sorting-strategy
      '(habit-down deadline-up time-up todo-state-up priority-down effort-up category-keep))


(setq org-agenda-breadcrumbs-separator " ➤ "
      org-agenda-prefix-format '((agenda . " %-18:c%?-12t% s")
                                 (timeline . "  % s")
                                 (todo ." %-18:c")
                                 (tags . " %-18:c")
                                 (search . " %-18:c")))

(setq org-agenda-custom-commands
      '(("A" "Running, Next Actions"
         ((todo "RUNNING" ((org-agenda-overriding-header "Running tasks")))
          (todo "NEXT" ((org-agenda-overriding-header "Next actions")))) nil)
        ("W" "Waiting on"
         ((todo "WAIT" ((org-agenda-overriding-header "Waiting on")))) nil)
        ("P" "Projects"
         ((todo "PROJ" ((org-agenda-overriding-header "Projects")))) nil)))

(defun my/set-org-todo-faces ()
  "Set Org TODO keyword faces using modus-themes colors."
  (modus-themes-with-colors
    (setq org-todo-keyword-faces
          `(("TODO" . (:foreground ,red-faint
                                   :weight bold))
            ("NEXT" . (:foreground ,yellow
                                   :weight bold))
            ("RUNNING" . (:foreground ,red
                                      :weight bold))
            ("WAIT" . (:foreground ,fg-dim
                                   :weight bold))
            ("IDEA" . (:foreground ,magenta-warmer
                                   :weight bold))
            ("PROJ" . (:foreground ,magenta-cooler
                                   :weight bold))
            ("MAYBE" . (:foreground ,fg-dim
                                    :weight bold))
            ("DONE" . (:foreground ,green
                                   :weight bold))
            ("CANC" . (:foreground ,fg-dim
                                   :weight bold)))))

  (setq org-fontify-done-headline nil)

  ;; Refresh org TODO faces in all org buffers
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (derived-mode-p 'org-mode)
        (org-mode-restart)))))
;; Call the function to initialize TODO faces
(my/set-org-todo-faces)
;; Add hooks to run the function on theme change
(add-hook 'modus-themes-after-load-theme-hook 'my/set-org-todo-faces)

;;;;; Calendar/Diary

(setq ; org-agenda-diary-file "~/Documents/03-Resources/Agenda/Calendar.org"
 org-agenda-insert-diary-strategy 'date-tree
 org-agenda-include-diary nil
 holiday-hebrew-holidays nil
 holiday-islamic-holidays nil
 holiday-bahai-holidays nil
 holiday-oriental-holidays nil
 calendar-christian-all-holidays-flag t)

(setq-default calendar-date-style 'iso)

;;;;; Appointments

(setq appt-time-msg-list nil
      appt-message-warning-time '10       ;; warn 10 min in advance
      appt-display-diary nil              ;; do not display diary when (appt-activate) is called
      appt-display-mode-line t            ;; show in the modeline
      appt-display-format 'window         ;; display notification in window
      appt-audible t
      calendar-mark-diary-entries-flag nil) ;; mark diary entries in calendar
(add-hook 'org-agenda-finalize-hook
          (lambda ()
            (org-agenda-to-appt)          ;; copy all agenda schedule to appointments
            (appt-activate 1)))           ;; active appt (appointment notification)

;;;; Capture

(global-set-key (kbd "C-c c") #'org-capture)
(setq org-capture-templates
      `(("i" "Inbox" entry (file "~/Documents/00-Inbox/Inbox.org")
         "* %?" :prepend t :empty-lines 0)
        ;; ("s" "Slipbox" entry (file "~/Documents/03-Resources/Slipbox/Slipbox.org")
        ;;  "* %?" :prepend t :empty-lines 1)
        ;; ("t" "Task" entry (file "Agenda.org")
        ;;  "* TODO %?" :prepend t :empty-lines 1)
        ;; ("j" "Journal" entry (file+datetree "Journal.org")
        ;;  "\n* %<%H:%M>\n\n%?" :empty-lines 1
        ;;  :tree-type (year month week day))
        ;; ("e" "Event" entry (file "Calendar.org")
        ;;  "* %?\n%^t" :time-prompt t :empty-lines 1)
        ;; ("x" "org-protocol-capture" entry (file "~/Documents/00-Inbox/Inbox.org")
        ;;  "* [[%:link][%:description]] %i"
        ;;  :prepend t
        ;;  :immediate-finish t
        ;;  :empty-lines 1)
        ))

;;;; Refile

(setq org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil
      org-refile-targets '((org-agenda-files :maxlevel . 3)))

;;;; Clocking

(setq org-clock-mode-line-total 'auto)

;;;; LaTeX previews

(use-package org-latex-preview
  :ensure nil
  :config
  (plist-put org-format-latex-options :zoom 1.4)
  (plist-put org-format-latex-options :page-width 0.8)

  (add-hook 'org-mode-hook 'org-latex-preview-auto-mode)

  ;; Enable consistent equation numbering
  (setq org-latex-preview-numbered t)

  ;; Bonus: Turn on live previews.  This shows you a live preview of a LaTeX
  ;; fragment and updates the preview in real-time as you edit it.
  ;; To preview only environments, set it to '(block edit-special) instead
  (setq org-latex-preview-live t)

  (setq org-startup-with-latex-preview t)

  ;; More immediate live-previews -- the default delay is 1 second
  (setq org-latex-preview-live-debounce 0.25))

;;;; Zotero integration

;; Open =zotero://= links from org buffers.
(defun org-zotero-open (path)
  (browse-url-xdg-open (format "zotero:%s" path)))

(with-eval-after-load 'org
  (org-link-set-parameters "zotero" :follow #'org-zotero-open))

;;;; Visual improvements

;; (use-package valign
;;   :custom
;;   (valign-fancy-bar t))
;; (add-hook 'org-mode-hook #'valign-mode)

;; (use-package org-modern
;;   :custom
;;   (org-modern-star 'replace)
;;   (org-modern-table nil))

;; (with-eval-after-load 'org (global-org-modern-mode))

;; (defun my/set-org-modern-todo-faces ()
;;   "Set org-modern TODO keyword faces using modus-themes colors."
;;   (modus-themes-with-colors
;;     (setq org-modern-todo-faces
;;           `(("TODO" :background ,bg-red-intense
;;              :foreground ,fg-main
;;              :weight bold)
;;             ("NEXT" :background ,bg-yellow-intense
;;              :foreground ,fg-main
;;              :weight bold)
;;             ("IN PROGRESS" :background ,bg-red-subtle
;;              :foreground ,fg-main
;;              :weight bold)
;;             ("ON HOLD" :background ,bg-blue-intense
;;              :foreground ,fg-main
;;              :weight bold)
;;             ("PROJ" :background ,bg-magenta-intense
;;              :foreground ,fg-main
;;              :weight bold)
;;             ("COURSE" :background ,bg-cyan-intense
;;              :foreground ,fg-main
;;              :weight bold)
;;             ("MAYBE" :background ,bg-inactive
;;              :foreground ,fg-main
;;              :weight bold)
;;             ("IDEA" :background ,bg-magenta-intense
;;              :foreground ,fg-main
;;              :weight bold)
;;             ("DONE" :background ,bg-green-intense
;;              :foreground ,fg-main
;;              :weight bold)
;;             ("CANC" :background ,bg-dim
;;              :foreground ,fg-dim
;;              :weight bold)))

;;     (setq org-fontify-done-headline nil)

;;     ;; Configure strike-through for CANC headlines
;;     ;; (setq org-fontify-done-headline t)

;;     ;; Set the face for CANC headlines to include strike-through
;;     ;; (set-face-attribute 'org-headline-done nil :strike-through t)

;;     ;; Refresh org-modern in all org buffers
;;     (dolist (buf (buffer-list))
;;       (with-current-buffer buf
;;         (when (and (derived-mode-p 'org-mode)
;;                    (bound-and-true-p org-modern-mode))
;;           (org-modern-mode -1)
;;           (org-modern-mode 1))))))

;; (add-hook 'modus-themes-after-load-theme-hook #'my/set-org-modern-todo-faces)
;; (my/set-org-modern-todo-faces)

;; (use-package org-appear
;;   :custom
;;   (org-hide-emphasis-markers t)
;;   (org-appear-trigger 'always)
;;   (org-appear-autoemphasis t)
;;   (org-appear-autolinks t)
;;   (org-appear-autoentities t)
;;   (org-appear-autokeywords t))

;; (add-hook 'org-mode-hook 'org-appear-mode)

;;;; Exporting

(require 'org-colored-text)

;; Taken and adapted from org-colored-text
(org-add-link-type
 "color"
 (lambda (path)
   "No follow action.")
 (lambda (color description backend)
   (cond
    ((eq backend 'latex)                  ; added by TL
     (format "{\\color{%s}%s}" color description)) ; added by TL
    ((eq backend 'html)
     (let ((rgb (assoc color color-name-rgb-alist))
           r g b)
       (if rgb
           (progn
             (setq r (* 255 (/ (nth 1 rgb) 65535.0))
                   g (* 255 (/ (nth 2 rgb) 65535.0))
                   b (* 255 (/ (nth 3 rgb) 65535.0)))
             (format "<span style=\"color: rgb(%s,%s,%s)\">%s</span>"
                     (truncate r) (truncate g) (truncate b)
                     (or description color)))
         (format "No Color RGB for %s" color)))))))

(use-package org-contrib)
(require 'ox-extra)
(ox-extras-activate '(ignore-headlines))

;; LaTeX export
(add-to-list 'org-latex-classes
             '("koma-article" "\\documentclass[paper=a4, parskip=full]{scrartcl}"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
(add-to-list 'org-latex-classes
             '("extarticle" "\\documentclass{extarticle}"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

(setq org-latex-tables-booktabs t
      org-latex-with-hyperref
      "\\hypersetup{
         pdfencoding=auto,
         psdextra,
         pdfauthor={%a},
         pdftitle={%t},
         pdfkeywords={%k},
         pdfsubject={%d},
         pdfcreator={%c},
         pdflang={%L},
         colorlinks=false,
         linkcolor={purple},
         filecolor={cyan},
         citecolor={red},
         urlcolor={blue}}
"

      org-latex-pdf-process '("latexmk -f -pdf -%latex -shell-escape -interaction=nonstopmode -output-directory=%o %f")
      org-latex-src-block-backend 'minted
      org-latex-image-default-width ".75\\linewidth"
      org-export-with-section-numbers nil
      org-export-with-toc nil
      org-export-with-date nil
      org-export-with-title nil
      org-export-with-author nil
      org-export-with-planning nil          ;; corresponds to p:nil in many setups
      org-export-with-todo-keywords nil
      org-export-headline-levels 6
      org-export-with-statistics-cookies nil
      org-export-default-language "el"
      org-latex-default-class "koma-article")

(with-eval-after-load 'ox-latex
  ;; Needed for polyglossia/unicode-math font setup
  (setq org-latex-compiler "xelatex")

  ;; Add packages (after org-latex-default-packages-alist) + raw header strings.
  ;; (setq org-latex-packages-alist
  ;;       '(
  ;;         ;; --- Packages
  ;;         ("english,AUTO" "polyglossia" nil ("lualatex" "xetex"))
  ;;         ("margin=1.4in" "geometry")
  ;;         ("" "microtype")
  ;;         ("" "amssymb")
  ;;         ("" "amsmath")
  ;;         ("" "unicode-math" nil ("lualatex" "xetex"))

  ;;         ("" "longtable")
  ;;         ("" "booktabs")
  ;;         ("" "array")
  ;;         ("" "colortbl")

  ;;         ("newfloat,cache=false" "minted" nil ("lualatex" "xetex" "pdflatex"))
  ;;         ("font={footnotesize},margin=1cm,labelfont=bf" "caption")

  ;;         ("" "amsthm")
  ;;         ("ruled,vlined,linesnumbered" "algorithm2e")

  ;;         "\\setmainfont[Ligatures=TeX]{Libertinus Serif}"
  ;;         "\\setsansfont[Scale=MatchUppercase]{Lato}"
  ;;         "\\setmathfont{Libertinus Math}"
  ;;         "\\setmonofont[Scale=MatchLowercase]{Iosevka}"

  ;;         "\\setminted{frame=single,framesep=2mm,linenos,breaklines,numbersep=0.5em,fontsize=\\footnotesize}"

  ;;         "\\newtheorem{theorem}{Θεώρημα}"
  ;;         "\\newtheorem{lemma}{Λήμμα}"

  ;;         "\\let\\oldquote\\quote"
  ;;         "\\let\\endoldquote\\endquote"
  ;;         "\\renewenvironment{quote}{\\oldquote\\itshape}{\\endoldquote}"

  ;;         "\\SetAlgorithmName{Αλγόριθμος}{Λίστα αλγορίθμων}"
  ;;         ))
  )

;;;; Org-Babel

(require 'ob-lean4)
(add-to-list 'org-src-lang-modes '("lean4" . nael))

;; Optional: Add to org-babel-do-load-languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((lean4 . t)
   (python . t)))

;;;; Links

(with-eval-after-load 'org
  (org-link-set-parameters
   "mid"
   :follow (lambda (path _)
             (start-process "xdg-open-mid" nil "xdg-open"
                            (concat "mid:" path)))))

;;; Font stuff

;; (use-package ligature
;;   :config
;;   ;; Enable all programming ligatures in programming modes
;;   (ligature-set-ligatures '(prog-mode text-mode) '(":::" "::=" "&&" "||" "::" ":=" "==" "!=" ">=" ">>" "<="
;;                                                    "<<" "??" ";;" "->" "<-" "-->" "<--" "=>" "!!" "-->" "<--"
;;                                                    "=<<" "=~" "/=" "++" "--" "===" "<>" "</>" "!==" "</" "<!--"
;;                                                    ))
;;   ;; Enables ligature checks globally in all buffers. You can also do it
;;   ;; per mode with `ligature-mode'.
;;   (global-ligature-mode t))

;;; Embark (keybinds)

(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; (push 'embark--allow-edit
;;       (alist-get 'eglot-rename embark-target-injection-hooks))

;;; Snippets

(use-package yasnippet
  :custom
  (yas-snippet-dirs '("~/.config/emacs/snippets")))

(yas-reload-all)
(add-hook 'org-mode-hook  'yas-minor-mode-on)
(add-hook 'markdown-mode-hook  'yas-minor-mode-on)
(add-hook 'prog-mode-hook 'yas-minor-mode-on)
(add-hook 'LaTeX-mode-hook 'yas-minor-mode-on)
(add-hook 'prog-mode-hook 'yas-minor-mode-on)

;;; Git

(use-package git-gutter
  :config
  (global-git-gutter-mode t))

;;; Spell and grammar checking

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(markdown-mode . ("harper-ls" "--stdio"))))

;;; Dired

(setq dired-listing-switches "-al --group-directories-first")
(add-hook 'dired-mode-hook
          (lambda ()
            (dired-hide-details-mode)))

(use-package dired
  :ensure nil
  :init
  (require 'dired-x)

  :bind
  (:map dired-mode-map
        ("C-h" . dired-omit-mode))

  :hook
  (dired-mode . (lambda () (dired-omit-mode))) ;; hide .dot files by default

  :config
  (setq dired-omit-files   ;; hide .dot files when in dired-omit-mode
        (concat dired-omit-files "\\|^\\.[^.].*")))

;;; LLMs

(use-package gptel
  :custom
  (gptel-default-mode #'org-mode))
(gptel-make-anthropic "Claude" :stream t :key gptel-api-key)

(use-package agent-shell)
(setq agent-shell-anthropic-authentication
      (agent-shell-anthropic-make-authentication :login t))

;;; File handling

(use-package openwith
  :config
  (setq openwith-associations '(("\\.pdf\\'" "setsid -w xdg-open" (file))
                                ;;("\\.png\\'" "setsid -w xdg-open" (file))
                                ;;("\\.jpg\\'" "setsid -w xdg-open" (file))
                                ;;("\\.jpeg\\'" "setsid -w xdg-open" (file))
                                ;; ("\\.html\\'" "firefox" (file))
                                ("\\.mp4\\'" "setsid -w xdg-open" (file))
                                ("\\.mkv\\'" "setsid -w xdg-open" (file))
                                ))
  (openwith-mode t))

;;; Typst

;; (package-vc-install "https://codeberg.org/meow_king/typst-ts-mode.git")

(use-package typst-ts-mode
  :custom
  (typst-ts-watch-options "--open"))

(with-eval-after-load 'eglot
  (with-eval-after-load 'typst-ts-mode
    (add-to-list 'eglot-server-programs
                 `((typst-ts-mode) .
                   ,(eglot-alternatives `(,typst-ts-lsp-download-path
                                          "tinymist"
                                          "typst-lsp"))))))

;;; KMonad

(use-package kbd-mode
  :vc (:url "https://github.com/kmonad/kbd-mode" :rev :newest))

;;; ERC

(setq erc-autojoin-channels-alist '(("Libera.Chat" "#lobsters" "#crypto" "#emacs" "#org-mode")
                                    ("Lainchan" "#lainchan" "#laintracker"))
      erc-hide-list '("JOIN" "PART" "QUIT")
      erc-lurker-hide-list '("JOIN" "PART" "QUIT")
      erc-prompt-for-nickserv-password nil)
(with-eval-after-load 'erc (add-to-list 'erc-modules 'notifications))

;;; Docker

(use-package dockerfile-mode)

;;; Tramp

(setq tramp-default-method "ssh")

;;; Hide mode-line

(use-package hide-mode-line
  :bind
  ("<f9>" . global-hide-mode-line-mode))
;;; Scroll bar

(use-package mlscroll
  :ensure t
  :hook (server-after-make-frame . mlscroll-mode))

;;; Eww

(add-hook 'eww-mode-hook #'olivetti-mode)

(setq browse-url-browser-function 'browse-url-default-browser
      eww-search-prefix "https://search.kchou.duckdns.org/search?q=")

;;; Elpher

(use-package elpher)
(add-hook 'elpher-mode-hook #'olivetti-mode)

;;; Elfeed

(use-package elfeed)
;; (global-set-key (kbd "C-c w") 'elfeed)
(add-hook 'elfeed-show-mode-hook #'olivetti-mode)
(setq-default elfeed-search-filter "+unread "
              elfeed-search-title-max-width 150
              elfeed-db-directory "~/Documents/03-Resources/RSS feeds/elfeed-db")

(use-package elfeed-org
  :after elfeed)
(elfeed-org)
(setq rmh-elfeed-org-files (list "~/Documents/03-Resources/RSS feeds/Feeds.org"))

(use-package elfeed-tube
  :after elfeed)
(elfeed-tube-setup)
(define-key elfeed-show-mode-map (kbd "F") 'elfeed-tube-fetch)
(define-key elfeed-show-mode-map [remap save-buffer] 'elfeed-tube-save)
(define-key elfeed-search-mode-map (kbd "F") 'elfeed-tube-fetch)
(define-key elfeed-search-mode-map [remap save-buffer] 'elfeed-tube-save)

(setq elfeed-tube-captions-languages
      '("en" "gr" "english (auto generated)")
      elfeed-tube-captions-sblock-p t)

(use-package mpv)
(use-package elfeed-tube-mpv)
(define-key elfeed-show-mode-map (kbd "RET") 'elfeed-tube-mpv)
(define-key elfeed-show-mode-map (kbd "C-c C-f") 'elfeed-tube-mpv-follow-mode)
(define-key elfeed-show-mode-map (kbd "C-c C-w") 'elfeed-tube-mpv-where)

(use-package elfeed-score
  :config
  (setq elfeed-score-rule-stats-file "/home/kchou/Documents/03-Resources/RSS feeds/elfeed.stats"
        elfeed-score-serde-score-file "/home/kchou/Documents/03-Resources/RSS feeds/elfeed.score")
  (setq elfeed-search-print-entry-function #'elfeed-score-print-entry)
  (progn
    (elfeed-score-enable)
    (define-key elfeed-search-mode-map "=" elfeed-score-map)))

;;; Custom modes

(define-derived-mode url-list-mode text-mode "URL List"
  "Major mode for editing lists of URLs, allowing # comments and highlighting SHA1 hashes."
  (setq-local comment-start "#")
  (setq-local comment-start-skip "#+\\s-*")
  (modify-syntax-entry ?# "<" url-list-mode-syntax-table)
  (modify-syntax-entry ?\n ">" url-list-mode-syntax-table)
  (font-lock-add-keywords nil
                          '(("^#.*" . font-lock-comment-face)
                            ("\\b[a-f0-9]\\{7,40\\}\\b" . font-lock-keyword-face))) ;; SHA-1 hash
  (goto-address-mode 0)) ;; Optional: make URLs clickable

;;; Custom Settings

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("3799f9b2e997c7cf7d1a5d9846095c8976bce96852eda40d8bf9248157c2615f"
     "17570f818a8a3877994453342e3425a3b4fa4b3ebac050b4ecbbee958f1ca133"
     "fb232a8ae1311f1b8acecb1f766880d12d7a01b7d8d547e7c09325a074a31237"
     "f693c100eed9a8dc13f020997530737c67581fa524da6fb3ca7e9afc48fa485d"
     "05dd18cce7247eefa694037a6f73aa3574a9f8735e2dcc67bc47abb07ff7a9d4"
     "aa36026e7cfc43b58fb6ea3683042f96e50d803eb76efe6e18d1f24002ac14d4"
     "d2c76098def8b2b10b45d2092c86ca9c8b95d58fabbc8850d28899181d8f6581"
     "a68ec832444ed19b83703c829e60222c9cfad7186b7aea5fd794b79be54146e6"
     "01a9797244146bbae39b18ef37e6f2ca5bebded90d9fe3a2f342a9e863aaa4fd"
     "1ad12cda71588cc82e74f1cabeed99705c6a60d23ee1bb355c293ba9c000d4ac"
     "da69584c7fe6c0acadd7d4ce3314d5da8c2a85c5c9d0867c67f7924d413f4436"
     "df39cc8ecf022613fc2515bccde55df40cb604d7568cb96cd7fe1eff806b863b"
     "c038d994d271ebf2d50fa76db7ed0f288f17b9ad01b425efec09519fa873af53"
     "5e39e95c703e17a743fb05a132d727aa1d69d9d2c9cde9353f5350e545c793d4"
     "77f281064ea1c8b14938866e21c4e51e4168e05db98863bd7430f1352cab294a" default))
 '(org-agenda-files
   '("~/Documents/01-Projects/ALMA - Blockchains - Theory Exercise 3/Chousos_blockchains_theory_3.org"
     "/home/kchou/Documents/01-Projects/Projects.org"
     "/home/kchou/Documents/02-Areas/Areas.org"
     "/home/kchou/Documents/00-Inbox/Inbox.org"))
 '(package-selected-packages '(4g))
 '(package-vc-selected-packages
   '((4g :vc-backend Git :url "https://github.com/eNotchy/4g")
     (buffer-to-pdf :vc-backend Git :url
                    "https://github.com/protesilaos/buffer-to-pdf.git")
     (agent-shell-sidebar :url "https://github.com/cmacrae/agent-shell-sidebar")
     (kbd-mode :url "https://github.com/kmonad/kbd-mode")
     (org-mode :url "https://code.tecosaur.net/tec/org-mode" :branch "dev")
     (org-timeblock :vc-backend Git :url
                    "https://github.com/ichernyshovvv/org-timeblock/")
     (typst-ts-mode :vc-backend Git :url
                    "https://codeberg.org/meow_king/typst-ts-mode.git")))
 '(send-mail-function 'mailclient-send-it))

;; Enable previously disabled commands
(put 'narrow-to-region 'disabled nil)

;;; Startup Message

(add-hook 'after-init-hook
          (lambda ()
            (message "Emacs configuration loaded successfully!")))
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'dired-find-alternate-file 'disabled nil)
