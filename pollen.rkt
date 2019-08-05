#lang racket/base

(require
  racket/base
  racket/list
  racket/string
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

;;
(define (texi-menu top-node)
  (let ([pg-tree (load-pagetree "index.ptree")])
    (display (string-append "po1: " top-node "\n"))
    (validate-pagetree pg-tree)
    (display (string-append "po2: " (symbol->string (first (pagetree->list pg-tree))) "\n"))
    (display (string-append "po3: " top-node "\n"))
    (case (current-poly-target)
    [(texi) (string-append* (map string-upcase (map symbol->string (children top-node pg-tree))))]
    ; [(texi) "@c"]
    [(txt) (map string-upcase pg-tree)]
    ;; else (html)
    [else (map string-upcase (pagetree->list (current-pagetree)))])))

