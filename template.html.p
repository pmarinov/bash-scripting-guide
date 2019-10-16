<!doctype html>

<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>
    ◊(select-from-metas 'page-title metas) --
    ◊(select-from-metas 'page-description metas) |
    ◊(->html this-book-title)
  </title>
  <link rel="stylesheet" type="text/css" href="../style.css"/>
</head>
<body>
◊(->html doc)

The current page is called ◊|here|.

</body>
</html>
