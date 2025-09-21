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

(savehist-mode 1)

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
    (set-face-attribute 'default nil :family "Iosevka" :height 110)
    (set-face-attribute 'fixed-pitch nil :family "Iosevka" :height 110))
  (when (find-font (font-spec :name "Iosevka Aile"))
    (set-face-attribute 'variable-pitch nil :family "Iosevka Aile")))

(if (daemonp)
    (add-hook 'after-make-frame-functions
              (lambda (frame)
                (with-selected-frame frame
                  (set-font-faces))))
  (set-font-faces))

(setq line-spacing 0.1) ; Slightly increased for better readability

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Disable annoying buffers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(with-eval-after-load 'quail (defun quail-completion ()))

(setq-default message-log-max nil)
(kill-buffer "*Messages*")

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

;;resizing windows
(global-set-key (kbd "C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "C-<up>") 'enlarge-window)
(global-set-key (kbd "C-<down>") 'shrink-window)

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
        '((1 . (1.2))
          (2 . (1.15))
          (3 . (1.1))
          (4 . (1.05))
          (t . (1.0)))

        modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts t
        modus-themes-subtle-line-numbers t
        modus-themes-fringes nil ; {nil,'subtle,'intense}

        ;; mode-line settings
        modus-themes-common-palette-overrides
        '(;; make border same color (e.g. borderless)
          ;; (border-mode-line-active bg-mode-line-active)
          ;; (border-mode-line-inactive bg-mode-line-inactive)
          ;; make active window's mode-line purple
          (bg-mode-line-active bg-lavender)
          (fg-mode-line-active fg-main)
          (border-mode-line-active bg-magenta-intense)

          ;; Make line numbers less intense
          (fg-line-number-inactive "gray50")
          (fg-line-number-active fg-main)
          (bg-line-number-inactive unspecified)
          (bg-line-number-active unspecified)
          ))

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
  ;; :config
  ;; (vundo-popup-mode)
  )

(use-package dashboard
  :custom
  (dashboard-startup-banner 'official)
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-startupify-list '(dashboard-insert-banner
                               ;; dashboard-insert-newline
                               ;; dashboard-insert-items
                               ))
  (dashboard-items '((projects . 5)
                     (bookmarks . 3)
                     (recents . 3)))
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
  (project-vc-extra-root-markers '(".envrc" ".project" ".git")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Direnv
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package direnv
  :custom
  (direnv-always-show-summary nil))

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
  ;; :custom
  ;; (eglot-ignored-server-capabilities '(:inlayHintProvider))
  :bind
  (("C-c C-q" . eglot-code-actions))
  :config
  (add-to-list 'eglot-server-programs '((python-base-mode)
                                        "basedpyright-langserver" "--stdio")))

;; Python
(add-hook 'python-base-mode-hook 'direnv-mode)

;; Yaml
(use-package yaml-mode)

;; Rust
(use-package rust-mode)
;; (add-hook 'rust-mode-hook 'eglot-ensure)
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((rust-ts-mode rust-mode) .
                 ("rust-analyzer" :initializationOptions (:check (:command "clippy"))))))

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

(use-package centered-cursor-mode)

(use-package olivetti
  :custom
  (olivetti-body-width 120))

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
  (setq truncate-lines nil))

(add-hook 'org-mode-hook #'my-prose-setup)
(add-hook 'markdown-mode-hook #'my-prose-setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Markdown
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package markdown-mode
  :mode ("\\.md\\'" "\\.qmd\\'")
  :hook ((markdown-mode . olivetti-mode)
         (markdown-mode . save-place-local-mode)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bibliography and Citations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
  (defun my/zk-new-note-header (title new-id &optional orig-id)
    "Insert header in new notes with TITLE and NEW-ID."
    (insert (format "* %s %s\n\n" new-id title)))
  :bind
  ("C-c z k" . zk-find-file)
  ("C-c z g" . zk-grep)
  ("C-c z f" . zk-find-file-by-full-text-search)
  ("C-c z b" . zk-backlinks)
  ("C-c z t" . zk-tag-insert)
  ("C-c z y" . zk-tag-search)
  ("C-c z r" . zk-rename-note)
  ;; ("C-c z n" . zk-new-note)
  ("C-c z N" . zk-network)
  ("C-c z n" . citar-open-notes)
  ("C-c z i" . zk-insert-link)
  ("C-c z c" . zk-current-notes)
  ("C-c z I" . zk-index)
  ("C-c z o" . zk-follow-link-at-point)
  :custom
  (zk-new-note-header-function 'my/zk-new-note-header)
  (zk-directory "~/Documents/02-Areas/Slipbox/")
  (zk-file-extension "org")
  (zk-id-time-string-format "%Y%m%d%H%M%S")
  (zk-id-regexp "\\([0-9]\\{14\\}\\)")
  (zk-tag-regexp "\\s#\\+[A-Za-zΑ-Ωα-ωΆ-Ώά-ώ_/\\-][A-Za-zΑ-Ωα-ωΆ-Ώά-ώ0-9_/\\-]*")
  (zk-new-note-link-insert 'ask)
  (zk-link-and-title nil)
  :config
  (zk-setup-auto-link-buttons)
  (zk-setup-embark))

(use-package zk-index
  :after zk
  :custom
  (zk-index-view-hide-cursor nil)
  (zk-index-invisible-ids nil))

(use-package zk-desktop
  :after zk-index
  :custom
  (zk-desktop-directory "~/Documents/02-Areas/Slipbox/")
  (zk-desktop-basename "Desktop - ")
  (zk-desktop-major-mode 'org-mode))

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

(setq cdlatex-math-symbol-alist '((93 ("\\Rightarrow" "\\implies"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Math rendering
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package math-preview
  ;; :hook ((markdown-mode . math-preview-all))
  :custom
  (math-preview-mathjax-tags "ams"))

(advice-add #'math-preview-all :before (lambda () (math-preview-reset-numbering 1)))

(with-eval-after-load 'markdown-mode
  (define-key markdown-mode-map (kbd "C-c C-m") #'math-preview-all))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org-Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (package-vc-install '(org-mode :url "https://code.tecosaur.net/tec/org-mode" :branch "dev"))
(use-package org :load-path "~/.config/emacs/elpa/org-mode/lisp/"
  :hook ((org-mode . olivetti-mode)
         (org-mode . my/markdown-highlight-tags)
         (org-mode . save-place-local-mode)
         ;; (org-mode . flyspell-mode)
         (org-mode . org-cdlatex-mode))
  :config
  (setq ; org-image-actual-width (list 0.5)
   org-image-align 'center
   org-ellipsis "…"
   org-startup-indented t
   org-pretty-entities nil
   org-footnote-auto-adjust t
   org-support-shift-select t
   org-startup-with-inline-images t
   org-fontify-quote-and-verse-blocks t
   org-link-file-path-type 'relative
   org-use-speed-commands t
   org-footnote-section nil
   org-return-follows-link t)

  (setq org-highlight-latex-and-related '(latex script entities))

  ;; Export options
  (setq org-cite-csl-styles-dir "~/Library/Zotero data/styles/"
        org-export-with-toc nil
        org-html-postamble nil
        org-export-with-broken-links t
        org-export-with-section-numbers nil
        org-export-with-smart-quotes t
        org-cite-csl-link-cites t
        org-cite-export-processors'((latex . (biblatex nil nil)) (t . (csl "ieee.csl" "ieee.csl")))
        org-cite-global-bibliography '("/home/kchou/Documents/02-Areas/Slipbox/Attachments/biblio.bib")
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

(use-package oc-csl
  :ensure nil)

(add-hook 'org-mode-hook
          (lambda ()
            (setq-local electric-pair-pairs '((?* . ?*) (?/ . ?/) (?+ . ?+) (?= . ?=) (?~ . ?~)))
            (setq-local electric-pair-text-pairs electric-pair-pairs)))

(defun my/find-first-headline ()
  "Move point to just after the first headline in the file."
  (goto-char (point-min))
  (re-search-forward "^\\* " nil t)
  (forward-line 1))

(global-set-key (kbd "C-c c") #'org-capture)

(setq org-capture-templates
      '(("i" "Inbox" plain
         (file+function "~/Documents/02-Areas/Slipbox/00000000000000 Inbox.org" my/find-first-headline)
         "\n%U\n%?\n\n--------------------------------------------------------------------------------\n\n"
         :empty-lines 1)))

(use-package org-latex-preview
  :ensure nil
  :config
  (plist-put org-format-latex-options :zoom 1.3)
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


;; Open =zotero://= links from org buffers.
(defun org-zotero-open (path)
  (browse-url-xdg-open (format "zotero:%s" path)))

(with-eval-after-load 'org
  (org-link-set-parameters "zotero" :follow #'org-zotero-open))

(use-package org-modern
  :custom
  (org-modern-star 'replace)
  :hook
  ((org-mode . org-modern-mode)))

(use-package org-appear
  :custom
  (org-hide-emphasis-markers t)
  (org-appear-trigger 'always)
  (org-appear-autoemphasis t)
  (org-appear-autolinks t)
  (org-appear-autoentities t)
  (org-appear-autokeywords t))

(add-hook 'org-mode-hook 'org-appear-mode)

(use-package org-download
  :custom
  (org-download-method 'directory)
  (org-download-image-dir "./Attachments"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Typesetting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package ligature
  :config
  ;; Enable all programming ligatures in programming modes
  (ligature-set-ligatures '(prog-mode text-mode) '(":::" "::=" "&&" "||" "::" ":=" "==" "!=" ">=" ">>" "<="
                                                   "<<" "??" ";;" "->" "<-" "-->" "<--" "=>" "!!" "-->" "<--"
                                                   "=<<" "=~" "/=" "++" "--" "===" "<>" "</>" "!==" "</" "<!--"
                                                   ))
  ;; Enables ligature checks globally in all buffers. You can also do it
  ;; per mode with `ligature-mode'.
  (global-ligature-mode t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Embark (keybinds)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Snippets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package yasnippet
  :custom
  (yas-snippet-dirs '("~/.config/emacs/snippets")))

(yas-reload-all)
(add-hook 'org-mode-hook  'yas-minor-mode-on)
(add-hook 'prog-mode-hook 'yas-minor-mode-on)
(add-hook 'LaTeX-mode-hook 'yas-minor-mode-on)
(add-hook 'prog-mode-hook 'yas-minor-mode-on)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Git
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package git-gutter
  :config
  (global-git-gutter-mode t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spell and grammar checking
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(markdown-mode . ("harper-ls" "--stdio"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dired
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq dired-listing-switches "-al --group-directories-first")
(add-hook 'dired-mode-hook
          (lambda ()
            (dired-hide-details-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LLMs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package gptel
  :custom
  (gptel-default-mode #'org-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Typst
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ERC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq erc-autojoin-channels-alist '(("Libera.Chat" "#lobsters" "#crypto")
                                    ("Lainchan" "#lainchan" "#laintracker")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Docker
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package dockerfile-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tramp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq tramp-default-method "ssh")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Eww
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-hook 'eww-mode-hook #'olivetti-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom modes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Custom Settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("1ad12cda71588cc82e74f1cabeed99705c6a60d23ee1bb355c293ba9c000d4ac"
     "da69584c7fe6c0acadd7d4ce3314d5da8c2a85c5c9d0867c67f7924d413f4436"
     "df39cc8ecf022613fc2515bccde55df40cb604d7568cb96cd7fe1eff806b863b"
     "c038d994d271ebf2d50fa76db7ed0f288f17b9ad01b425efec09519fa873af53"
     "5e39e95c703e17a743fb05a132d727aa1d69d9d2c9cde9353f5350e545c793d4"
     "77f281064ea1c8b14938866e21c4e51e4168e05db98863bd7430f1352cab294a" default))
 '(package-selected-packages
   '(apheleia auctex cape cdlatex centered-cursor-mode citar-embark corfu csv-mode
              darkroom dashboard diff-hl direnv dockerfile-mode edit-indirect
              ef-themes eglot git-gutter gptel ligature link-hint marginalia
              markdown-mode markdown-ts-mode math-preview mermaid-mode
              modus-themes olivetti openwith orderless org-appear org-download
              org-mode org-modern pet ruff-format rust-mode selectric-mode
              telephone-line tree-sitter-langs treesit-auto typst-ts-mode
              vertico vterm vundo yaml-mode yasnippet zk-desktop))
 '(package-vc-selected-packages
   '((typst-ts-mode :vc-backend Git :url
                    "https://codeberg.org/meow_king/typst-ts-mode.git"))))

;; Enable previously disabled commands
(put 'dired-find-alternate-file 'disabled nil)
(put 'narrow-to-region 'disabled nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Startup Message
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Kill buffers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(kill-buffer "*scratch*")
