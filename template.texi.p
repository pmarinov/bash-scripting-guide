◊;{A page template for .texi output}

◊(local-require racket/list)
◊(local-require racket/string)
◊(local-require pollen/pagetree)
◊(local-require debug/repl)

◊; The variable 'here' is in .texi format, we need it as .poly.pm for
◊; the navigation functions to work
◊(define (->poly-node texi-node)
    (string-replace (symbol->string texi-node) ".texi" ".poly.pm"))

◊(define phere (->poly-node here))

◊(define (prev-node) (previous phere))
◊(define (next-node) (next phere))
◊(define (parent-node) (parent phere))

◊(define (page-title node)
  (display (string-append "+node: " (symbol->string node) "\n"))
  (if (equal? node 'page0.poly.pm)
      ""
    (select 'page-title node)))

◊(define (parent-node-str)
  (let ([parent1 (parent-node)])
    (select 'page-title parent1)))

◊(define (next-node-str)
   (let ([next1 (next-node)])
     (if next1
         (string-append (select 'page-title next1))
       (string-append ""))))

◊(define (prev-node-str)
   (let ([prev1 (prev-node)])
     (if prev1
         (page-title prev1)
       "")))

◊;
◊; For every page except page0, define node and chapter
◊(when (not (or (equal? here 'page0.texi) (equal? here 'page0.poly.pm)))
   (string-append
       "@c " (symbol->string here) "\n"
       "@c Include file for '" this-book-title "'\n"
       "\n"
       "@node " (page-title here) ", "
       (next-node-str) ", "
       (prev-node-str) ", "
       (parent-node-str) "\n"
       "@chapter " (select-from-metas 'page-description metas) "\n"))

◊; Let page0 be the special node Top
◊(when (equal? here 'page0.texi)
     (string-append
         "\\input texinfo\n"
         "@settitle " this-book-title "\n"
         "@node Top\n"
         "top Zzz\n"))

◊;
◊; THE MAIN contents of the page
◊(apply string-append (filter string? (flatten doc)))

◊(define (->texi-page poly-pg)
  (string-replace poly-pg "poly.pm" "texi"))

◊(define (prepend-include e)
  (string-append "@include "
    ; Each entry is in form filenanme.poly.pm, make it a .texi
    (->texi-page (symbol->string e))
    "\n"))

◊(define (all-nodes)
  ; "rest()" skips the element "root"
  (map prepend-include (rest (pagetree->list (current-pagetree)))))

◊;
◊; In page0, generate list of include directives for all the .texi pages
◊(if (equal? here 'page0.texi)
     ; List of include directives
     (string-append
       "@c Every node is in an individual file\n"
       (apply string-append (all-nodes))
       "\n"
       "@c The entire project is represented as include files in page0\n"
       "@bye\n")
   ; Simply mark the end of a node
   (string-append "@c End of node " (select-from-metas 'page-title metas) "\n"))
