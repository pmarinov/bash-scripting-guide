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
  [(texi) (append '("@c"))]
  [(txt) (map string-upcase elements)]
  ;; else (html)
  [else (txexpr 'h1 '() elements)]))

