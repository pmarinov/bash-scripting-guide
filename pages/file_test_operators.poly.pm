#lang pollen

◊define-meta[page-title]{File tests}
◊define-meta[page-description]{File test operators}

◊section{Returns true if...}

◊definition-block[#:type "code"]{
◊definition-entry[#:name "-e"]{
File ◊strong{exists}
}

◊definition-entry[#:name "-a"]{
File ◊strong{exists}

This is identical in effect to ◊code{-e}. It has been "deprecated,"
◊footnote{Per the 1913 edition of Webster's Dictionary:

◊emphasize{Deprecate} => To pray against, as an evil; to seek to avert by prayer; to
desire the removal of; to seek deliverance from; to express deep
regret for; to disapprove of strongly.} and its use is discouraged.
}

◊definition-entry[#:name "-f"]{
File is a ◊strong{regular} file (not a directory or device file)
}

} ◊; definition-block

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
