#lang pollen

◊define-meta[page-title]{Introduction}
◊define-meta[page-description]{What is a UNIX shell}

◊; TODO: display: Part 1. Introduction

◊quotation[#:author "Webster's Dictionary, 1913 ed."]{
Script: A writing; a written document. [Obs.]
}

The shell is a command interpreter. More than just the insulating
layer between the operating system kernel and the user, it's also a
fairly powerful programming language. A shell program, called a
@dfn{script}, is an easy-to-use tool for building applications by "gluing
together" system calls, tools, utilities, and compiled
binaries. Virtually the entire repertoire of UNIX commands, utilities,
and tools is available for invocation by a shell script. If that were
not enough, internal shell commands, such as testing and loop
constructs, lend additional power and flexibility to scripts. Shell
scripts are especially well suited for administrative system tasks and
other routine repetitive tasks not requiring the bells and whistles of
a full-blown tightly structured programming language.

◊; List pages under introduction.poly.pm
◊(node-menu "pages/introduction.poly.pm")
