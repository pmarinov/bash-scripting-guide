#lang pollen

◊page-init{}
◊define-meta[page-title]{Restricted Shells}
◊define-meta[page-description]{Restricted Shells}

Running a script or portion of a script in restricted mode disables
certain commands that would otherwise be available. This is a security
measure intended to limit the privileges of the script user and to
minimize possible damage from running the script.

The following commands and actions are disabled:

◊list-block[#:type "bullet"]{

◊list-entry{Using cd to change the working directory.}

◊list-entry{Changing the values of the ◊code{$PATH}, ◊code{$SHELL},
◊code{$BASH_ENV}, or ◊code{$ENV} environmental variables.}

◊list-entry{Reading or changing the ◊code{$SHELLOPTS}, shell
environmental options.}

◊list-entry{Output redirection.}

◊list-entry{Invoking commands containing one or more /'s.}

◊list-entry{Invoking exec to substitute a different process for the
shell.}

◊list-entry{Various other commands that would enable monkeying with or
attempting to subvert the script for an unintended purpose.}

◊list-entry{Getting out of restricted mode within the script.}

}

◊anchored-example[#:anchor "restricted1"]{Running a script in
restricted mode}

◊example{
#!/bin/bash

#  Starting the script with "#!/bin/bash -r"
#+ runs entire script in restricted mode.

echo

echo "Changing directory."
cd /usr/local
echo "Now in `pwd`"
echo "Coming back home."
cd
echo "Now in `pwd`"
echo

# Everything up to here in normal, unrestricted mode.

set -r
# set --restricted    has same effect.
echo "==> Now in restricted mode. <=="

echo
echo

echo "Attempting directory change in restricted mode."
cd ..
echo "Still in `pwd`"

echo
echo

echo "\$SHELL = $SHELL"
echo "Attempting to change shell in restricted mode."
SHELL="/bin/ash"
echo
echo "\$SHELL= $SHELL"

echo
echo

echo "Attempting to redirect output in restricted mode."
ls -l /usr/bin > bin.files
ls -l bin.files    # Try to list attempted file creation effort.

echo

exit 0
}
