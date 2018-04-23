;;; desktop-environment.el --- Helps you control your GNU/Linux computer  -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Damien Cassou

;; Author: Damien Cassou <damien@cassou.me>
;; Url: https://gitlab.petton.fr/DamienCassou/desktop-environment
;; Package-requires: ((emacs "25.1"))
;; Version: 0.2.0

;; This program is free software; you can redistribute it and/or modify
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

;; This package helps you control your GNU/Linux desktop from Emacs.
;; With desktop-environment, you can control the brightness and volume
;; as well as take screenshots and lock your screen.  The package
;; depends on the availability of shell commands to do the hard work
;; for us.  These commands can be changed by customizing the
;; appropriate variables.

;; The global minor mode `desktop-environment-mode' binds standard
;; keys to provided commands: e.g., <XF86AudioRaiseVolume> to raise
;; the volume, <print> to take a screenshot, and <s-l> to lock the
;; screen.

;;; Code:

(defgroup desktop-environment nil
  "Configure desktop-environment."
  :group 'environment)


;;; Customization - brightness

(defcustom desktop-environment-brightness-normal-increment "10%+"
  "Normal brightness increment value."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-brightness-normal-decrement "10%-"
  "Normal brightness decrement value."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-brightness-small-increment "5%+"
  "Small brightness increment value."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-brightness-small-decrement "5%-"
  "Small brightness decrement value."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-brightness-get-command "brightnessctl"
  "Shell command getting current screen brightness level.
If you change this variable, you might want to change
`desktop-environment-brightness-get-regexp' as well."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-brightness-get-regexp "\\([0-9]+%\\)"
  "Regular expression matching brightness value.

This regular expression will be tested against the result of
`desktop-environment-brightness-get-command' and group 1 must
match the current brightness level."
  :type 'regexp
  :group 'desktop-environment)

(defcustom desktop-environment-brightness-set-command "brightnessctl set %s"
  "Shell command setting the brightness level.
The value must contain 1 occurence of '%s' that will be
replaced by the desired new brightness level."
  :type 'string
  :group 'desktop-environment)


;;; Customization - volume

(defcustom desktop-environment-volume-normal-increment "5%+"
  "Normal volume increment value."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-volume-normal-decrement "5%-"
  "Normal volume decrement value."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-volume-small-increment "1%+"
  "Small volume increment value."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-volume-small-decrement "1%-"
  "Small volume decrement value."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-volume-get-command "amixer get Master"
  "Shell command getting current volume level.
If you change this variable, you might want to change
`desktop-environment-volume-get-regexp' as well."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-volume-get-regexp "\\([0-9]+%\\)"
  "Regular expression matching volume value.

This regular expression will be tested against the result of
`desktop-environment-volume-get-command' and group 1 must
match the current volume level."
  :type 'regexp
  :group 'desktop-environment)

(defcustom desktop-environment-volume-set-command "amixer set Master %s"
  "Shell command setting the volume level.
The value must contain 1 occurence of '%s' that will be
replaced by the desired new volume level."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-volume-toggle-command "amixer set Master toggle"
  "Shell command toggling between muted and unmuted."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-volume-toggle-microphone-command "amixer set Capture toggle"
  "Shell command toggling microphone between muted and unmuted."
  :type 'string
  :group 'desktop-environment)


;;; Customization - screenshots

(defcustom desktop-environment-screenshot-command "scrot"
  "Shell command taking a screenshot in the current working directory."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-screenshot-partial-command "scrot -s"
  "Shell command taking a partial screenshot in the current working directory.

The shell command should let the user interactively select the
portion of the screen."
  :type 'string
  :group 'desktop-environment)

(defcustom desktop-environment-screenshot-directory "~/Pictures"
  "Directory where to save screenshots."
  :type 'directory
  :group 'desktop-environment)


;;; Customization - screen locking

(defcustom desktop-environment-screenlock-command "slock"
  "Shell command locking the screen."
  :type 'string
  :group 'desktop-environment)


;;; Helper functions - brightness

(defun desktop-environment-brightness-get ()
  "Return a string representing current brightness level."
  (let ((output (shell-command-to-string desktop-environment-brightness-get-command)))
    (save-match-data
      (string-match desktop-environment-brightness-get-regexp output)
      (match-string 1 output))))

(defun desktop-environment-brightness-set (value)
  "Set brightness to VALUE."
  (shell-command-to-string (format desktop-environment-brightness-set-command value))
  (message "New brightness value: %s" (desktop-environment-brightness-get)))


;;; Helper functions - volume

(defun desktop-environment-volume-get ()
  "Return a string representing current volume level."
  (let ((output (shell-command-to-string desktop-environment-volume-get-command)))
    (save-match-data
      (string-match desktop-environment-volume-get-regexp output)
      (match-string 1 output))))

(defun desktop-environment-volume-set (value)
  "Set volume to VALUE."
  (shell-command-to-string (format desktop-environment-volume-set-command value))
  (message "New volume value: %s" (desktop-environment-volume-get)))


;;; Commands - brightness

;;;###autoload
(defun desktop-environment-brightness-increment ()
  "Increment brightness by `desktop-environment-brightness-normal-increment'."
  (interactive)
  (desktop-environment-brightness-set desktop-environment-brightness-normal-increment))

;;;###autoload
(defun desktop-environment-brightness-decrement ()
  "Increment brightness by `desktop-environment-brightness-normal-decrement'."
  (interactive)
  (desktop-environment-brightness-set desktop-environment-brightness-normal-decrement))

;;;###autoload
(defun desktop-environment-brightness-increment-slowly ()
  "Increment brightness by `desktop-environment-brightness-small-increment'."
  (interactive)
  (desktop-environment-brightness-set desktop-environment-brightness-small-increment))

;;;###autoload
(defun desktop-environment-brightness-decrement-slowly ()
  "Decrement brightness by `desktop-environment-brightness-small-decrement'."
  (interactive)
  (desktop-environment-brightness-set desktop-environment-brightness-small-decrement))


;;; Commands - volume

;;;###autoload
(defun desktop-environment-volume-increment ()
  "Increment volume by `desktop-environment-volume-normal-increment'."
  (interactive)
  (desktop-environment-volume-set desktop-environment-volume-normal-increment))

;;;###autoload
(defun desktop-environment-volume-decrement ()
  "Increment volume by `desktop-environment-volume-normal-decrement'."
  (interactive)
  (desktop-environment-volume-set desktop-environment-volume-normal-decrement))

;;;###autoload
(defun desktop-environment-volume-increment-slowly ()
  "Increment volume by `desktop-environment-volume-small-increment'."
  (interactive)
  (desktop-environment-volume-set desktop-environment-volume-small-increment))

;;;###autoload
(defun desktop-environment-volume-decrement-slowly ()
  "Decrement volume by `desktop-environment-volume-small-decrement'."
  (interactive)
  (desktop-environment-volume-set desktop-environment-volume-small-decrement))

;;;###autoload
(defun desktop-environment-toggle-mute ()
  "Toggle between muted and un-muted."
  (interactive)
  (message "%s"
           (shell-command-to-string desktop-environment-volume-toggle-command)))

;;;###autoload
(defun desktop-environment-toggle-microphone-mute ()
  "Toggle microphone between muted and un-muted."
  (interactive)
  (message "%s"
           (shell-command-to-string desktop-environment-volume-toggle-microphone-command)))


;;; Commands - screenshots

;;;###autoload
(defun desktop-environment-screenshot ()
  "Take a screenshot of the screen in the current working directory."
  (interactive)
  (let ((default-directory (expand-file-name desktop-environment-screenshot-directory)))
    (start-process-shell-command "desktop-environment-screenshot" nil desktop-environment-screenshot-command)))

;;;###autoload
(defun desktop-environment-screenshot-part ()
  "Take a partial screenshot in the current working directory.

The command asks the user to interactively select a portion of
the screen."
  (interactive)
  (let ((default-directory (expand-file-name desktop-environment-screenshot-directory)))
    (message "Please select the part of your screen to shoot.")
    (start-process-shell-command "desktop-environment-screenshot" nil desktop-environment-screenshot-partial-command)))


;;; Commands - screen locking

;;;###autoload
(defun desktop-environment-lock-screen ()
  "Lock the screen, preventing anyone without a password from using the system."
  (interactive)
  (shell-command-to-string desktop-environment-screenlock-command))


;;; Minor mode

(defconst desktop-environment--keybindings
  `(;; Brightness
    (,(kbd "<XF86MonBrightnessUp>") . ,(function desktop-environment-brightness-increment))
    (,(kbd "<XF86MonBrightnessDown>") . ,(function desktop-environment-brightness-decrement))
    (,(kbd "S-<XF86MonBrightnessUp>") . ,(function desktop-environment-brightness-increment-slowly))
    (,(kbd "S-<XF86MonBrightnessDown>") . ,(function desktop-environment-brightness-decrement-slowly))
    ;; Volume
    (,(kbd "<XF86AudioRaiseVolume>") . ,(function desktop-environment-volume-increment))
    (,(kbd "<XF86AudioLowerVolume>") . ,(function desktop-environment-volume-decrement))
    (,(kbd "S-<XF86AudioRaiseVolume>") . ,(function desktop-environment-volume-increment-slowly))
    (,(kbd "S-<XF86AudioLowerVolume>") . ,(function desktop-environment-volume-decrement-slowly))
    (,(kbd "<XF86AudioMute>") . ,(function desktop-environment-toggle-mute))
    (,(kbd "<XF86AudioMicMute>") . ,(function desktop-environment-toggle-microphone-mute))
    ;; Volume
    (,(kbd "S-<print>") . ,(function desktop-environment-screenshot-part))
    (,(kbd "<print>") . ,(function desktop-environment-screenshot))
    ;; Screen locking
    (,(kbd "s-l") . ,(function desktop-environment-lock-screen)))
  "List of (KEY . FUNCTION) in `desktop-environment-mode-map'.")

(defvar desktop-environment-mode-map
  (let ((map (make-sparse-keymap)))
    (mapc
     (lambda (keybinding)
       (define-key map (car keybinding) (cdr keybinding)))
     desktop-environment--keybindings)
    map)
  "Keymap for `desktop-environment-mode'.")

(declare-function exwm-input-set-key "ext:exwm-input")

(defun desktop-environment-exwm-set-global-keybindings ()
  "When using EXWM, add `desktop-environment-mode-map' to global keys."
  (when (featurep 'exwm-input)
    (mapc
     (lambda (keybinding)
       (exwm-input-set-key (car keybinding) (cdr keybinding)))
     desktop-environment--keybindings)))

;;;###autoload
(define-minor-mode desktop-environment-mode
  "Activate keybindings to control your desktop environment.

\\{desktop-environment-mode-map}"
  :global t
  :require 'desktop-environment
  :lighter " DE"
  (desktop-environment-exwm-set-global-keybindings))

(provide 'desktop-environment)
;;; desktop-environment.el ends here
