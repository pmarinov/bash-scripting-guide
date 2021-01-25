#lang pollen

◊; This is free software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Text Processing}
◊define-meta[page-description]{Text Processing Commands}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "sort"]{
File sort utility, often used as a filter in a pipe. This command
sorts a text stream or file forwards or backwards, or according to
various keys or character positions. Using the ◊code{-m} option, it
merges presorted input files. The info page lists its many
capabilities and options. See TODO Example 11-10, Example 11-11, and
Example A-8.

}

◊definition-entry[#:name "tsort"]{
Topological sort, reading in pairs of whitespace-separated strings and
sorting according to input patterns. The original purpose of
◊command{tsort} was to sort a list of dependencies for an obsolete
version of the ◊command{ld} linker in an "ancient" version of UNIX.

The results of a ◊command{tsort} will usually differ markedly from
those of the standard ◊command{sort} command, above.

}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
