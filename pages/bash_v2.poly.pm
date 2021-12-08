#lang pollen

◊page-init{}
◊define-meta[page-title]{Version 2}
◊define-meta[page-description]{Bash, version 2}

The current version of Bash, the one you have running on your machine,
is most likely version 2.xx.yy, 3.xx.yy, or 4.xx.yy.

◊example{
bash$ echo $BASH_VERSION
3.2.25(1)-release
}

The version 2 update of the classic Bash scripting language added
array variables, string and parameter expansion, and a better method
of indirect variable references, among other features.

◊anchored-example[#:anchor "str_exp1"]{String expansion}

◊example{
#!/bin/bash

# String expansion.
# Introduced with version 2 of Bash.

#  Strings of the form $'xxx'
#+ have the standard escaped characters interpreted. 

echo $'Ringing bell 3 times \a \a \a'
     # May only ring once with certain terminals.
     # Or ...
     # May not ring at all, depending on terminal settings.
echo $'Three form feeds \f \f \f'
echo $'10 newlines \n\n\n\n\n\n\n\n\n\n'
echo $'\102\141\163\150'
     #   B   a   s   h
     # Octal equivalent of characters.

exit
}



