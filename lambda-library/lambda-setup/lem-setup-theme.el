;;; lem-setup-theme.el --- summary -*- lexical-binding: t -*-

;; Author: Colin McLear
;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.


;;; Commentary:

;; Theme settings & functions 𝛌-Emacs comes with its own set of themes --
;; 𝛌-Themes. The user can of course configure things to use whatever theme they
;; like. The Modus themes are especially good and included with Emacs 28+.

;;; Code:

;;;; No-confirm themes
(setq custom-safe-themes t)

;;;; Custom Theme Folder
;;
(defcustom lem-custom-themes-dir (concat lem-user-dir "custom-themes/")
  "Set a custom themes directory path."
  :group 'lambda-emacs
  :type 'string)

;; Make the custom themes dir.
(mkdir lem-custom-themes-dir t)
(setq-default custom-theme-directory lem-custom-themes-dir)

;; find all themes recursively in custom-theme-folder
(let ((basedir custom-theme-directory))
  (dolist (f (directory-files basedir))
    (if (and (not (or (equal f ".") (equal f "..")))
             (file-directory-p (concat basedir f)))
        (add-to-list 'custom-theme-load-path (concat basedir f)))))

;;;; Disable All Custom Themes
(defun lem-disable-all-themes ()
  "Disable all active themes & reset mode-line."
  (interactive)
  (progn
    (dolist (i custom-enabled-themes)
      (disable-theme i))
    ;; disable window-divider mode
    (window-divider-mode -1)
    ;; revert to mode line
    (setq-default header-line-format nil)
    (setq-default mode-line-format
                  '((:eval
                     (list
                      "%b "
                      "%m "
                      (cond ((and buffer-file-name (buffer-modified-p))
                             (propertize "(**)" 'face `(:foreground "#f08290")))
                            (buffer-read-only "(RO)" ))
                      " %l:%c %0"
                      " "
                      ))))
    (force-mode-line-update)))

;;;; Load Theme Wrapper
(defun lem-load-theme ()
  (interactive)
  (progn
    (lem-disable-all-themes)
    (call-interactively 'load-theme)))

;;;; Toggle Menubar
;; toggle menubar to light or dark
(defun lem-osx-toggle-menubar-theme ()
  "Toggle menubar to dark or light using shell command."
  (interactive)
  (shell-command "dark-mode"))
(defun lem-osx-menubar-theme-light ()
  "Turn dark mode off."
  (interactive)
  (shell-command "dark-mode off"))
(defun lem-osx-menubar-theme-dark ()
  "Turn dark mode on."
  (interactive)
  (shell-command "dark-mode on"))

;;;; Theme & menubar toggle
(defun toggle-dark-light-theme ()
  "Coordinate setting of theme with os theme and toggle."
  (interactive)
  (if (eq active-theme 'light-theme)
      (progn (lem-osx-menubar-theme-dark)
             (setq active-theme 'dark-theme))
    (progn (lem-osx-menubar-theme-light)
           (setq active-theme 'light-theme))))

;;;; After Load Theme Hook
(defvar lem-after-load-theme-hook nil
  "Hook run after a color theme is loaded using `load-theme'.")
(defadvice load-theme (after run-after-load-theme-hook activate)
  "Run `after-load-theme-hook'."
  (run-hooks 'lem-after-load-theme-hook))

;;;; Lambda Themes
;; Set a default theme
(use-package lambda-themes
  :straight (:type git :host github :repo "lambda-emacs/lambda-themes")
  :custom
  ;; Custom settings. To turn any of these off just set to `nil'.
  (lambda-themes-set-variable-pitch t)
  (lambda-themes-set-italic-comments t)
  (lambda-themes-set-italic-keywords t))

;;;; Builtin Modus Themes
;; Set a default theme
(use-package modus-themes
  :straight (modus-themes :type built-in)
  :init
  ;; Add all your customizations prior to loading the themes
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t)
  (setq
   ;; modus-themes-vivendi-color-overrides
   ;; '((bg-region-accent-subtle . "#240f55")) ;; Default
   ;; '((bg-region-accent-subtle . "#323da2"));; Good candidate
   ;; '((bg-region-accent-subtle . "#304466"))
   ;; modus-themes-operandi-color-overrides
   ;; '((bg-main . "#FAFAFA")
   ;;  (fg-main . "#101010")
   ;;  (fg-window-divider-inner . "#FAFAFA"))
   modus-themes-completions '((matches . (extrabold))
			                  (selection . (semibold accented))
			                  (popup . (accented intense)))
   modus-themes-diffs nil ; 'fg-only
   modus-themes-fringes 'intense
   modus-themes-hl-line '(accented intense)
   modus-themes-intense-markup t
   modus-themes-links '(faint background)
   modus-themes-mixed-fonts t
   ;; modus-themes-no-mixed-fonts t
   modus-themes-mode-line '(accented borderless)
   ;; modus-themes-mode-line '(accented 3d)
   modus-themes-org-blocks 'gray-background
   modus-themes-paren-match '(bold intense)
   modus-themes-prompts '(intense accented)
   modus-themes-region '(bg-only accented)
   modus-themes-scale-headings t
   modus-themes-slanted-constructs t
   modus-themes-subtle-line-numbers t
   modus-themes-syntax '(alt-syntax yellow-comments green-strings)
   ;; modus-themes-syntax '(alt-syntax)
   modus-themes-tabs-accented t
   modus-themes-headings
   '((1 . (variable-pitch light 1.6))
     (2 . (overline semibold 1.4))
     (3 . (monochrome overline 1.2 background))
     (4 . (overline 1.1))
     (t . (rainbow 1.05)))
   modus-themes-completions
   '((matches . (extrabold background))
     (selection . (semibold italic)))
   )
  :init (load-theme 'modus-vivendi :noconfirm t)
  :bind ("<f5>" . modus-themes-toggle))

;;;;; System Appearance Hook
;; See https://github.com/d12frosted/homebrew-emacs-plus#system-appearance-change
(defun lem--system-apply-theme (appearance)
  "Load theme, taking current system APPEARANCE into consideration."
  (mapc #'disable-theme custom-enabled-themes)
  (pcase appearance
    ('light (progn
              (load-theme 'lambda-light)
              (setq active-theme 'light-theme)))
    ('dark (progn
             (load-theme 'lambda-dark)
             (setq active-theme 'dark-theme)))))

(defcustom lem-ui-mac-system-theme t
  "When `t' use theme that matches macOS system theme."
  :group 'lambda-emacs
  :type 'boolean)

;; Add the hook on MacOS
(when (and sys-mac
           lem-ui-mac-system-theme)
  (add-hook 'ns-system-appearance-change-functions #'lem--system-apply-theme))

;;;;; Define User Theme
(defcustom lem-ui-theme nil
  "Default user theme."
  :group 'lambda-emacs
  :type 'symbol)

;; If set, load user theme, otherwise load lambda-themes
;; (cond ((bound-and-true-p lem-ui-theme)
;;        (load-theme lem-ui-theme t))
;;       ((eq active-theme 'light-theme)
;;        (load-theme 'lambda-light t))
;;       ((eq active-theme 'dark-theme)
;;        (load-theme 'lambda-dark t))
;;       (t
;;        (load-theme 'lambda-light t)))

;; kind-icon needs to have its cache flushed after theme change
(with-eval-after-load 'kind-icon
  (add-hook 'lambda-themes-after-load-theme-hook #'kind-icon-reset-cache))

;;; Provide
(provide 'lem-setup-theme)
;;; lem-setup-theme.el ends here
