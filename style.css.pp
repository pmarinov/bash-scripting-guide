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

h2, h3, h4, h5, h6 {
  color: ◊|color-title|;
}

h3.section-example {
  color: inherit;
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

code {
  background-color: #f7f7f8;
}

pre.code {
  background-color: #f7f7f8;
  line-height: 1.45;
  padding: 10px;
}

.title-anchored-example {
  font-weight: bold;
}

kbd {
  font-family: monospace;
  color: rgba(0,0,0,.8);
  background: #f7f7f7;
  border: 1px solid #ccc;
  border-radius: 3px;
  box-shadow: 0 1px 0 rgba(0,0,0,.2),0 0 0 .1em #fff inset;
  margin: 0 0.15em;
  padding: 0.2em 0.5em;
  white-space: nowrap;
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

.toc li a:link {
  list-style-type: none;
  color: #2156a5;
  text-decoration: none;
}

dt.def {
  font-weight: bold;
}

.footnotes {
  border-top: 2px lightgray dotted;
  padding-top: 0.25em;
  display: grid;
  grid-gap: 0.2em;
  grid-template-columns: 2.5em 1fr;
}

.quotation {
  font-style: italic;
  max-width: 65%;
}

.navbar {
  font-family: sans-serif;
  font-size: 0.9em;
  display: grid;
  grid-template-columns: 30% 40% 30%;
  color: gray;
}

.separator-top {
  border-bottom: 2px lightgray dotted;
  padding-bottom: 0.4em;
}

.separator-bottom {
  border-top: 2px lightgray dotted;
  margin-top: 2em;
  padding-top: 0.4em;
}

.navbar .left {
}

.navbar .center {
  text-align: center;
}

.navbar .right {
  text-align: right;
}

/* emacs:            */
/* Local Variables:  */
/* mode: css         */
/* End:              */
