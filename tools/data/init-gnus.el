;;; package --- init-gnus
;;; Commentary:
;;; sourced from http://blog.binchen.org/posts/notes-on-using-gnus.html
;;; Code:
(require-package 'epg)
(require-package 'w3m)
(require-package 'epa-file)
(require 'epa)
(require 'epa-file)
(require 'nnir)
(require 'w3m)
(require 'nnir)

(require 'epg)
(setq mml2015-use 'epg
      mml2015-verbose t
      epg-user-id "846D8CB0"
      mml2015-signers '("846D8CB0")
      mml2015-encrypt-to-self t
      mml2015-always-trust nil
      mml2015-cache-passphrase t
      mml2015-passphrase-cache-expiry '36000
      mml2015-sign-with-sender t

      gnus-message-replyencrypt t
      gnus-message-replysign t
      gnus-message-replysignencrypted t
      gnus-treat-x-pgp-sig t

      ;;mm-sign-option 'guided
      ;;mm-encrypt-option 'guided
      mm-verify-option 'always
      mm-decrypt-option 'always

      gnus-buttonized-mime-types
      '("multipart/alternative"
        "multipart/encrypted"
        "multipart/signed")

      epg-debug t ;;  then read the *epg-debug*" buffer
      )

(setq starttls-use-gnutls t
      starttls-gnutls-program "gnutls-cli"
      starttls-extra-arguments '("--strict-tofu"))

(setq message-required-news-headers
      (nconc message-required-news-headers
             (list '(Face . (lambda ()
                              (gnus-face-from-file "~/.emacs.d/xface.png"))))))

(setq message-required-news-headers
      (nconc message-required-news-headers
             (list '(X-Face . (lambda ()
                                (gnus-x-face-from-file
                                 "~/.emacs.d/xface.png"))))))


;; Specify the altitude of Face and X-Face images in the From header.
(setq gnus-face-properties-alist
      '((pbm . (:face gnus-x-face :ascent 80))
        (png . (:ascent 80))))

;; Show Face and X-Face images as pressed buttons.
(setq gnus-face-properties-alist
      '((pbm . (:face gnus-x-face :relief -2))
        (png . (:relief -2))))



;;@see http://www.emacswiki.org/emacs/GnusGmail#toc1
(setq gnus-select-method '(nntp "news.gmane.org"))

;; ask encyption password once
(setq epa-file-cache-passphrase-for-symmetric-encryption t)

(setq smtpmail-auth-credentials "~/.authinfo.gpg")

(setq-default
 gnus-summary-line-format "%U%R%z %(%&user-date;  %-15,15f  %B%s%)\n"
 gnus-user-date-format-alist '((t . "%Y-%m-%d %H:%M"))
 gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references
 gnus-sum-thread-tree-false-root ""
 gnus-sum-thread-tree-indent ""
 gnus-sum-thread-tree-leaf-with-other "-> "
 gnus-sum-thread-tree-root ""
 gnus-sum-thread-tree-single-leaf "|_ "
 gnus-sum-thread-tree-vertical "|")

(setq gnus-thread-sort-functions
      '(
        (not gnus-thread-sort-by-date)
        (not gnus-thread-sort-by-number)
        ))

;; NO 'passive
(setq gnus-use-cache t)
(setq gnus-use-adaptive-scoring t)
(setq gnus-save-score t)
(add-hook 'mail-citation-hook 'sc-cite-original)
(add-hook 'message-sent-hook 'gnus-score-followup-article)
(add-hook 'message-sent-hook 'gnus-score-followup-thread)
;; @see http://stackoverflow.com/questions/945419/how-dont-use-gnus-adaptive-scoring-in-some-newsgroups
(setq gnus-parameters
      '(("nnimap.*"
         (gnus-use-scoring nil))
        ))

(defvar gnus-default-adaptive-score-alist
  '((gnus-kill-file-mark (from -10))
    (gnus-unread-mark)
    (gnus-read-mark (from 10) (subject 30))
    (gnus-catchup-mark (subject -10))
    (gnus-killed-mark (from -1) (subject -30))
    (gnus-del-mark (from -2) (subject -15))
    (gnus-ticked-mark (from 10))
    (gnus-dormant-mark (from 5))))

(setq  gnus-score-find-score-files-function
       '(gnus-score-find-hierarchical gnus-score-find-bnews bbdb/gnus-score))

;; BBDB: Address list
(when (file-exists-p "/usr/share/emacs/site-lisp/bbdb3")
  (add-to-list 'load-path "/usr/share/emacs/site-lisp/bbdb3")
  (require 'bbdb)
  (bbdb-initialize 'message 'gnus 'sendmail)
  (setq bbdb-file "~/.emacs.d/bbdb.db")
  (add-hook 'gnus-startup-hook 'bbdb-insinuate-gnus)
  (setq bbdb/mail-auto-create-p t
        bbdb/news-auto-create-p t)
  (defvar bbdb-time-internal-format "%Y-%m-%d"
    "The internal date format.")
  ;;;###autoload
  (defun bbdb-timestamp-hook (record)
    "For use as a `bbdb-change-hook'; maintains a notes-field called `timestamp'
    for the given record which contains the time when it was last modified.  If
    there is such a field there already, it is changed, otherwise it is added."
    (bbdb-record-putprop record 'timestamp (format-time-string
                                            bbdb-time-internal-format
                                            (current-time))))
  )

(add-hook 'message-mode-hook
          '(lambda ()
             (flyspell-mode t)
             (local-set-key "<TAB>" 'bbdb-complete-name)))

;; Fetch only part of the article if we can.  I saw this in someone
;; else's .gnus
(setq gnus-read-active-file 'some)

;; Tree view for groups.  I like the organisational feel this has.
(add-hook 'gnus-group-mode-hook 'gnus-topic-mode)

;; Threads!  I hate reading un-threaded email -- especially mailing
;; lists.  This helps a ton!
(setq gnus-summary-thread-gathering-function
      'gnus-gather-threads-by-subject)

;; Also, I prefer to see only the top level message.  If a message has
;; several replies or is part of a thread, only show the first
;; message.  'gnus-thread-ignore-subject' will ignore the subject and
;; look at 'In-Reply-To:' and 'References:' headers.
(setq gnus-thread-hide-subtree t)
(setq gnus-thread-ignore-subject t)

;; Personal Information
(setq user-full-name "nicolas couture"
      user-mail-address "nicolas@couture.rocks"
      message-generate-headers-first t)

;; Change email address for work folder.  This is one of the most
;; interesting features of Gnus.  I plan on adding custom .sigs soon
;; for different mailing lists.
;; Usage, FROM: My Name <work>
(setq gnus-posting-styles
      '((".*"
         (name "nicolas couture")
         (address "nicolas@couture.rocks")
         (organization "Church of Emacs")
         (signature-file "~/.signature")
         (x-face-file "~/.xface")
         ("Organization" "Church of Emacs"))))

(setq message-user-organization "Church of Emacs")

;; You need install the command line brower 'w3m' and Emacs plugin 'w3m'
(setq mm-text-html-renderer 'gnus-w3m)

(setq gnus-select-method
      '(nnimap "googlemail"
               (nnimap-address "imap.google.com")
               (nnimap-server-port 993)
               (nnimap-stream ssl)))

(setq send-mail-function    'smtpmail-send-it
      smtpmail-smtp-server  "smtp.gmail.com"
      smtpmail-stream-type  'ssl
      smtpmail-smtp-service 465)

(add-to-list 'gnus-secondary-select-methods
             '(nntp "news.gwene.org"))
(add-to-list 'gnus-secondary-select-methods
             '(nntp "news.easynews.com"))
(add-to-list 'gnus-secondary-select-methods
             '(nnimap "imap.gmail.com"
                      (nnimap-address "imap.gmail.com")
                      (nnimap-server-port 993)
                      (nnimap-stream ssl)
                      (nnimap-authenticator login)))

(setq gnus-use-correct-string-widths nil)

(provide 'gnus)
;;; gnus.el ends heres
