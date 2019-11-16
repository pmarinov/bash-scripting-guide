#lang pollen

◊(require racket/math)
◊(require pollen/pagetree)

◊define-meta[page-title]{Top}
◊define-meta[page-description]{Page0}
◊book-title{◊this-book-title}

Original edition by Mendel Cooper, dedicated to the Public Domain

◊strong{An in-depth exploration of the art of shell scripting.}

This tutorial assumes no previous knowledge of scripting or
programming, yet progresses rapidly toward an intermediate/advanced
level of instruction... ◊emphasize{all the while sneaking in little
nuggets of UNIX® wisdom and lore.} It serves as a textbook, a manual
for self-study, and as a reference and source of knowledge on shell
scripting techniques. The exercises and heavily-commented examples
invite active reader participation, under the premise that
◊emphasize{the only way to really learn scripting is to write
scripts.}

This book is suitable for classroom use as a general introduction to
programming concepts.

◊; List pages under page0.poly.pm
◊(node-menu "pages/page0.poly.pm")
