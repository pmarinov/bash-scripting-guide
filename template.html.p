<!doctype html>

◊(local-require racket/string)
◊(local-require threading)

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

◊; Convenience function, obtains Page Title
◊(define (page-title node)
  (if node
      (select 'page-title node)
    ""))

◊; Convenience function, returns HTML form of a .poly.pm page
◊(define (->href page)
  (~> (symbol->string page)
    (string-replace ".poly.pm" ".html")
    (string-replace "pages/" "")))

◊;; Design of the nav bar
◊;; <div class="navbar">
◊;;   <span><div>prev</div><div>title</div></span>
◊;;   <span style='text-align: center'>title</span>
◊;;   <span style='text-align: right'><div>next</div><div>title</div></span>
◊;; </div>

◊; nav-bar:
◊; An instance of a nav-bar
◊(define (nav-bar #:location-top [location-top #t])
  (define (nav-bar-entry to-page link-name)
    (if to-page
      `(@
        (div ,(page-title to-page))
        (div
          (a [[href ,(->href to-page)]] ,link-name)))
      (div "No more")))
  (let* ([page-poly (->poly-node here)]
      [class-location
        (if location-top "separator-top" "separator-bottom")]
      [prev-page (previous page-poly)]
      [next-page (next page-poly)]
      [parent-page (parent page-poly)])
    `(@
      (div [[class ,(string-append "navbar" " " class-location)]]
        ;; Go to prev
        (span [[class "left"]] ,(nav-bar-entry prev-page "Prev"))
        ;; Go to parent
        (span [[class "center"]]
          (div ,this-book-title)
          ,(if parent-page
              `(@
                (div
                  (a [[href ,(->href parent-page)]] "Up")))
            (div)))
        ;; Go to next
        (span [[class "right"]] ,(nav-bar-entry next-page "Next"))))))

◊; TOP nav-bar
◊; (printf "~a~n" (nav-bar))
◊(->html (nav-bar #:location-top #t))

◊; On page0 the H1 is the book title
◊; everywhere else, render H1 from the page description
◊(when (not (or (equal? here 'pages/page0.html) (equal? here 'pages/page0.poly.pm)))
  {<h1>(select-from-metas 'page-description metas)</h1>})

◊(->html doc)

◊; BOTTOM nav-var
◊(->html (nav-bar #:location-top #f))

</body>
</html>
