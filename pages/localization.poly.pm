#lang pollen

◊page-init{}
◊define-meta[page-title]{Localization}
◊define-meta[page-description]{Localization}

Localization is an undocumented Bash feature.

A localized shell script echoes its text output in the language
defined as the system's locale. A Linux user in Berlin, Germany, would
get script output in German, whereas his cousin in Berlin, Maryland,
would get output from the same script in English.

To create a localized script, use the following template to write all
messages to the user (error messages, prompts, etc.).

◊example{
#!/bin/bash
# localized.sh
#  Script by Stéphane Chazelas,
#+ modified by Bruno Haible, bugfixed by Alfredo Pironti.

. gettext.sh

E_CDERROR=65

error()
{
  printf "$@" >&2
  exit $E_CDERROR
}

cd $var || error "`eval_gettext \"Can\'t cd to \\\$var.\"`"
#  The triple backslashes (escapes) in front of $var needed
#+ "because eval_gettext expects a string
#+ where the variable values have not yet been substituted."
#    -- per Bruno Haible
read -p "`gettext \"Enter the value: \"`" var
#  ...


#  ------------------------------------------------------------------
#  Alfredo Pironti comments:

#  This script has been modified to not use the $"..." syntax in
#+ favor of the "`gettext \"...\"`" syntax.
#  This is ok, but with the new localized.sh program, the commands
#+ "bash -D filename" and "bash --dump-po-string filename"
#+ will produce no output
#+ (because those command are only searching for the $"..." strings)!
#  The ONLY way to extract strings from the new file is to use the
# 'xgettext' program. However, the xgettext program is buggy.

# Note that 'xgettext' has another bug.
#
# The shell fragment:
#    gettext -s "I like Bash"
# will be correctly extracted, but . . .
#    xgettext -s "I like Bash"
# . . . fails!
#  'xgettext' will extract "-s" because
#+ the command only extracts the
#+ very first argument after the 'gettext' word.


#  Escape characters:
#
#  To localize a sentence like
#     echo -e "Hello\tworld!"
#+ you must use
#     echo -e "`gettext \"Hello\\tworld\"`"
#  The "double escape character" before the `t' is needed because
#+ 'gettext' will search for a string like: 'Hello\tworld'
#  This is because gettext will read one literal `\')
#+ and will output a string like "Bonjour\tmonde",
#+ so the 'echo' command will display the message correctly.
#
#  You may not use
#     echo "`gettext -e \"Hello\tworld\"`"
#+ due to the xgettext bug explained above.



# Let's localize the following shell fragment:
#     echo "-h display help and exit"
#
# First, one could do this:
#     echo "`gettext \"-h display help and exit\"`"
#  This way 'xgettext' will work ok,
#+ but the 'gettext' program will read "-h" as an option!
#
# One solution could be
#     echo "`gettext -- \"-h display help and exit\"`"
#  This way 'gettext' will work,
#+ but 'xgettext' will extract "--", as referred to above.
#
# The workaround you may use to get this string localized is
#     echo -e "`gettext \"\\0-h display help and exit\"`"
#  We have added a \0 (NULL) at the beginning of the sentence.
#  This way 'gettext' works correctly, as does 'xgettext.'
#  Moreover, the NULL character won't change the behavior
#+ of the 'echo' command.
#  ------------------------------------------------------------------
}

Run it:

◊example{
bash$ bash -D localized.sh
"Can't cd to %s."
"Enter the value: "
}

This lists all the localized text. (The ◊code{-D} option lists
double-quoted strings prefixed by a ◊code{$}, without executing the
script.)

◊example{
bash$ bash --dump-po-strings localized.sh
#: a:6
msgid "Can't cd to %s."
msgstr ""
#: a:7
msgid "Enter the value: "
msgstr ""
}

The ◊code{--dump-po-strings} option to Bash resembles the ◊code{-D}
option, but uses gettext "po" format.

Bruno Haible points out:

Starting with gettext-0.12.2, ◊command{xgettext -o - localized.sh} is
recommended instead of ◊command{bash --dump-po-strings localized.sh},
because ◊command{xgettext} . . .

1. understands the ◊command{gettext} and ◊command{eval_gettext}
commands (whereas ◊command{bash --dump-po-strings} understands only
its deprecated ◊code{$"..."} syntax)

2. can extract comments placed by the programmer, intended to be read
by the translator.

This shell code is then not specific to Bash any more; it works the
same way with Bash 1.x and other ◊fname{/bin/sh} implementations.

Now, build a ◊fname{language.po} file for each language that the
script will be translated into, specifying the msgstr. Alfredo Pironti
gives the following example:

fr.po:

◊example{
#: a:6
msgid "Can't cd to $var."
msgstr "Impossible de se positionner dans le repertoire $var."
#: a:7
msgid "Enter the value: "
msgstr "Entrez la valeur : "

#  The string are dumped with the variable names, not with the %s syntax,
#+ similar to C programs.
#+ This is a very cool feature if the programmer uses
#+ variable names that make sense!
}

Then, run ◊command{msgfmt -o localized.sh.mo fr.po}

Place the resulting ◊fname{localized.sh.mo} file in the
◊fname{/usr/local/share/locale/fr/LC_MESSAGES} directory, and at the
beginning of the script, insert the lines:

◊example{
TEXTDOMAINDIR=/usr/local/share/locale
TEXTDOMAIN=localized.sh
}

If a user on a French system runs the script, she will get French
messages.

Note: With older versions of Bash or other shells, localization
requires ◊command{gettext}, using the ◊code{-s} option. In this case,
the script becomes:

◊example{
#!/bin/bash
# localized.sh

E_CDERROR=65

error() {
  local format=$1
  shift
  printf "$(gettext -s "$format")" "$@" >&2
  exit $E_CDERROR
}
cd $var || error "Can't cd to %s." "$var"
read -p "$(gettext -s "Enter the value: ")" var
# ...
}

The ◊code{TEXTDOMAIN} and ◊code{TEXTDOMAINDIR} variables need to be
set and exported to the environment. This should be done within the
script itself.

---

This appendix written by Stéphane Chazelas, with modifications
suggested by Alfredo Pironti, and by Bruno Haible, maintainer of GNU
gettext.
