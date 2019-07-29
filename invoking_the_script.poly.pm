#lang pollen

◊define-meta[page-title]{Invoking the script}
◊define-meta[page-description]{Inoking a script from the command line}

◊; TODO: display: 2.1. Invoking the script

Having written the script, you can invoke it by sh scriptname, [1] or
alternatively bash scriptname. (Not recommended is using sh
<scriptname, since this effectively disables reading from stdin within
the script.) Much more convenient is to make the script itself
directly executable with a chmod.
