<!doctype html>

◊(local-require racket/list)
◊(local-require racket/string)
◊(local-require pollen/pagetree)
◊(local-require debug/repl)

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

◊(define prev-page (previous here))
◊(define next-page (next here))

◊(define (nav-bar curpage)
  `(@
  ,(when `(previous ,curpage)
    `(span "PREV"))
  ,(when `(next ,curpage)
    `(span "NEXT"))))

◊;; <div class="navbar">
◊;;   <span><div>prev</div><div>title</div></span>
◊;;   <span style='text-align: center'>title</span>
◊;;   <span style='text-align: right'><div>next</div><div>title</div></span>
◊;; </div>

◊;
◊; Define NODE and CHAPTER for each page
◊; (except page0)
◊(printf "~a~n" (nav-bar here))
◊(->html (nav-bar here))

◊; On page0 the H1 is the book title
◊; everywhere else, render H1 from the page description
◊(when (not (or (equal? here 'pages/page0.html) (equal? here 'pages/page0.poly.pm)))
  {<h1>(select-from-metas 'page-description metas)</h1>})

◊(->html doc)

◊; TODO: Add page navigation (prev, next, up)
◊;The current page is called ◊|here|.

</body>
</html>
