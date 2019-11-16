<!doctype html>

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

◊; On page0 the H1 is the book title
◊; everywhere else, render H1 from the page description
◊(when (not (or (equal? here 'pages/page0.html) (equal? here 'pages/page0.poly.pm)))
  {<h1>(select-from-metas 'page-description metas)</h1>})

◊(->html doc)

◊; TODO: Add page navigation (prev, next, up)
◊;The current page is called ◊|here|.

</body>
</html>
