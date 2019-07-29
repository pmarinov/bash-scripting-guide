◊;{A page template for .txt output}

◊(local-require racket/list)
◊(apply string-append (filter string? (flatten doc)))
