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

;; Dot is a rest argument, all arguments past book-title are combined
;; in a list parameter elements
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
  (let* ([pg-tree (load-pagetree "index.ptree")]
        [str-mentries (string-join (map texi-make-mentry (children top-node pg-tree)) "\n")])
    (string-append
      "@menu\n"
      str-mentries
      "\n"
      "@end menu\n")))

;;
(define (node-menu top-node)
  (let ([pg-tree (load-pagetree "index.ptree")])
    (case (current-poly-target)
      [(texi) (texi-node-menu pg-tree top-node)]
      [(txt) (map string-upcase pg-tree)]
      ;; else (html)
      [else (map string-upcase (pagetree->list (current-pagetree)))])))

