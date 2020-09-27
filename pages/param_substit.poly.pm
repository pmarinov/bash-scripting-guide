#lang pollen

◊define-meta[page-title]{Parameter Substitution}
◊define-meta[page-description]{Substitution in variables and parameters}

◊section{Manipulating and/or expanding variables}

◊definition-block[#:type "variables"]{
◊definition-entry[#:name "${parameter}"]{

Same as ◊code{$parameter}, i.e., value of the variable parameter. In certain
contexts, only the less ambiguous ◊code{$◊escaped{◊"{"}parameter◊escaped{◊"}"}} form works.

}

} ◊;definition-block

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
