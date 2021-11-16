
;;; init.el --- My init.el  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Naoya Yamashita

;; Author: Naoya Yamashita <conao3@gmail.com>

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; My init.el.

;;; Code:

;; this enables this running method
;;   emacs -q -l ~/.debug.emacs.d/init.el

(column-number-mode t)
;; remove tab
(setq-default indent-tabs-mode nil)
;; display line num
;;(global-linum-mode t)
;; backups
(setq backup-directory-alist '((".*" . "~/.ehist")))
;; no beap
(setq ring-bell-function 'ignore)

(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("org"   . "https://orgmode.org/elpa/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

;; leaf config

(leaf undo-tree
  :ensure t
  :leaf-defer nil
  :bind (("M-/" . undo-tree-redo))
  :custom ((global-undo-tree-mode . t)))

(leaf zenburn-theme
  :ensure t
  :config (load-theme 'zenburn t))

;; paren-mode
(setq show-paren-delay 0)
(show-paren-mode t)
(setq show-paren-style 'parenthesis)
;(set-face-background 'show-paren-match-face "gray")
(set-face-attribute 'show-paren-match nil
      :background "gray"
      :underline 'unspecified)

(leaf multi-term
  :ensure t
  :custom `((multi-term-program . ,(getenv "SHELL")))
  :preface
  (defun namn/open-shell-sub (new)
   (split-window-below)
   (enlarge-window 5)
   (other-window 1)
   (let ((term) (res))
     (if (or new (null (setq term (dolist (buf (buffer-list) res)
                                    (if (string-match "*terminal<[0-9]+>*" (buffer-name buf))
                                        (setq res buf))))))
         (multi-term)
       (switch-to-buffer term))))
  (defun namn/open-shell ()
    (interactive)
    (namn/open-shell-sub t))
  (defun namn/to-shell ()
    (interactive)
    (namn/open-shell-sub nil))
  :bind (("C-^"   . namn/to-shell)
         ("C-M-^" . namn/open-shell)
         (:term-raw-map
          ("C-t" . other-window))))

(leaf smart-mode-line
  :ensure t
  :custom ((sml/no-confirm-load-theme . t)
           (sml/theme . 'dark)
           (sml/shorten-directory . -1))
  :config
  (sml/setup))

(leaf auto-complete
  :ensure t
  :leaf-defer nil
  :config
  (ac-config-default)
  :custom ((ac-use-menu-map . t)
           (ac-ignore-case . nil))
  :bind (:ac-mode-map
         ; ("M-TAB" . auto-complete))
         ("M-t" . auto-complete)))

(leaf whitespace
  :ensure t
  :custom
  ((whitespace-style . '(face
                         trailing
                         tabs
                         ;; spaces
                         ;; empty
                         space-mark
                         tab-mark))
   (whitespace-display-mappings . '((tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])))
   (global-whitespace-mode . t)))

(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf macrostep
  :ensure t
  :bind (("C-c e" . macrostep-expand)))

;; golang
(leaf *go
  :config
  (add-to-list 'exec-path (expand-file-name "~/.goenv/shims/"))
  (leaf go-mode
    :disabled (not (executable-find "go"))
    :ensure t go-eldoc
    :hook (go-mode-hook . (lambda ()
                            (go-eldoc-setup)
                            (set (make-local-variable 'whitespace-style) '())
                            (set (make-local-variable 'tab-width) 2)))
    :mode "\\.go\\'")
  (leaf go-autocomplete
    :ensure t))


;; leaf config end 

(provide 'init)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
