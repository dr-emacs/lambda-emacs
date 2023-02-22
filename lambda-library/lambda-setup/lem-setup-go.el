;;; lem-setup-go.el --- Programming settings -*- lexical-binding: t -*-

;; Author: Dr. Stephan Heuer
;; Maintainer: Colin McLear

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

;; Settings for better programming/coding. This includes delimiters, languages,
;; indentation, linting, documentation, and compilation.

;;; Code:

;;;; Show Pretty Symbols
;; (use-package prog-mode
;;   :straight (:type built-in)
;;   :defer t
;;   :custom
;;   ;; Show markup at point
;;   (prettify-symbols-unprettify-at-point t)
;;   :config
;;   ;; Pretty symbols
;;   (global-prettify-symbols-mode +1))


;;;;; EGlot

;; (use-package xref
;;   :straight nil
;;   :bind
;;   ([remap xref-find-apropos] . xref-find-definitions)
;;   ([remap xref-find-definitions] . xref-find-definitions-other-window)
;;   :bind (("s-r" . #'xref-find-references)
;;          ("s-[" . #'xref-go-back)
;;          ("C-<down-mouse-2>" . #'xref-go-back)
;;          ("s-]" . #'xref-go-forward)))

(use-package eglot
  :custom
  (eglot-autoshutdown t)
  :bind (:map eglot-mode-map
         ("C-c a r" . #'eglot-rename)
         ("C-<down-mouse-1>" . #'xref-find-definitions)
         ("C-S-<down-mouse-1>" . #'xref-find-references)
         ("C-c C-c" . #'eglot-code-actions))
  :hook
                                        ; (eglot-managed-mode . me/flymake-eslint-enable-maybe)
  (typescript-mode . eglot-ensure)
  (go-mode . eglot-ensure)
                                        ; (haskell-mode . eglot-ensure)
                                        ; (rust-mode . eglot-ensure)
  :init
  (put 'eglot-server-programs 'safe-local-variable 'listp)
  :config
  (add-to-list 'eglot-stay-out-of 'eldoc-documentation-strategy)
  (put 'eglot-error 'flymake-overlay-control nil)
  (put 'eglot-warning 'flymake-overlay-control nil)
  (advice-add 'eglot--apply-workspace-edit :after #'me/project-save)
  (advice-add 'project-kill-buffers :before #'me/eglot-shutdown-project)
  :preface
  (defun me/eglot-shutdown-project ()
    "Kill the LSP server for the current project if it exists."
    (when-let ((server (eglot-current-server)))
      (ignore-errors (eglot-shutdown server)))))

(use-package consult-eglot
  :bind (:map eglot-mode-map ("s-t" . #'consult-eglot-symbols)))

;; (use-package flymake
;;   :straight nil
;;   :custom
;;   (flymake-fringe-indicator-position 'left-fringe))

(use-package tree-sitter
  :hook
  (js-mode . tree-sitter-hl-mode)
  (typescript-mode . tree-sitter-hl-mode))

(use-package tree-sitter-langs
  :after tree-sitter
  :defer nil
  :config
  (tree-sitter-require 'tsx)
  (add-to-list 'tree-sitter-major-mode-language-alist
               '(typescript-tsx-mode . tsx)))

(use-package display-line-numbers
  :custom
  (display-line-numbers-grow-only t)
  (display-line-numbers-type 'relative)
  (display-line-numbers-width 3)
  ;; (add-hook 'conf-mode-hook #'display-line-numbers-mode)
  ;; (add-hook 'prog-mode-hook #'display-line-numbers-mode)
  ;; (add-hook 'text-mode-hook #'display-line-numbers-mode)
  ;; (global-display-line-numbers-mode 1)
  ;; Disable line numbers for some modes
  :config
  (dolist (mode '(org-mode-hook
                  term-mode-hook
                  eshell-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 0))))
  ;; Enable line numbers for some modes
  (dolist (mode '(conf-mode-hook
                  prog-mode-hook
                  text-mode-hook))
    (add-hook mode (lambda () (display-line-numbers-mode 1)))))

;;;;; Go
(use-package go-mode
  :commands go-mode)

;;; Provide
(provide 'lem-setup-go)
;;; lem-setup-go.el ends here
