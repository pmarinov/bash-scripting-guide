#lang racket/base

(require
  racket/base
  racket/list
  racket/string
  pollen/core
  racket/path
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

(define (root . elements)
  (case (current-poly-target)
    [(html)
      (txexpr 'root empty (decode-elements elements
        #:txexpr-elements-proc decode-paragraphs-flow))]
    ;; `else' -- passthrough without changes
    [else (txexpr 'root empty (decode-elements elements))]))

;; Two '\n' mark a paragraph, single '\n' is ignored (doesn't generate
;; "<br/>")
(define (decode-paragraphs-flow elements)
  (decode-paragraphs elements #:linebreak-proc (lambda (x) x)))

;; Define book title
(define (book-title . elements)
  (case (current-poly-target)
    [(texi) (string-append "@c " (string-append* elements))]
    [(html) `(h1 [[class "placeholder-book-title"]] ,@elements)]
    ;; else (txt)
    [else (map string-upcase elements)]))

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

;; Format node for display purposes
(define (node->display node)
  (if (pagenodeish? node)
      (if (string? node)
          (string-append "(s) " node)
        (string-append "(n) " (symbol->string node)))
    (string-append " (x) not a node")))

;; Convert node to string, if not alredy a string
(define (node->string node)
  (if (string? node)
    node
    (symbol->string node)))

;; For a given node, make a menu of HTML links to its direct children
(define (html-node-menu pg-tree top-node)
  ;; Compute depth of a node
  (define (node-depth node depth)
    (cond
      [(string=?
         (node->string node)
         (node->string top-node))
        depth]
      [else (node-depth (parent node pg-tree) (+ depth 1))]))

  (define (menu-make-mentry node)
    (printf "node: ~a ~a~n" (node->display node) (node-depth node 0))
    `(div (a [[href ,(symbol->string node)]] ,(select 'page-title node))))

  ; Create a link to a page (node)
  (append '(@) (map menu-make-mentry (children top-node pg-tree))))
  ; (printf "~a~n" (pagetree->list pg-tree))
  ; (append '(@) (map menu-make-mentry (rest (pagetree->list pg-tree)))))

;; Menu
(define (node-menu top-node)
  (let ([pg-tree (load-pagetree "../index.ptree")])
    (case (current-poly-target)
      [(texi) (texi-node-menu pg-tree top-node)]
      [(html) (html-node-menu pg-tree top-node)]
      ;; else (txt)
      [else (map string-upcase pg-tree)])))

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
    [(html) `(span [[class "placeholder-quotation"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; Section
(define (section section-title)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@section " section-title
          "\n")]
    [(html) `(strong [[class "placeholder-section"]] ,section-title)]
    ;; else (txt)
    [else (string-append* section-title)]))

;; Definition (dfn)
;; Italic in HTML
(define (dfn . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@dfn{"
          (string-append* elements)
          "}")]
    [(html) `(span [[class "placeholder-dfn"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; A term (a word that is not part of Engligh language
;; texi: No representation
;; html: Make it italic
(define (term . elements)
  (case (current-poly-target)
    [(texi)
      ;; Pass the text unchanged
      (string-append* elements)]
    [(html) `(span [[class "placeholder-dfn"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; Emphasize
;; Produces rendering of italic
(define (emphasize . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@emph{"
          (string-append* elements)
          "}")]
    [(html) `(span [[class "placeholder-emphasize"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; Strong
;; Produces rendering of bold
(define (strong . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@strong{"
          (string-append* elements)
          "}")]
    [(html) `(span [[class "placeholder-strong"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; Footnote
(define (footnote . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@footnote{"
          (string-append* elements)
          "}")]
    [(html) `(span [[class "placeholder-footnote"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; File name
(define (fname . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@file{"
          (string-append* elements)
          "}")]
    [(html) `(span [[class "placeholder-fname"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; Command
(define (command . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@command{"
          (string-append* elements)
          "}")]
    [(html) `(span [[class "placeholder-command"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; Command
(define (kbd . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@kbd{"
          (string-append* elements)
          "}")]
    [(html) `(span [[class "placeholder-kbd"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; Code
;; Example: The function returns @code{nil}.
(define (code . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@code{"
          (string-append* elements)
          "}")]
    [(html) `(span [[class "placeholder-code"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

(define (bracketed element)
  (if (equal? element "\n")
      (string-append "!")
    (string-append "[" element "]")))

(define (strip-new-line element)
  (if (equal? element "\n")
      " "
    element))

(define (strip-new-lines elements)
    (map strip-new-line elements))

;; Section-example
;; Start a section for example code, it will be indexed List of Examples
(define (section-example #:anchor anchor . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@section "
          (string-append* (strip-new-lines elements))
          "\n")]
    [(html) `(span [[class "placeholder-section-example"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; Anchored example
;; Start a section for example code, it will be indexed List of Examples
(define (anchored-example #:anchor anchor . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@strong{"
          (string-append* (strip-new-lines elements))
          "}\n")]
    [(html) `(span [[class "placeholder-anchored-example"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; Example
(define (example . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@indentedblock\n"
          "@verbatim\n"
          (string-append* elements)
          "\n"
          "@end verbatim\n"
          "@end indentedblock")]
    [(html) `(span [[class "placeholder-example"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; Note
(define (note . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@indentedblock\n"
          (string-append* elements)
          "\n"
          "@end indentedblock")]
    [(html) `(span [[class "placeholder-note"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; List
(define (list-block #:type [list-type ""] . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@itemize @bullet\n"
          (string-append* elements)
          "\n"
          "@end itemize")]
    [(html) `(span [[class "placeholder-list-block"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

(define (list-entry . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@item "
          (string-append* elements))]
    [(html) `(span [[class "placeholder-list-entry"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; URL
(define (url #:link link . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@url{" link ", "
          (string-append* elements)
          "}")]
    [(html) `(span [[class "placeholder-list-url"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; Abbreviation
(define (abbr #:title title . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@abbr{" title ", "
          (string-append* elements)
          "}")]
    [(html) `(span [[class "placeholder-list-abbr"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; Definition
(define (definition-block #:type definitions-type . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
        (cond
          [(equal? definitions-type "variables")
            "@table @var"]
          [else
            (string-append "ERROR: Unknown definitions-type "
                definitions-type)]
          )
        "\n"
        (string-append* elements)
        "\n"
        "@end table")]
    [(html) `(span [[class "placeholder-definition-block"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

(define (definition-entry #:name definition-name . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@item " definition-name "\n"
          (string-append* elements))]
    [(html) `(span [[class "placeholder-definition-entry"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

(define (escaped . elements)
    (case (current-poly-target)
      [(texi)
        (string-append
            "@" (string-append* elements))]
    [(html) `(span [[class "placeholder-escaped"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))
