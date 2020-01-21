#lang pollen

◊define-meta[page-title]{Escaping}
◊define-meta[page-description]{Quoting single characters}

◊emphasize{Escaping} is a method of quoting single characters. The
escape (◊code{\}) preceding a character tells the shell to interpret that
character literally.

Caution: With certain commands and utilities, such as ◊code{echo} and
◊code{sed}, escaping a character may have the opposite effect - it can
toggle on a special meaning for that character.

◊section["Special meanings of certain escaped characters"]

(used with ◊code{echo} and ◊code{sed})

◊definition-block[#:type "variables"]{
◊definition-entry[#:name "\\n"]{
means newline
}

◊definition-entry[#:name "\\r"]{
means return
}

◊definition-entry[#:name "\\t"]{
means tab
}

◊definition-entry[#:name "\\v"]{
means vertical tab
}

◊definition-entry[#:name "\\b"]{
means backspace
}

◊definition-entry[#:name "\\a"]{
means ◊emphasize{alert} (beep or flash)
}

◊definition-entry[#:name "\\0xx"]{
translates to the octal ASCII equivalent of ◊code{0nn}, where
◊code{nn} is a string of digits

Important: The ◊code{$' ... '} quoted string-expansion construct is a
mechanism that uses escaped octal or hex values to assign ASCII
characters to variables, e.g., ◊code{quote=$'\042'}.

◊anchored-example[#:anchor "escaped_chars1"]{Escaped Characters}

◊example{
#!/bin/bash
# escaped.sh: escaped characters

#############################################################
### First, let's show some basic escaped-character usage. ###
#############################################################

# Escaping a newline.
# ------------------

echo ""

echo "This will print
as two lines."
# This will print
# as two lines.

echo "This will print \
as one line."
# This will print as one line.

echo; echo

echo "============="


echo "\v\v\v\v"      # Prints \v\v\v\v literally.
# Use the -e option with 'echo' to print escaped characters.
echo "============="
echo "VERTICAL TABS"
echo -e "\v\v\v\v"   # Prints 4 vertical tabs.
echo "=============="

echo "QUOTATION MARK"
echo -e "\042"       # Prints " (quote, octal ASCII character 42).
echo "=============="



# The $'\X' construct makes the -e option unnecessary.

echo; echo "NEWLINE and (maybe) BEEP"
echo $'\n'           # Newline.
echo $'\a'           # Alert (beep).
                     # May only flash, not beep, depending on terminal.

# We have seen $'\nnn" string expansion, and now . . .

# =================================================================== #
# Version 2 of Bash introduced the $'\nnn' string expansion construct.
# =================================================================== #

echo "Introducing the \$\' ... \' string-expansion construct . . . "
echo ". . . featuring more quotation marks."

echo $'\t \042 \t'   # Quote (") framed by tabs.
# Note that  '\nnn' is an octal value.

# It also works with hexadecimal values, in an $'\xhhh' construct.
echo $'\t \x22 \t'  # Quote (") framed by tabs.
# Thank you, Greg Keraunen, for pointing this out.
# Earlier Bash versions allowed '\x022'.

echo


# Assigning ASCII characters to a variable.
# ----------------------------------------
quote=$'\042'        # " assigned to a variable.
echo "$quote Quoted string $quote and this lies outside the quotes."

echo

# Concatenating ASCII chars in a variable.
triple_underline=$'\137\137\137'  # 137 is octal ASCII code for '_'.
echo "$triple_underline UNDERLINE $triple_underline"

echo

ABC=$'\101\102\103\010'           # 101, 102, 103 are octal A, B, C.
echo $ABC

echo

escape=$'\033'                    # 033 is octal for escape.
echo "\"escape\" echoes as $escape"
#                                   no visible output.

echo

exit 0
}

A more elaborate example:

◊anchored-example[#:anchor "detecting_keyp1"]{Detecting key-presses}

◊example{
#!/bin/bash
# Author: Sigurd Solaas, 20 Apr 2011
# Used in ABS Guide with permission.
# Requires version 4.2+ of Bash.

key="no value yet"
while true; do
  clear
  echo "Bash Extra Keys Demo. Keys to try:"
  echo
  echo "* Insert, Delete, Home, End, Page_Up and Page_Down"
  echo "* The four arrow keys"
  echo "* Tab, enter, escape, and space key"
  echo "* The letter and number keys, etc."
  echo
  echo "    d = show date/time"
  echo "    q = quit"
  echo "================================"
  echo

 # Convert the separate home-key to home-key_num_7:
 if [ "$key" = $'\x1b\x4f\x48' ]; then
  key=$'\x1b\x5b\x31\x7e'
  #   Quoted string-expansion construct. 
 fi

 # Convert the separate end-key to end-key_num_1.
 if [ "$key" = $'\x1b\x4f\x46' ]; then
  key=$'\x1b\x5b\x34\x7e'
 fi

 case "$key" in
  $'\x1b\x5b\x32\x7e')  # Insert
   echo Insert Key
  ;;
  $'\x1b\x5b\x33\x7e')  # Delete
   echo Delete Key
  ;;
  $'\x1b\x5b\x31\x7e')  # Home_key_num_7
   echo Home Key
  ;;
  $'\x1b\x5b\x34\x7e')  # End_key_num_1
   echo End Key
  ;;
  $'\x1b\x5b\x35\x7e')  # Page_Up
   echo Page_Up
  ;;
  $'\x1b\x5b\x36\x7e')  # Page_Down
   echo Page_Down
  ;;
  $'\x1b\x5b\x41')  # Up_arrow
   echo Up arrow
  ;;
  $'\x1b\x5b\x42')  # Down_arrow
   echo Down arrow
  ;;
  $'\x1b\x5b\x43')  # Right_arrow
   echo Right arrow
  ;;
  $'\x1b\x5b\x44')  # Left_arrow
   echo Left arrow
  ;;
  $'\x09')  # Tab
   echo Tab Key
  ;;
  $'\x0a')  # Enter
   echo Enter Key
  ;;
  $'\x1b')  # Escape
   echo Escape Key
  ;;
  $'\x20')  # Space
   echo Space Key
  ;;
  d)
   date
  ;;
  q)
  echo Time to quit...
  echo
  exit 0
  ;;
  *)
   echo You pressed: \'"$key"\'
  ;;
 esac

 echo
 echo "================================"

 unset K1 K2 K3
 read -s -N1 -p "Press a key: "
 K1="$REPLY"
 read -s -N2 -t 0.001
 K2="$REPLY"
 read -s -N1 -t 0.001
 K3="$REPLY"
 key="$K1$K2$K3"

done

exit $?
}

See also (TODO) Example 37-1.

}

◊definition-entry[#:name "\\\""]{
gives the quote its literal meaning

◊example{
echo "Hello"                     # Hello
echo "\"Hello\" ... he said."    # "Hello" ... he said.
}

}


}

◊; emacs:
◊; Local Variables:
◊; mode: fundamental
◊; End:
