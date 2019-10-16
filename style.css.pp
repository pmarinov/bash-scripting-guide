#lang pollen

◊(define color-text "rgba(0,0,0,.85)")
◊(define color-book-title "rgba(0,0,0,.85)")
◊(define color-title "#ba3925")

h1, h2, h3, h4, h5, h6 {
  font-family: sans-serif;
  font-weight: 300;
}

h1 {
	color: ◊|color-book-title|;
}

h2, h3, h4, h5, h6 {
	color: ◊|color-title|;
}

body {
  max-width: 1000px;
  margin-left: auto;
  margin-right: auto;
  color: ◊|color-text|;
  font-family: serif;
}
