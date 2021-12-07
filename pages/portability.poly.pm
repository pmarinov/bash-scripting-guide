#lang pollen

◊page-init{}
◊define-meta[page-title]{Portability}
◊define-meta[page-description]{Portability Issues}

◊quotation[#:author "Larry Wall"]{It is easier to port a shell than a
shell script.}

◊section{Bash vs. ksh vs. sh}

This book deals specifically with Bash scripting on a GNU/Linux
system. All the same, users of ◊command{sh} and ◊command{ksh} will
find much of value here.

As it happens, many of the various shells and scripting languages seem
to be converging toward the POSIX 1003.2 standard. Invoking Bash with
the ◊code{--posix} option or inserting a ◊command{set -o posix} at the
head of a script causes Bash to conform very closely to this
standard. Another alternative is to use a ◊fname{#!/bin/sh} sha-bang
header in the script, rather than ◊fname{#!/bin/bash}. Note that
◊fname{/bin/sh} is a link to ◊fname{/bin/bash} in Linux and certain
other flavors of UNIX, and a script invoked this way disables extended
Bash functionality.

Note: It is better to use ◊code{env}: ◊code{!/bin/env sh}

Most Bash scripts will run as-is under ◊command{ksh}, and vice-versa,
since Chet Ramey has been busily porting ◊command{ksh} features to the
latest versions of Bash.

On a commercial UNIX machine, scripts using GNU-specific features of
standard commands may not work. This has become less of a problem in
the last few years, as the GNU utilities have pretty much displaced
their proprietary counterparts even on "big-iron" UNIX. Caldera's
release of the source to many of the original UNIX utilities has
accelerated the trend.

Bash has certain features that the traditional Bourne shell
lacks. Among these are:

(TODO link to appropriate articles)

◊list-block[#:type "bullet"]{

◊list-entry{Certain extended invocation options}

◊list-entry{Command substitution using ◊command{$( )} notation}

◊list-entry{Brace expansion}

◊list-entry{Certain array operations, and associative arrays}

◊list-entry{The double brackets extended test construct}

◊list-entry{The double-parentheses arithmetic-evaluation construct}

◊list-entry{Certain string manipulation operations}

◊list-entry{Process substitution}

◊list-entry{A Regular Expression matching operator}

◊list-entry{Bash-specific builtins}

◊list-entry{Coprocesses}

}

See Bash FAQ for complete listing:
◊url[#:link "http://www.faqs.org/faqs/unix-faq/shell/bash/"]

◊section{A Test Suite}

Let us illustrate some of the incompatibilities between Bash and the
classic Bourne shell. Download and install the "Heirloom Bourne Shell"
and run the following script, first using ◊command{bash}, then the
classic ◊command{sh}.

See: ◊url[#:link "http://heirloom.sourceforge.net/sh.html"]{}

◊example{
#!/bin/bash
# test-suite.sh
# A partial Bash compatibility test suite.
# Run this on your version of Bash, or some other shell.

default_option=FAIL         # Tests below will fail unless . . .

echo
echo -n "Testing "
sleep 1; echo -n ". "
sleep 1; echo -n ". "
sleep 1; echo ". "
echo

# Double brackets
String="Double brackets supported?"
echo -n "Double brackets test: "
if [[ "$String" = "Double brackets supported?" ]]
then
  echo "PASS"
else
  echo "FAIL"
fi


# Double brackets and regex matching
String="Regex matching supported?"
echo -n "Regex matching: "
if [[ "$String" =~ R.....matching* ]]
then
  echo "PASS"
else
  echo "FAIL"
fi


# Arrays
test_arr=$default_option     # FAIL
Array=( If supports arrays will print PASS )
test_arr=${Array[5]}
echo "Array test: $test_arr"


# Command Substitution
csub_test ()
{
  echo "PASS"
}

test_csub=$default_option    # FAIL
test_csub=$(csub_test)
echo "Command substitution test: $test_csub"

echo

#  Completing this script is an exercise for the reader.
#  Add to the above similar tests for double parentheses,
#+ brace expansion, process substitution, etc.

exit $?
}

◊section{Shell Scripting Under Windows}

Even users running that other OS can run UNIX-like shell scripts, and
therefore benefit from many of the lessons of this book. The Cygwin
package from Cygnus and the MKS utilities from Mortice Kern Associates
add shell scripting capabilities to Windows.

See: ◊url[#:link "https://www.mkssoftware.com/"]{}

Another alternative is UWIN, written by David Korn of AT&T, of Korn
Shell fame.
