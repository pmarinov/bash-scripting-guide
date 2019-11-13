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

;; Collect a list footnotes in a page
;; (Lis of a lists, each note is an x-expression)
(define footnotes null)

;; footnotes-render:
;; Render footnotes as an x-expression to be placed at the bottom of
;; the page
(define (footnotes-render)
  (define (a-footnote note-elements)
    (let ([a-index (+ 1 (index-of footnotes note-elements))])
      ; (printf "~a~n" a-index)
      `(div
        (span [[style "padding-right: 12px"]] ,(format "~a" a-index))
        (span ,@note-elements))))
  (when footnotes
    `((div [[class "footnotes"]]
      ,@(map a-footnote footnotes)))))

(define (root . elements)
  (case (current-poly-target)
    [(html)
      ; (printf "~a~n" elements)
      `(root
        ,@(decode-elements elements
          #:txexpr-elements-proc decode-paragraphs-flow)
        ,@(footnotes-render))]
      ;; (txexpr 'root '() (decode-elements elements
      ;;   #:txexpr-elements-proc decode-paragraphs-flow))]
    ;; `else' -- passthrough without changes
    [else `(root ,@elements)]))

;; Two '\n' mark a paragraph, single '\n' is ignored (doesn't generate
;; "<br/>"), the idea is to do a pass-through for unmodified linebreaks
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

(define (node-strip-page-location node)
  (string-replace node "pages/" ""))

;; node->ref:
;; Converter from node to HTML page name
(define (node->href node-poly-pm)
  (string-replace (node-strip-page-location (symbol->string node-poly-pm)) ".poly.pm" ".html"))

;; For a given node, make a menu of HTML links to its direct children
(define (html-node-menu pg-tree top-node)
  ;; node-link:
  ;; One li entry in an ul list
  (define (node-link node) `(li (a [[href ,(node->href node)]] ,(select 'page-title node))))
  ;; menu-make-mentry:
  ;; Recursively create a menu of links for a node and its children
  (define (menu-make-mentry node)
    ; (printf "menu-make-mentry: ~a ~a~n" (node->display node) depth)
    (let ([node-children (children node pg-tree)])
      ; (printf "~a~n" (node-link node))
      (if node-children
          ;; node-link + ul + nested recursive menu entries
          `(@ ,(node-link node)
            (ul
              ,@(map menu-make-mentry node-children)))
        ;; A node link
        (node-link node))))

  ;; html-node-menu:
  ;; Start with an ul tag for the top level and insert all children
  ;; entries
  `(@
    (ul [[class "toc"]]
      ,@(map menu-make-mentry (children top-node pg-tree)))))

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
    [(html) `(em [[class "placeholder-quotation"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

;; Section
(define (section section-title)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@section " section-title
          "\n")]
    [(html) `(h2 [[class "placeholder-section"]] ,section-title)]
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
    [(html) `(em [[class "placeholder-dfn"]] ,@elements)]
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
    [(html) `(em [[class "placeholder-dfn"]] ,@elements)]
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
    [(html) `(em [[class "placeholder-emphasize"]] ,@elements)]
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
    [(html) `(strong [[class "placeholder-strong"]] ,@elements)]
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
    [(html)
      ;; Collect into footnotes
      (set! footnotes (append footnotes (list elements)))
      ;; Render a link to jump to the footnote
      ; (printf "~a: ~a~n" (length footnotes) footnotes)
      (let* ([fn-index (length footnotes)]
             [fn-index-anchor (format "#~a" fn-index)]
             [fn-index-str (format "[~a]" fn-index)])
        `(a [[href ,fn-index-anchor]] ,fn-index-str))]
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
    [(html) `(code [[class "placeholder-fname"]] ,@elements)]
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
    [(html) `(code [[class "placeholder-command"]] ,@elements)]
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
    [(html) `(code [[class "placeholder-kbd"]] ,@elements)]
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
    [(html) `(code [[class "placeholder-code"]] ,@elements)]
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
    [(html) `(h2 [[id ,anchor]] ,@elements)]
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
    [(html) `(pre [[class "code"]] ,@elements)]
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
    [(html) `(ul [[class "placeholder-list-block"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

(define (list-entry . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@item "
          (string-append* elements))]
    [(html) `(li [[class "placeholder-list-entry"]] ,@elements)]
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
    [(html) `(dl [[class "placeholder-definition-block"]] ,@elements)]
    ;; else (txt)
    [else (string-append* elements)]))

(define (definition-entry #:name definition-name . elements)
  (case (current-poly-target)
    [(texi)
      (string-append
          "@item " definition-name "\n"
          (string-append* elements))]
    [(html)
      `(@
        (dt ,definition-name)
        (dd ,@elements))]
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
