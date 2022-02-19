# Advanced Bash-Scripting Guide

(New Edition based on Pollen)

Advanced Bash-Scripting Guide in HTML:
https://hangar118.sdf.org/p/bash-scripting-guide/

Home page: https://hangar118.sdf.org/p/bash-scripting-guide-home/

## About

The *Advanced Bash-Scripting Guide* is a book written by Mendel Cooper
and part of The Linux Documentation Project (see
[Guides](http://tldp.org/guides.html)). **This is a fork** of the
original work which itself had been (since 2014) dedicated to the
**Public Domain**.

Motivation for the new edition:

* To produce a modern-looking HTML format
* To produce a GNU Info format, readable inside Emacs
* To use Pollen as a publishing system, see ["Pollen: the book
  is a program"](https://docs.racket-lang.org/pollen/index.html)
* To invite contributions by hosting on GitHub

## How to build

Use `apt` to install `racket`:

```
$ apt install racket

$ racket --version
```

Racket v7.0 is minimum

Use `raco pkg` to install Pollen:

```
$ raco pkg install pollen
```

Installs in `~/.racket/7.2/pkgs`

To read the documentation:

```
$ raco docs pollen
```

Also the book "Pollen: the book is a program" is at:
`~/.racket/7.2/pkgs/pollen/pollen/doc/pollen/index.html`

One more package:

```
$ raco pkg install debug
```

Install `makeinfo`

```
$ apt install texinfo
```

Now build the project via `make`:

```
$ make all
```

TODO: Describe output folders

## License

Public Domain, see
[LICENSE.txt](https://github.com/pmarinov/bash-scripting-guide/blob/master/LICENSE.txt)

## Changelog

2019-11-17, v0.2.0, pmarinov

* First 2 chapters formatted for GNU Info reader and in HTML
