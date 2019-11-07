#lang pollen

◊(define color-text "rgba(0,0,0,.85)")
◊(define color-book-title "rgba(0,0,0,.85)")
◊(define color-title "#ba3925")

h1, h2, h3, h4, h5, h6 {
  font-family: sans-serif;
}

h1 {
  color: ◊|color-book-title|;
  margin-top: 0.5em;
  margin-bottom: 0.5em;
}

h1, h2 {
  letter-spacing: -0.01em;
  word-spacing: -0.05em;
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
  line-height: 1.6
}

p {
  margin-bottom: 1.25em;
}

pre.code {
  background-color: #f7f7f8;
  line-height: 1.45;
  padding: 10px;
}

ul.toc {
  background-color: #f7f7f8;
  line-height: 1.6;
  padding: 1.25em;
  list-style-type: none;
  font-family: sans-serif;
}

.toc li {
  list-style-type: none;
}

.toc li a {
  list-style-type: none;
  color: ◊|color-text|;
  text-decoration: none;
}
