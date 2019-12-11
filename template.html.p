<!doctype html>

◊;(local-require racket/list)
◊(local-require racket/string)
◊;(local-require pollen/pagetree)
◊;(local-require debug/repl)

<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>
    ◊(select-from-metas 'page-title metas) |
    ◊;(select-from-metas 'page-description metas) |
    ◊(->html this-book-title)
  </title>
  <link rel="stylesheet" type="text/css" href="../style.css"/>
</head>
<body>

◊(define (->poly-node html-node)
  ;(printf "1: ~a~n" html-node)
  (string-replace (symbol->string html-node) ".html" ".poly.pm"))

◊(define prev-page (previous (->poly-node here)))

◊(define (nav-bar curpage)
  ;(printf "2: ~a~n" curpage)
  (let ([prev-page (previous (->poly-node here))]
      [next-page (next (->poly-node here))])
    (printf "3: ~a~n" prev-page)
    (printf "4: ~a~n" next-page)
    `(@
      (div [[class "navbar"]]
        (span [[class "left"]]
          ,(when prev-page
            `(@
              (div "TITLE")
              (div ,(symbol->string prev-page)))))
        (span "TITLE")
        (span [[class "right"]]
          ,(if next-page
              `(div ,next-page)
            `(div)))))))

◊;; <div class="navbar">
◊;;   <span><div>prev</div><div>title</div></span>
◊;;   <span style='text-align: center'>title</span>
◊;;   <span style='text-align: right'><div>next</div><div>title</div></span>
◊;; </div>

◊;
◊; Define NODE and CHAPTER for each page
◊; (except page0)
◊(printf "~a~n" (nav-bar (->poly-node here)))
◊(->html (nav-bar (->poly-node here)))

◊; On page0 the H1 is the book title
◊; everywhere else, render H1 from the page description
◊(when (not (or (equal? here 'pages/page0.html) (equal? here 'pages/page0.poly.pm)))
  {<h1>(select-from-metas 'page-description metas)</h1>})

◊(->html doc)

◊; TODO: Add page navigation (prev, next, up)
◊;The current page is called ◊|here|.

</body>
</html>
