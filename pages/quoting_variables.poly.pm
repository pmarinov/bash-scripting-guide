#lang pollen

◊define-meta[page-title]{Quoting variables}
◊define-meta[page-description]{Quoting Variables}


◊; TODO: FIX FORMATTING (code, idalic, etc.)

When referencing a variable, it is generally advisable to enclose its
name in double quotes. This prevents reinterpretation of all special
characters within the quoted string -- except $, ` (backquote), and \
(escape). Keeping $ as a special character within double quotes
permits referencing a quoted variable ("$variable"), that is,
replacing the variable with its value (TODO: see Example 4-1, above).

Encapsulating "!" within double quotes gives an error when used from
the command line. This is interpreted as a history command. Within a
script, though, this problem does not occur, since the Bash history
mechanism is disabled then.

Of more concern is the apparently inconsistent behavior of \ within
double quotes, and especially following an echo -e command.

◊example{
bash$ echo hello\!
hello!
bash$ echo "hello\!"
hello\!


bash$ echo \
>
bash$ echo "\"
>
bash$ echo \a
a
bash$ echo "\a"
\a


bash$ echo x\ty
xty
bash$ echo "x\ty"
x\ty

bash$ echo -e x\ty
xty
bash$ echo -e "x\ty"
x       y
} 

Double quotes following an echo sometimes escape \. Moreover, the -e
option to echo causes the "\t" to be interpreted as a tab.

(Thank you, Wayne Pollock, for pointing this out, and Geoff Lee and
Daniel Barclay for explaining it.)

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
