;;; packages.el --- C/C++ Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq c++-packages
  '(
    cc-mode
    disaster
    clang-format
    cmake-mode
    company
    (company-c-headers :toggle (configuration-layer/package-usedp 'company))
    company-ycmd
    flycheck
    gdb-mi
    semantic
    stickyfunc-enhance
    ycmd
    rtags
    ))

(defun c++/init-cc-mode ()
  (use-package cc-mode
    :defer t
    :init
    (progn
      (add-to-list 'auto-mode-alist
                   `("\\.h\\'" . ,c++-default-mode-for-headers)))
    :config
    (progn
      (require 'compile)
      (c-toggle-auto-newline 1)
      (spacemacs/set-leader-keys-for-major-mode 'c-mode
        "ga" 'projectile-find-other-file
        "gA" 'projectile-find-other-file-other-window)
      (spacemacs/set-leader-keys-for-major-mode 'c++-mode
        "ga" 'projectile-find-other-file
        "gA" 'projectile-find-other-file-other-window))))

(defun c++/init-disaster ()
  (use-package disaster
    :defer t
    :commands (disaster)
    :init
    (progn
      (spacemacs/set-leader-keys-for-major-mode 'c-mode
        "D" 'disaster)
      (spacemacs/set-leader-keys-for-major-mode 'c++-mode
        "D" 'disaster))))

(defun c++/init-clang-format ()
  (use-package clang-format
    :if c++-enable-clang-support))

(defun c++/init-cmake-mode ()
  (use-package cmake-mode
    :mode (("CMakeLists\\.txt\\'" . cmake-mode) ("\\.cmake\\'" . cmake-mode))
    :init (push 'company-cmake company-backends-cmake-mode)))

(defun c++/post-init-company ()
  (spacemacs|add-company-hook c-mode-common)
  (spacemacs|add-company-hook cmake-mode)

  (when c++-enable-clang-support
    (push 'company-clang company-backends-c-mode-common)

    (defun company-mode/more-than-prefix-guesser ()
      (c++/load-clang-args)
      (company-clang-guess-prefix))

    (setq company-clang-prefix-guesser 'company-mode/more-than-prefix-guesser)
    (spacemacs/add-to-hooks 'c++/load-clang-args '(c-mode-hook c++-mode-hook))))

(defun c++/init-company-c-headers ()
  (use-package company-c-headers
    :defer t
    :init (push 'company-c-headers company-backends-c-mode-common)))

(defun c++/post-init-flycheck ()
  (dolist (mode '(c-mode c++-mode))
    (spacemacs/add-flycheck-hook mode))
  (when c++-enable-clang-support
    (spacemacs/add-to-hooks 'c++/load-clang-args '(c-mode-hook c++-mode-hook))))

(defun c++/init-gdb-mi ()
  (use-package gdb-mi
    :defer t
    :init
    (setq
     ;; use gdb-many-windows by default when `M-x gdb'
     gdb-many-windows t
     ;; Non-nil means display source file containing the main routine at startup
     gdb-show-main t)))

(defun c++/post-init-semantic ()
  (spacemacs/add-to-hooks 'semantic-mode '(c-mode-hook c++-mode-hook)))

(defun c++/post-init-stickyfunc-enhance ()
  (spacemacs/add-to-hooks 'spacemacs/lazy-load-stickyfunc-enhance '(c-mode-hook c++-mode-hook)))

(defun c++/post-init-ycmd ()
  (add-hook 'c++-mode-hook 'ycmd-mode)
  (add-hook 'c-mode-hook 'ycmd-mode)
  (add-to-list 'spacemacs-jump-handlers-c++-mode '(ycmd-goto :async t))
  (add-to-list 'spacemacs-jump-handlers-c-mode '(ycmd-goto :async t))
  (dolist (mode '(c++-mode c-mode))
    (spacemacs/set-leader-keys-for-major-mode mode
      "gG" 'ycmd-goto-imprecise)))

(defun c++/post-init-company-ycmd ()
  (push 'company-ycmd company-backends-c-mode-common))

;; (defun c++/init-rtags ()
;;      (use-package rtags
;;             :if c++-enable-rtags-support))

(defun rtags-evil-standard-keybindings (mode)
  (evil-leader/set-key-for-mode mode
    "mR." 'rtags-find-symbol-at-point
    "mR," 'rtags-find-references-at-point
    "mRv" 'rtags-find-virtuals-at-point
    "mRV" 'rtags-print-enum-value-at-point
    "mR/" 'rtags-find-all-references-at-point
    "mRY" 'rtags-cycle-overlays-on-screen
    "mR>" 'rtags-find-symbol
    "mR<" 'rtags-find-references
    "mR[" 'rtags-location-stack-back
    "mR]" 'rtags-location-stack-forward
    "mRD" 'rtags-diagnostics
    "mRG" 'rtags-guess-function-at-point
    "mRp" 'rtags-set-current-project
    "mRP" 'rtags-print-dependencies
    "mRe" 'rtags-reparse-file
    "mRE" 'rtags-preprocess-file
    "mRR" 'rtags-rename-symbol
    "mRM" 'rtags-symbol-info
    "mRS" 'rtags-display-summary
    "mRO" 'rtags-goto-offset
    "mR;" 'rtags-find-file
    "mRF" 'rtags-fixit
    "mRL" 'rtags-copy-and-print-current-location
    "mRX" 'rtags-fix-fixit-at-point
    "mRB" 'rtags-show-rtags-buffer
    "mRI" 'rtags-imenu
    "mRT" 'rtags-taglist
    "mRh" 'rtags-print-class-hierarchy
    "mRa" 'rtags-print-source-arguments
    )
  )


;; For each package, define a function rtags/init-<package-name>
;;
(defun c++/init-rtags ()
  "Initialize my package"
  (use-package rtags
    :init
    ;;(evil-set-initial-state 'rtags-mode 'emacs)
    ;;(rtags-enable-standard-keybindings c-mode-base-map)
    :config
    (progn
      (define-key evil-normal-state-map (kbd "RET") 'rtags-select-other-window)
      (define-key evil-normal-state-map (kbd "M-RET") 'rtags-select)
      (define-key evil-normal-state-map (kbd "q") 'rtags-bury-or-delete)

      (rtags-evil-standard-keybindings 'c-mode)
      (rtags-evil-standard-keybindings 'c++-mode)
      )
    )
  )
