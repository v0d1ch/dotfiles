;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Sasha Bogicevic"
      user-mail-address "sasha.bogicevic@iohk.io")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;
(setq
 default-font "Hasklig"
 default-font-size 20
 default-nice-size 20
 doom-font-increment 1
 doom-font (font-spec :family default-font
                      :size default-font-size)
 doom-variable-pitch-font (font-spec :family default-font
                                     :size default-font-size)
 )

;;(setq doom-font (font-spec :family "Hasklig" :size 20 :weight 'regular)
;;      doom-variable-pitch-font (font-spec :family "Hasklig" :size 20))
;; (setq doom-font (font-spec :family "Hasklig" :size 20))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
;;(setq display-line-numbers-type 'relative)
(setq display-line-numbers 1)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq doom-theme 'doom-dracula)
;;(setq doom-theme 'tsdh-light)
(setq magit-list-refs-sortby "-creatordate")
(use-package! evil-escape
:init
(setq evil-escape-key-sequence "jk"))
(setq create-lockfiles nil)
(setq confirm-kill-emacs nil)
(setq find-file-visit-truename nil)
(setq which-key-idle-delay 0.2)


(map! :leader
     ;; :desc "M-x"                   "SPC" #'execute-extended-command
      :desc "Search in project"     "/"   #'+default/search-project
      :desc "Comment lines"         ";"   #'comment-or-uncomment-region
      ;;; <leader> a --- agenda
      :desc "Org agenda"            "a"   #'org-agenda
      ;;; <leader> g --- git/version control
      (:prefix ("g" . "git")
       :desc "Git status"           "s"   #'magit-status
       )
      ;;; <leader> e --- errors (flycheck)
      (:prefix ("e" . "errors")
       :desc "List errors"          "l"   #'+toggle-flycheck-error-list
       :desc "Next error"           "n"   #'flycheck-next-error
       :desc "Previous error"       "p"   #'flycheck-previous-error
       :desc "Select checker"       "s"   #'flycheck-select-checker
       :desc "Verify setup"         "v"   #'flycheck-verify-setup
       ))


;; Flycheck

(defun +toggle-flycheck-error-list ()
  "Toggle flycheck's error list window. If the error list is
visible, hide it. Otherwise, show it."
  (interactive)
  (-if-let (window (flycheck-get-error-list-window))
      (quit-window nil window)
    (flycheck-list-errors)))

;; Haskell

;; Additional haskell mode key bindings
(map! :after haskell-mode
      :map haskell-mode-map
      :localleader
      "h" #'haskell-hoogle-lookup-from-local
      "H" #'haskell-hoogle)

(setq-hook! 'haskell-mode-hook +format-with-lsp nil)

;; Appropriate HLS is assumed to be in scope (by nix-shell)
(setq lsp-haskell-server-path "haskell-language-server-8.10.7"
      lsp-enable-file-watchers nil
      lsp-lens-enable nil
      lsp-treemacs-errors-position-params '((bottom))
      lsp-ui-sideline-diagnostic-max-lines 20
      lsp-ui-imenu-auto-refresh 1
      lsp-headerline-breadcrumb-enable 1
      ;;lsp-ui-sideline-show-diagnostics nil
      ;;lsp-diagnostics-flycheck-default-level 'warning
      ;;lsp-signature-render-documentation 1
      ;;lsp-enable-symbol-highlighting 1
      )
(defun add-autoformat-hook ()
  (add-hook 'before-save-hook '+format-buffer-h nil 'local))
(add-hook! (haskell-mode haskell-cabal-mode) 'add-autoformat-hook)

(set-formatter! 'fourmolu "fourmolu"
  :modes 'haskell-mode
  :filter
  (lambda (output errput)
    (list output
          (replace-regexp-in-string "Loaded config from:[^\n]*\n*" "" errput))))


;; Use 'cabal-fmt' for .cabal files
(set-formatter! 'cabal-fmt "cabal-fmt"
  :modes 'haskell-cabal-mode)

(map! :leader
      :desc "Show flycheck errors"
      "j" #'lsp-ui-flycheck-list)

(map! :leader
      :desc "Show flycheck errors"
      "k" #'lsp-ui-imenu)

(map! :leader
      :desc "UI Peek find definitions"
      "dd" #'lsp-ui-peek-find-definitions)

(map! :leader
      :desc "UI Peek find references"
      "rr" #'lsp-ui-peek-find-references)

(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0.02))

(use-package git-gutter-fringe
  :config
  (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom))

(eval-after-load 'git-timemachine
  '(progn
     (evil-make-overriding-map git-timemachine-mode-map 'normal)
     ;; force update evil keymaps after git-timemachine-mode loaded
     (add-hook 'git-timemachine-mode-hook #'evil-normalize-keymaps)))

