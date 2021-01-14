#lang pollen

◊; This is free software released into the public domain
◊; See LICENSE.txt

◊page-init{}
◊define-meta[page-title]{Time / Date Commands}
◊define-meta[page-description]{Time / Date Commands}

◊definition-block[#:type "code"]{

◊definition-entry[#:name "date"]{

Simply invoked, ◊code{date} prints the date and time to
◊code{stdout}. Where this command gets interesting is in its
formatting and parsing options.

◊example{
!/bin/bash
# Exercising the 'date' command

echo "The number of days since the year's beginning is `date +%j`."
# Needs a leading '+' to invoke formatting.
# %j gives day of year.

echo "The number of seconds elapsed since 01/01/1970 is `date +%s`."
#  %s yields number of seconds since "UNIX epoch" began,
#+ but how is this useful?

prefix=temp
suffix=$(date +%s)  # The "+%s" option to 'date' is GNU-specific.
filename=$prefix.$suffix
echo "Temporary filename = $filename"
#  It's great for creating "unique and random" temp filenames,
#+ even better than using $$.

# Read the 'date' man page for more formatting options.

exit 0
}

}

}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
