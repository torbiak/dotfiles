;;; package.el
(require 'package)
(add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;;; use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-and-compile
  (setq use-package-always-ensure t
        use-package-expand-minimally t))

(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . markdown-mode)
  ;; Individual list items in markdown are defined as paragraphs,
  ;; which really messes me up, since I move by paragraphs constantly.
  :bind (:map markdown-mode-map
         ("M-{" . markdown-backward-block)
         ("M-}" . markdown-forward-block)
         ("M-h" . markdown-mark-block)))

;; https://github.com/mkleehammer/surround
(use-package surround
  :ensure t
  :bind-keymap ("M-'" . surround-keymap))

;;; Put customized variables in their own file.
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file 'noerror)

;;; GUI
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
;; With dwm I can't unsuspend a frame.
(when (display-graphic-p)
    (global-unset-key (kbd "C-z")))

;;; Backups
;; Save backups and autosaves under ~/tmp/emacs.
(setq backup-directory-alist `(("." . "~/tmp/emacs/backup")))
(mkdir "~/tmp/emacs/autosave/" t)
(setq auto-save-file-name-transforms
  `((".*" "~/tmp/emacs/autosave/" t)))
(setf kill-buffer-delete-auto-save-files t)

;;; Misc
(setq-default help-window-select t)     ; Select the help window.
(repeat-mode t)
(delete-selection-mode t)               ; self-insert commands replace an active region.
(global-whitespace-mode t)
(global-auto-revert-mode t)
(fido-vertical-mode t)
(column-number-mode t)                  ; add column number to modeline

;;; Python
(setq-default python-check-command "mypy")
(defun jat/python-mode-hook ()
  (setq tab-width 4))
(add-hook 'python-mode-hook 'jat/python-mode-hook)

;;; Fonts
(set-face-attribute 'fixed-pitch-serif nil :family  "Monospace")
(let ((height (if (string= (system-name) "jair") 90 140)))
  (set-face-attribute 'default nil :height height))

;;; Indentation
(setq-default indent-tabs-mode nil)
(setq whitespace-style '(face trailing tabs tab-mark))
(setq-default tab-width 4)

;;; isearch
;; In isearch, have DEL always remove characters from the search
;; string, instead of first visiting past locations. Avoids the need
;; for C-M-d.
(define-key isearch-mode-map [remap isearch-delete-char] 'isearch-del-char)

;; Open the buffer menu in the current window, instead of another one
;; like list-buffers does.
(global-set-key (kbd "C-x C-b") 'buffer-menu)

;;; Movement Don't require two spaces after a period to end a sentence
;;; for M-a/M-e movement, among other things.
(setq-default sentence-end-double-space nil)
;; Override the defaults for {next,previous}-error, since M-g really
;; strains the fingers.
(global-set-key (kbd "M-_") 'previous-error)
(global-set-key (kbd "M-+") 'next-error)


;;; Window movement
(global-set-key (kbd "C-c h")  'windmove-left)
(global-set-key (kbd "C-c l") 'windmove-right)
(global-set-key (kbd "C-c k")    'windmove-up)
(global-set-key (kbd "C-c j")  'windmove-down)

;;; Format tables with columns separated by two or more spaces. Isn't
;;; idempotent since it doesn't keep at least two spaces, though.
(add-hook 'align-load-hook
          (lambda ()
            (add-to-list 'align-rules-list
                         '(text-column-whitespace
                           (regexp . "\\(\\s-\\{2,\\}\\)")
                           (group  . 1)
                           (modes  . align-text-modes)
                           (repeat . t)))))

;;; Active Babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)))

;;; Append to register ?a
(defun jat/append-to-reg-a ()
  (interactive)
  (if (use-region-p)
      (append-to-register ?a (region-beginning) (region-end))
    (append-to-register ?a (line-beginning-position) (line-end-position))))
(global-set-key (kbd "C-c a")  'jat/append-to-reg-a)
;; Use a separator when appending to a register.
(setq register-separator ?+)
(set-register register-separator "\n")

;;; Shift-style indentation
(defun jat/shift-right (arg)
  "Shift the current line or region right by a multiple of tab-width."
  (interactive "p")
  (let ((deactivate-mark nil)           ; Keep an active region active.
        (n (* arg tab-width)))
      (cond
       ((use-region-p) (save-mark-and-excursion
                         (indent-rigidly (region-beginning) (region-end) n)))
       ((jat/blank-line-p) (let ((col (+ (current-indentation) n)))
                             (delete-horizontal-space t)
                             (indent-to col)))
       (t (save-mark-and-excursion
            (indent-rigidly (line-beginning-position) (line-end-position) n))))))
;; Override tab-to-tab-stop, since I always want to shift by tab-width
;; and never want to customize my tab stops.
(global-set-key (kbd "M-i") 'jat/shift-right)

(defun jat/blank-line-p ()
  (= (current-indentation)
     (- (line-end-position) (line-beginning-position))))

(defun jat/shift-left (arg)
  "Shift the current line or region left by tab-width."
  (interactive "p")
  (jat/shift-right (- arg)))
(global-set-key (kbd "M-I") 'jat/shift-left)

(defun jat/copy-line (arg)
  "Copy lines (as many as prefix argument) in the kill ring.
      Ease of use features:
      - Move to start of next line.
      - Appends the copy on sequential calls.
      - Use newline as last char even on the last line of the buffer.
      - If region is active, copy its lines."
  (interactive "p")
  (let ((beg (line-beginning-position))
        (end (line-end-position arg)))
    (when mark-active
      (if (> (point) (mark))
          (setq beg (save-excursion (goto-char (mark)) (line-beginning-position)))
        (setq end (save-excursion (goto-char (mark)) (line-end-position)))))
    (if (eq last-command 'jat/copy-line)
        (kill-append (buffer-substring beg end) (< end beg))
      (kill-ring-save beg end)))
  (kill-append "\n" nil)
  (beginning-of-line (or (and arg (1+ arg)) 2))
  (if (and arg (not (= 1 arg))) (message "%d lines copied" arg)))
;;; Bind to M-k (overwriting kill-sentence) to be analagous to
;;; C-w/M-w. While I do sometimes want to copy sentences, copying lines
;;; is much, much more common.
(global-set-key (kbd "M-k") 'jat/copy-line)

(defun jat/kill-region-or-thing-at-point (beg end)
  "If a region is active kill it, or kill the thing (word/symbol) at point"
  (interactive "r")
  (unless (region-active-p)
    (save-excursion
      (setq beg (re-search-backward "\\_<" nil t))
      (setq end (re-search-forward "\\_>" nil t))))
  (kill-ring-save beg end))
(global-set-key (kbd "M-w") 'jat/kill-region-or-thing-at-point)

(defun jat/kill-region-or-backward-word ()
  "If the region is active and non-empty, call `kill-region'.
  Otherwise, call `backward-kill-word'."
  (interactive)
  (call-interactively
   (if (use-region-p) 'kill-region 'backward-kill-word)))
(global-set-key (kbd "C-w") 'jat/kill-region-or-backward-word)

(defun jat/switch-to-alternate-buffer ()
  "Switch back and forth between the current and previous buffer in
the current window."
  ;; Adapted from https://emacs.stackexchange.com/questions/18042/is-there-a-command-to-alternate-buffers
  (interactive)
  ;; The current buffer can also be the previous buffer if the
  ;; "previous" previous buffer was killed, so filter out the current
  ;; buffer.
  (let ((bufs (seq-filter (lambda (elt) (not (eq (current-buffer) (car elt))))
                          (window-prev-buffers))))
    (switch-to-buffer (caar bufs))))
(global-set-key (kbd "C-c b") 'jat/switch-to-alternate-buffer)

(defun jat/insert-buffer-file-name-absolute ()
  "Insert the name of the file the current buffer is based on."
  (interactive)
  (insert (buffer-file-name (window-buffer (minibuffer-selected-window)))))
(global-set-key (kbd "C-c F") 'jat/insert-buffer-file-name-absolute)

(defun jat/insert-buffer-file-name-relative ()
  "Insert the name of the file the current buffer is based on."
  (interactive)
  (insert (file-relative-name (buffer-file-name (window-buffer (minibuffer-selected-window))))))
(global-set-key (kbd "C-c f") 'jat/insert-buffer-file-name-relative)

(defun jat/exec-file ()
  "Execute the current file using the shell."
  (interactive)
  (save-buffer)
  (shell-command (buffer-file-name)))
(global-set-key (kbd "C-c r") 'jat/exec-file)

(defun jat/chmod-exec ()
  "Make the current file executable."
  (interactive)
  (chmod (buffer-file-name) #o755))

(defun jat/forward-nonws (arg)
  "Move to the end of the next sequence of non-whitespace characters."
  (interactive "p")
  (let ((ws "\\([ \t\r\n]\\|\\'\\)+")
        (nonws "[^ \t\r\n]+"))
    (dotimes (i (abs arg))
      (re-search-forward nonws nil t)
      (re-search-forward ws nil t)
      (goto-char (match-beginning 0)))
    (point)))
(global-set-key (kbd "M-P") 'jat/forward-nonws)

(defun jat/backward-nonws (arg)
  "Move to the start of the previous sequence of non-whitespace characters."
  (interactive "p")
  (let ((ws "\\([ \t\r\n]\\|\\`\\)+")
        (nonws "[^ \t\r\n]+"))
    (dotimes (i (abs arg))
      (re-search-backward nonws nil t)
      (re-search-backward ws nil t)
      (goto-char (match-end 0)))
    (point)))
(global-set-key (kbd "M-O") 'jat/backward-nonws)

(defun jat/kill-nonws (arg)
  "Kill to the end of the next sequence of non-whitespace characters."
  (interactive "p")
  (kill-region (point) (jat/forward-nonws arg)))
(global-set-key (kbd "M-p") 'jat/kill-nonws)

(defun jat/backward-kill-nonws (arg)
  "Kill to the start of the previous sequence of non-whitespace characters."
  (interactive "p")
  (kill-region (point) (jat/backward-nonws arg)))
(global-set-key (kbd "M-o") 'jat/backward-kill-nonws)

(defun jat/complete-mb-prop ()
  (interactive)
  (when(eq jat/mb-props nil)
    (setq jat/mb-props (jat/read-lines "/home/jtorbiak/proj/chinese/props")))
  (insert
   (completing-read "Prop: " jat/mb-props nil "confirm" nil 'jat/mb-props-hist)))
(setq jat/mb-props nil)
(setq jat/mb-props-hist nil)
(define-key text-mode-map (kbd "C-c p") 'jat/complete-mb-prop)

(defun jat/read-lines (filePath)
  "Return a list of lines of a file at filePath."
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) "\n" t)))

(defun jat/open-line-above ()
  "Starts a new line above the current line."
  (interactive)
  (move-beginning-of-line 1)
  (newline)
  (forward-line -1)
  (indent-according-to-mode))
(global-set-key (kbd "C-o") 'jat/open-line-above)

;;; Jobs mode
(define-minor-mode jobs-mode
  "Job mode."
  ;; The initial value.
  nil
  ;; The indicator for the mode line.
  " Jobs"
  ;; The minor mode bindings.
  '(("\C-ct" . jat/jobs-append-timestamp)
    ("\C-cg" . jat/jobs-find-related)))
;;(add-to-list 'auto-mode-alist '("\\/jobs\\'" . jobs-mode))

(defun jat/jobs-append-timestamp ()
  (interactive)
  (let* ((read-answer-short t)
         (what (read-answer "What? "
                            '(("applied" ?a "applied date")
                              ("rejected" ?r "rejected date"))))
         (ts (format " %s=%s" what (format-time-string "%Y-%m-%d"))))
    (save-excursion
      (save-restriction
        (if (use-region-p)
            (narrow-to-region (region-beginning) (region-end))
          (narrow-to-region (line-beginning-position) (line-end-position)))
        (goto-char (point-min))
        (while (< (point) (point-max))
          (when (not (jat/blank-line-p))
            (goto-char (line-end-position))
            (insert ts))
          (forward-line))))))

(defun jat/jobs-find-related ()
  (interactive)
  (let* ((job (substring (thing-at-point 'list) 1 -1))
         (read-answer-short t)
         (what (read-answer "What? "
                           '(("listing" ?l "job description")
                             ("coverletter" ?c "coverletter")
                             ("prep" ?p "interview prep"))))
        (file (cond
               ((string= what "listing") (format "~/proj/job2024/listings/%s.txt" job))
               ((string= what "coverletter") (format "~/jlp/resume/coverletters/%s.md" job))
               ((string= what "prep") (format "~/jlp/resume/prep/%s.md" job)))))
    (find-file file)))
