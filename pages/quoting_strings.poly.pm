#lang pollen

◊define-meta[page-title]{Quoting strings}
◊define-meta[page-description]{Interpretation of strings}

Quoting means just that, bracketing a string in quotes. This has the effect of protecting special characters in the string from reinterpretation or expansion by the shell or shell script. (A character is "special" if it has an interpretation other than its literal meaning. For example, the asterisk * represents a wild card character in globbing and Regular Expressions).

◊example{
bash$ ls -l [Vv]*
 -rw-rw-r--    1 bozo  bozo       324 Apr  2 15:05 VIEWDATA.BAT
 -rw-rw-r--    1 bozo  bozo       507 May  4 14:25 vartrace.sh
 -rw-rw-r--    1 bozo  bozo       539 Apr 14 17:11 viewdata.sh

bash$ ls -l '[Vv]*'
ls: [Vv]*: No such file or directory
}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
