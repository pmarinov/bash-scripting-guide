#lang pollen

◊define-meta[page-title]{Nested if/then}
◊define-meta[page-description]{Nested if/then Condition Tests}

Condition tests using the ◊code{if/then} construct may be nested. The net
result is equivalent to using the ◊code{&&} compound comparison operator.

◊example{
a=3

if [ "$a" -gt 0 ]
then
  if [ "$a" -lt 5 ]
  then
    echo "The value of \"a\" lies somewhere between 0 and 5."
  fi
fi

# Same result as:

if [ "$a" -gt 0 ] && [ "$a" -lt 5 ]
then
  echo "The value of \"a\" lies somewhere between 0 and 5."
fi
}

TOOD: Example 37-4 and Example 17-11 demonstrate nested ◊code{if/then} condition tests.

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
