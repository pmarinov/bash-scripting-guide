#lang racket/base

(require
  racket/base
  racket/list
  racket/string
  pollen/core
  pollen/decode
  pollen/setup
  pollen/pagetree
  txexpr)

(provide (all-defined-out))

;;
(require debug/repl)

;; 3 output formats -- HTML, Info texi, Plain text
(module setup racket/base
  (provide (all-defined-out))
  (define poly-targets '(html texi txt)))

(define this-book-title "Advanced Bash-Scripting Guide")

;; Define book title
(define (book-title . elements)
  (case (current-poly-target)
    [(texi) (string-append "@c " (string-append* elements))]
    [(txt) (map string-upcase elements)]
    ;; else (html)
    [else (txexpr 'h1 '() elements)]))

(define (texi-make-mentry node)
  (let* ([str-node-title (select 'page-title node)]
        [str-node-desc (select 'page-description node)]
        [str-entry (string-append "* " str-node-title "::\t" str-node-desc)])
    str-entry))

;; For a given node, make a texi menu of all of its direct children
(define (texi-node-menu pg-tree top-node)
  (let* ([str-mentries (string-join (map texi-make-mentry (children top-node pg-tree)) "\n")])
    (string-append
      "@menu\n"
      str-mentries
      "\n"
      "@end menu\n")))

;; Menu
(define (node-menu top-node)
  (let ([pg-tree (load-pagetree "../index.ptree")])
    (case (current-poly-target)
      [(texi) (texi-node-menu pg-tree top-node)]
      [(txt) (map string-upcase pg-tree)]
      ;; else (html)
      [else (map string-upcase (pagetree->list (current-pagetree)))])))

;; Quotation
(define (quotation #:author [author #f] . elements)
    (case (current-poly-target)
      [(texi)
        (string-append
            "@quotation\n"
            (string-append* elements)
            "\n"
            (when author (string-append "@author " author "\n"))
            "@end quotation")]
      [(txt) (display "ERROR: quotation is not ready!")]
      ;; else (html)
      [else (display "ERROR: quotation is not ready!")]))

;; Section
(define (section section-title)
    (case (current-poly-target)
      [(texi)
        (string-append
            "@section " section-title
            "\n")]
      [(txt) (display "ERROR: section is not ready!")]
      ;; else (html)
      [else (display "ERROR: section is not ready!")]))

;; Definition (dfn)
(define (dfn . elements)
    (case (current-poly-target)
      [(texi)
        (string-append
            "@dfn{"
            (string-append* elements)
            "}")]
      [(txt) (display "ERROR: dfn is not ready!")]
      ;; else (html)
      [else (display "ERROR: dfn is not ready!")]))

;; Footnote
(define (footnote . elements)
    (case (current-poly-target)
      [(texi)
        (string-append
            "@footnote{"
            (string-append* elements)
            "}")]
      [(txt) (display "ERROR: dfn is not ready!")]
      ;; else (html)
      [else (display "ERROR: dfn is not ready!")]))

;; File name
(define (fname . elements)
    (case (current-poly-target)
      [(texi)
        (string-append
            "@file{"
            (string-append* elements)
            "}")]
      [(txt) (display "ERROR: file is not ready!")]
      ;; else (html)
      [else (display "ERROR: file is not ready!")]))

;; Note
(define (note . elements)
    (case (current-poly-target)
      [(texi)
        (string-append
            "@indentedblock\n"
            (string-append* elements)
            "\n"
            "@end indentedblock")]
      [(txt) (display "ERROR: file is not ready!")]
      ;; else (html)
      [else (display "ERROR: file is not ready!")]))

;; List
(define (list-block #:type [list-type ""] . elements)
    (case (current-poly-target)
      [(texi)
        (string-append
            "@itemize @bullet\n"
            (string-append* elements)
            "\n"
            "@end itemize")]
      [(txt) (display "ERROR: list-block is not ready!")]
      ;; else (html)
      [else (display "ERROR: list is not ready!")]))

(define (list-entry . elements)
    (case (current-poly-target)
      [(texi)
        (string-append
            "@item "
            (string-append* elements))]
      [(txt) (display "ERROR: list-entry is not ready!")]
      ;; else (html)
      [else (display "ERROR: list-entry is not ready!")]))

;; URL
(define (url #:link link . elements)
    (case (current-poly-target)
      [(texi)
        (string-append
            "@url{" link ", "
            (string-append* elements)
            "}")]
      [(txt) (display "ERROR: url is not ready!")]
      ;; else (html)
      [else (display "ERROR: url is not ready!")]))
