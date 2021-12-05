#lang pollen

◊page-init{}
◊define-meta[page-title]{Colorizing}
◊define-meta[page-description]{"Colorizing" Scripts}

The ANSI escape sequences set screen attributes, such as bold
text, and color of foreground and background. DOS batch files commonly
used ANSI escape codes for color output, and so can Bash scripts.

◊anchored-example[#:anchor "color_db1"]{A "colorized" address
database}

◊example{
#!/bin/bash
# ex30a.sh: "Colorized" version of ex30.sh.
#            Crude address database


clear                                   # Clear the screen.

echo -n "          "
echo -e '\E[37;44m'"\033[1mContact List\033[0m"
                                        # White on blue background
echo; echo
echo -e "\033[1mChoose one of the following persons:\033[0m"
                                        # Bold
tput sgr0                               # Reset attributes.
echo "(Enter only the first letter of name.)"
echo
echo -en '\E[47;34m'"\033[1mE\033[0m"   # Blue
tput sgr0                               # Reset colors to "normal."
echo "vans, Roland"                     # "[E]vans, Roland"
echo -en '\E[47;35m'"\033[1mJ\033[0m"   # Magenta
tput sgr0
echo "ambalaya, Mildred"
echo -en '\E[47;32m'"\033[1mS\033[0m"   # Green
tput sgr0
echo "mith, Julie"
echo -en '\E[47;31m'"\033[1mZ\033[0m"   # Red
tput sgr0
echo "ane, Morris"
echo

read person

case "$person" in
# Note variable is quoted.

  "E" | "e" )
  # Accept upper or lowercase input.
  echo
  echo "Roland Evans"
  echo "4321 Flash Dr."
  echo "Hardscrabble, CO 80753"
  echo "(303) 734-9874"
  echo "(303) 734-9892 fax"
  echo "revans@zzy.net"
  echo "Business partner & old friend"
  ;;

  "J" | "j" )
  echo
  echo "Mildred Jambalaya"
  echo "249 E. 7th St., Apt. 19"
  echo "New York, NY 10009"
  echo "(212) 533-2814"
  echo "(212) 533-9972 fax"
  echo "milliej@loisaida.com"
  echo "Girlfriend"
  echo "Birthday: Feb. 11"
  ;;

# Add info for Smith & Zane later.

          * )
   # Default option.	  
   # Empty input (hitting RETURN) fits here, too.
   echo
   echo "Not yet in database."
  ;;

esac

tput sgr0                               # Reset colors to "normal."

echo

exit 0
}

◊anchored-example[#:anchor "draw_bow1"]{Drawing a box}

◊example{
#!/bin/bash
# Draw-box.sh: Drawing a box using ASCII characters.

# Script by Stefano Palmeri, with minor editing by document author.
# Minor edits suggested by Jim Angstadt.
# Used in the ABS Guide with permission.


######################################################################
###  draw_box function doc  ###

#  The "draw_box" function lets the user
#+ draw a box in a terminal.       
#
#  Usage: draw_box ROW COLUMN HEIGHT WIDTH [COLOR] 
#  ROW and COLUMN represent the position        
#+ of the upper left angle of the box you're going to draw.
#  ROW and COLUMN must be greater than 0
#+ and less than current terminal dimension.
#  HEIGHT is the number of rows of the box, and must be > 0. 
#  HEIGHT + ROW must be <= than current terminal height. 
#  WIDTH is the number of columns of the box and must be > 0.
#  WIDTH + COLUMN must be <= than current terminal width.
#
# E.g.: If your terminal dimension is 20x80,
#  draw_box 2 3 10 45 is good
#  draw_box 2 3 19 45 has bad HEIGHT value (19+2 > 20)
#  draw_box 2 3 18 78 has bad WIDTH value (78+3 > 80)
#
#  COLOR is the color of the box frame.
#  This is the 5th argument and is optional.
#  0=black 1=red 2=green 3=tan 4=blue 5=purple 6=cyan 7=white.
#  If you pass the function bad arguments,
#+ it will just exit with code 65,
#+ and no messages will be printed on stderr.
#
#  Clear the terminal before you start to draw a box.
#  The clear command is not contained within the function.
#  This allows the user to draw multiple boxes, even overlapping ones.

###  end of draw_box function doc  ### 
######################################################################

draw_box(){

#=============#
HORZ="-"
VERT="|"
CORNER_CHAR="+"

MINARGS=4
E_BADARGS=65
#=============#


if [ $# -lt "$MINARGS" ]; then          # If args are less than 4, exit.
    exit $E_BADARGS
fi

# Looking for non digit chars in arguments.
# Probably it could be done better (exercise for the reader?).
if echo $@ | tr -d [:blank:] | tr -d [:digit:] | grep . &> /dev/null; then
   exit $E_BADARGS
fi

BOX_HEIGHT=`expr $3 - 1`   #  -1 correction needed because angle char "+"
BOX_WIDTH=`expr $4 - 1`    #+ is a part of both box height and width.
T_ROWS=`tput lines`        #  Define current terminal dimension 
T_COLS=`tput cols`         #+ in rows and columns.
         
if [ $1 -lt 1 ] || [ $1 -gt $T_ROWS ]; then    #  Start checking if arguments
   exit $E_BADARGS                             #+ are correct.
fi
if [ $2 -lt 1 ] || [ $2 -gt $T_COLS ]; then
   exit $E_BADARGS
fi
if [ `expr $1 + $BOX_HEIGHT + 1` -gt $T_ROWS ]; then
   exit $E_BADARGS
fi
if [ `expr $2 + $BOX_WIDTH + 1` -gt $T_COLS ]; then
   exit $E_BADARGS
fi
if [ $3 -lt 1 ] || [ $4 -lt 1 ]; then
   exit $E_BADARGS
fi                                 # End checking arguments.

plot_char(){                       # Function within a function.
   echo -e "\E[${1};${2}H"$3
}

echo -ne "\E[3${5}m"               # Set box frame color, if defined.

# start drawing the box

count=1                                         #  Draw vertical lines using
for (( r=$1; count<=$BOX_HEIGHT; r++)); do      #+ plot_char function.
  plot_char $r $2 $VERT
  let count=count+1
done 

count=1
c=`expr $2 + $BOX_WIDTH`
for (( r=$1; count<=$BOX_HEIGHT; r++)); do
  plot_char $r $c $VERT
  let count=count+1
done 

count=1                                        #  Draw horizontal lines using
for (( c=$2; count<=$BOX_WIDTH; c++)); do      #+ plot_char function.
  plot_char $1 $c $HORZ
  let count=count+1
done 

count=1
r=`expr $1 + $BOX_HEIGHT`
for (( c=$2; count<=$BOX_WIDTH; c++)); do
  plot_char $r $c $HORZ
  let count=count+1
done 

plot_char $1 $2 $CORNER_CHAR                   # Draw box angles.
plot_char $1 `expr $2 + $BOX_WIDTH` $CORNER_CHAR
plot_char `expr $1 + $BOX_HEIGHT` $2 $CORNER_CHAR
plot_char `expr $1 + $BOX_HEIGHT` `expr $2 + $BOX_WIDTH` $CORNER_CHAR

echo -ne "\E[0m"             #  Restore old colors.

P_ROWS=`expr $T_ROWS - 1`    #  Put the prompt at bottom of the terminal.

echo -e "\E[${P_ROWS};1H"
}      


# Now, let's try drawing a box.
clear                       # Clear the terminal.
R=2      # Row
C=3      # Column
H=10     # Height
W=45     # Width 
col=1    # Color (red)
draw_box $R $C $H $W $col   # Draw the box.

exit 0

# Exercise:
# --------
# Add the option of printing text within the drawn box.
}

The simplest, and perhaps most useful ANSI escape sequence is bold
text, ◊code{\033[1m ... \033[0m}. The ◊code{\033} represents an
escape, the ◊code{[1} turns on the bold attribute, while the ◊code{[0}
switches it off. The ◊code{m} terminates each term of the escape
sequence.

◊example{
bash$ echo -e "\033[1mThis is bold text.\033[0m"
}

A similar escape sequence switches on the underline attribute (on an
◊command{rxvt} and an ◊command{aterm}).

◊example{
bash$ echo -e "\033[4mThis is underlined text.\033[0m"
}

Note: With an ◊command{echo}, the ◊code{-e} option enables the escape
sequences.

Other escape sequences change the text and/or background color.

◊example{
bash$ echo -e '\E[34;47mThis prints in blue.'; tput sgr0


bash$ echo -e '\E[33;44m'"yellow text on blue background"; tput sgr0


bash$ echo -e '\E[1;33;44m'"BOLD yellow text on blue background"; tput sgr0
}

Use the following template for writing colored text on a colored background.

◊example{
echo -e '\E[COLOR1;COLOR2mSome text goes here.'
}

The ◊code{\E[} begins the escape sequence. The semicolon-separated
numbers ◊code{COLOR1} and ◊code{COLOR2} specify a foreground and a
background color, according to the table below. (The order of the
numbers does not matter, since the foreground and background numbers
fall in non-overlapping ranges.) The ◊code{m} terminates the escape
sequence, and the text begins immediately after that.

Note also that single quotes enclose the remainder of the command
sequence following the ◊code{echo -e}.

◊example{
+---------+------------+------------+
| color   | Foreground | Background |
|---------+------------+------------|
| black   |         30 |         40 |
| red     |         31 |         41 |
| green   |         32 |         42 |
| yellow  |         33 |         43 |
| blue    |         34 |         44 |
| magenta |         35 |         45 |
| cyan    |         36 |         46 |
| white   |         37 |         47 |
+---------+------------+------------+
}

◊anchored-example[#:anchor "color_txt1"]{Echoing colored text}

◊example{
#!/bin/bash
# color-echo.sh: Echoing text messages in color.

# Modify this script for your own purposes.
# It's easier than hand-coding color.

black='\E[30;47m'
red='\E[31;47m'
green='\E[32;47m'
yellow='\E[33;47m'
blue='\E[34;47m'
magenta='\E[35;47m'
cyan='\E[36;47m'
white='\E[37;47m'


alias Reset="tput sgr0"      #  Reset text attributes to normal
                             #+ without clearing screen.


cecho ()                     # Color-echo.
                             # Argument $1 = message
                             # Argument $2 = color
{
local default_msg="No message passed."
                             # Doesn't really need to be a local variable.

message=${1:-$default_msg}   # Defaults to default message.
color=${2:-$black}           # Defaults to black, if not specified.

  echo -e "$color"
  echo "$message"
  Reset                      # Reset to normal.

  return
}  


# Now, let's try it out.
# ----------------------------------------------------
cecho "Feeling blue..." $blue
cecho "Magenta looks more like purple." $magenta
cecho "Green with envy." $green
cecho "Seeing red?" $red
cecho "Cyan, more familiarly known as aqua." $cyan
cecho "No color passed (defaults to black)."
       # Missing $color argument.
cecho "\"Empty\" color passed (defaults to black)." ""
       # Empty $color argument.
cecho
       # Missing $message and $color arguments.
cecho "" ""
       # Empty $message and $color arguments.
# ----------------------------------------------------

echo

exit 0

# Exercises:
# ---------
# 1) Add the "bold" attribute to the 'cecho ()' function.
# 2) Add options for colored backgrounds.
}

◊anchored-example[#:anchor "horse_gm1"]{A "horserace" game}

◊example{
#!/bin/bash
# horserace.sh: Very simple horserace simulation.
# Author: Stefano Palmeri
# Used with permission.

################################################################
#  Goals of the script:
#  playing with escape sequences and terminal colors.
#
#  Exercise:
#  Edit the script to make it run less randomly,
#+ set up a fake betting shop . . .     
#  Um . . . um . . . it's starting to remind me of a movie . . .
#
#  The script gives each horse a random handicap.
#  The odds are calculated upon horse handicap
#+ and are expressed in European(?) style.
#  E.g., odds=3.75 means that if you bet $1 and win,
#+ you receive $3.75.
# 
#  The script has been tested with a GNU/Linux OS,
#+ using xterm and rxvt, and konsole.
#  On a machine with an AMD 900 MHz processor,
#+ the average race time is 75 seconds.    
#  On faster computers the race time would be lower.
#  So, if you want more suspense, reset the USLEEP_ARG variable.
#
#  Script by Stefano Palmeri.
################################################################

E_RUNERR=65

# Check if md5sum and bc are installed. 
if ! which bc &> /dev/null; then
   echo bc is not installed.  
   echo "Can\'t run . . . "
   exit $E_RUNERR
fi
if ! which md5sum &> /dev/null; then
   echo md5sum is not installed.  
   echo "Can\'t run . . . "
   exit $E_RUNERR
fi

#  Set the following variable to slow down script execution.
#  It will be passed as the argument for usleep (man usleep)  
#+ and is expressed in microseconds (500000 = half a second).
USLEEP_ARG=0  

#  Clean up the temp directory, restore terminal cursor and 
#+ terminal colors -- if script interrupted by Ctl-C.
trap 'echo -en "\E[?25h"; echo -en "\E[0m"; stty echo;\
tput cup 20 0; rm -fr  $HORSE_RACE_TMP_DIR'  TERM EXIT
#  See the chapter on debugging for an explanation of 'trap.'

# Set a unique (paranoid) name for the temp directory the script needs.
HORSE_RACE_TMP_DIR=$HOME/.horserace-`date +%s`-`head -c10 /dev/urandom \
| md5sum | head -c30`

# Create the temp directory and move right in.
mkdir $HORSE_RACE_TMP_DIR
cd $HORSE_RACE_TMP_DIR


#  This function moves the cursor to line $1 column $2 and then prints $3.
#  E.g.: "move_and_echo 5 10 linux" is equivalent to
#+ "tput cup 4 9; echo linux", but with one command instead of two.
#  Note: "tput cup" defines 0 0 the upper left angle of the terminal,
#+ echo defines 1 1 the upper left angle of the terminal.
move_and_echo() {
          echo -ne "\E[${1};${2}H""$3" 
}

# Function to generate a pseudo-random number between 1 and 9. 
random_1_9 ()
{
    head -c10 /dev/urandom | md5sum | tr -d [a-z] | tr -d 0 | cut -c1 
}

#  Two functions that simulate "movement," when drawing the horses. 
draw_horse_one() {
               echo -n " "//$MOVE_HORSE//
}
draw_horse_two(){
              echo -n " "\\\\$MOVE_HORSE\\\\ 
}   


# Define current terminal dimension.
N_COLS=`tput cols`
N_LINES=`tput lines`

# Need at least a 20-LINES X 80-COLUMNS terminal. Check it.
if [ $N_COLS -lt 80 ] || [ $N_LINES -lt 20 ]; then
   echo "`basename $0` needs a 80-cols X 20-lines terminal."
   echo "Your terminal is ${N_COLS}-cols X ${N_LINES}-lines."
   exit $E_RUNERR
fi


# Start drawing the race field.

# Need a string of 80 chars. See below.
BLANK80=`seq -s "" 100 | head -c80`

clear

# Set foreground and background colors to white.
echo -ne '\E[37;47m'

# Move the cursor on the upper left angle of the terminal.
tput cup 0 0 

# Draw six white lines.
for n in `seq 5`; do
      echo $BLANK80   # Use the 80 chars string to colorize the terminal.
done

# Sets foreground color to black. 
echo -ne '\E[30m'

move_and_echo 3 1 "START  1"            
move_and_echo 3 75 FINISH
move_and_echo 1 5 "|"
move_and_echo 1 80 "|"
move_and_echo 2 5 "|"
move_and_echo 2 80 "|"
move_and_echo 4 5 "|  2"
move_and_echo 4 80 "|"
move_and_echo 5 5 "V  3"
move_and_echo 5 80 "V"

# Set foreground color to red. 
echo -ne '\E[31m'

# Some ASCII art.
move_and_echo 1 8 "..@@@..@@@@@...@@@@@.@...@..@@@@..."
move_and_echo 2 8 ".@...@...@.......@...@...@.@......."
move_and_echo 3 8 ".@@@@@...@.......@...@@@@@.@@@@...."
move_and_echo 4 8 ".@...@...@.......@...@...@.@......."
move_and_echo 5 8 ".@...@...@.......@...@...@..@@@@..."
move_and_echo 1 43 "@@@@...@@@...@@@@..@@@@..@@@@."
move_and_echo 2 43 "@...@.@...@.@.....@.....@....."
move_and_echo 3 43 "@@@@..@@@@@.@.....@@@@...@@@.."
move_and_echo 4 43 "@..@..@...@.@.....@.........@."
move_and_echo 5 43 "@...@.@...@..@@@@..@@@@.@@@@.."


# Set foreground and background colors to green.
echo -ne '\E[32;42m'

# Draw  eleven green lines.
tput cup 5 0
for n in `seq 11`; do
      echo $BLANK80
done

# Set foreground color to black. 
echo -ne '\E[30m'
tput cup 5 0

# Draw the fences. 
echo "++++++++++++++++++++++++++++++++++++++\
++++++++++++++++++++++++++++++++++++++++++"

tput cup 15 0
echo "++++++++++++++++++++++++++++++++++++++\
++++++++++++++++++++++++++++++++++++++++++"

# Set foreground and background colors to white.
echo -ne '\E[37;47m'

# Draw three white lines.
for n in `seq 3`; do
      echo $BLANK80
done

# Set foreground color to black.
echo -ne '\E[30m'

# Create 9 files to stores handicaps.
for n in `seq 10 7 68`; do
      touch $n
done  

# Set the first type of "horse" the script will draw.
HORSE_TYPE=2

#  Create position-file and odds-file for every "horse".
#+ In these files, store the current position of the horse,
#+ the type and the odds.
for HN in `seq 9`; do
      touch horse_${HN}_position
      touch odds_${HN}
      echo \-1 > horse_${HN}_position
      echo $HORSE_TYPE >>  horse_${HN}_position
      # Define a random handicap for horse.
       HANDICAP=`random_1_9`
      # Check if the random_1_9 function returned a good value.
      while ! echo $HANDICAP | grep [1-9] &> /dev/null; do
                HANDICAP=`random_1_9`
      done
      # Define last handicap position for horse. 
      LHP=`expr $HANDICAP \* 7 + 3`
      for FILE in `seq 10 7 $LHP`; do
            echo $HN >> $FILE
      done   
     
      # Calculate odds.
      case $HANDICAP in 
              1) ODDS=`echo $HANDICAP \* 0.25 + 1.25 | bc`
                                 echo $ODDS > odds_${HN}
              ;;
              2 | 3) ODDS=`echo $HANDICAP \* 0.40 + 1.25 | bc`
                                       echo $ODDS > odds_${HN}
              ;;
              4 | 5 | 6) ODDS=`echo $HANDICAP \* 0.55 + 1.25 | bc`
                                             echo $ODDS > odds_${HN}
              ;; 
              7 | 8) ODDS=`echo $HANDICAP \* 0.75 + 1.25 | bc`
                                       echo $ODDS > odds_${HN}
              ;; 
              9) ODDS=`echo $HANDICAP \* 0.90 + 1.25 | bc`
                                  echo $ODDS > odds_${HN}
      esac


done


# Print odds.
print_odds() {
tput cup 6 0
echo -ne '\E[30;42m'
for HN in `seq 9`; do
      echo "#$HN odds->" `cat odds_${HN}`
done
}

# Draw the horses at starting line.
draw_horses() {
tput cup 6 0
echo -ne '\E[30;42m'
for HN in `seq 9`; do
      echo /\\$HN/\\"                               "
done
}

print_odds

echo -ne '\E[47m'
# Wait for a enter key press to start the race.
# The escape sequence '\E[?25l' disables the cursor.
tput cup 17 0
echo -e '\E[?25l'Press [enter] key to start the race...
read -s

#  Disable normal echoing in the terminal.
#  This avoids key presses that might "contaminate" the screen
#+ during the race.  
stty -echo

# --------------------------------------------------------
# Start the race.

draw_horses
echo -ne '\E[37;47m'
move_and_echo 18 1 $BLANK80
echo -ne '\E[30m'
move_and_echo 18 1 Starting...
sleep 1

# Set the column of the finish line.
WINNING_POS=74

# Define the time the race started.
START_TIME=`date +%s`

# COL variable needed by following "while" construct.
COL=0    

while [ $COL -lt $WINNING_POS ]; do
                   
          MOVE_HORSE=0     
          
          # Check if the random_1_9 function has returned a good value.
          while ! echo $MOVE_HORSE | grep [1-9] &> /dev/null; do
                MOVE_HORSE=`random_1_9`
          done
          
          # Define old type and position of the "randomized horse".
          HORSE_TYPE=`cat  horse_${MOVE_HORSE}_position | tail -n 1`
          COL=$(expr `cat  horse_${MOVE_HORSE}_position | head -n 1`)
          
          ADD_POS=1
          # Check if the current position is an handicap position. 
          if seq 10 7 68 | grep -w $COL &> /dev/null; then
                if grep -w $MOVE_HORSE $COL &> /dev/null; then
                      ADD_POS=0
                      grep -v -w  $MOVE_HORSE $COL > ${COL}_new
                      rm -f $COL
                      mv -f ${COL}_new $COL
                      else ADD_POS=1
                fi 
          else ADD_POS=1
          fi
          COL=`expr $COL + $ADD_POS`
          echo $COL >  horse_${MOVE_HORSE}_position  # Store new position.
                            
         # Choose the type of horse to draw.         
          case $HORSE_TYPE in 
                1) HORSE_TYPE=2; DRAW_HORSE=draw_horse_two
                ;;
                2) HORSE_TYPE=1; DRAW_HORSE=draw_horse_one 
          esac       
          echo $HORSE_TYPE >>  horse_${MOVE_HORSE}_position
          # Store current type.
         
          # Set foreground color to black and background to green.
          echo -ne '\E[30;42m'
          
          # Move the cursor to new horse position.
          tput cup `expr $MOVE_HORSE + 5` \
	  `cat  horse_${MOVE_HORSE}_position | head -n 1` 
          
          # Draw the horse.
          $DRAW_HORSE
           usleep $USLEEP_ARG
          
           # When all horses have gone beyond field line 15, reprint odds.
           touch fieldline15
           if [ $COL = 15 ]; then
             echo $MOVE_HORSE >> fieldline15  
           fi
           if [ `wc -l fieldline15 | cut -f1 -d " "` = 9 ]; then
               print_odds
               : > fieldline15
           fi           
          
          # Define the leading horse.
          HIGHEST_POS=`cat *position | sort -n | tail -1`          
          
          # Set background color to white.
          echo -ne '\E[47m'
          tput cup 17 0
          echo -n Current leader: `grep -w $HIGHEST_POS *position | cut -c7`\
	  "                              "

done  

# Define the time the race finished.
FINISH_TIME=`date +%s`

# Set background color to green and enable blinking text.
echo -ne '\E[30;42m'
echo -en '\E[5m'

# Make the winning horse blink.
tput cup `expr $MOVE_HORSE + 5` \
`cat  horse_${MOVE_HORSE}_position | head -n 1`
$DRAW_HORSE

# Disable blinking text.
echo -en '\E[25m'

# Set foreground and background color to white.
echo -ne '\E[37;47m'
move_and_echo 18 1 $BLANK80

# Set foreground color to black.
echo -ne '\E[30m'

# Make winner blink.
tput cup 17 0
echo -e "\E[5mWINNER: $MOVE_HORSE\E[25m""  Odds: `cat odds_${MOVE_HORSE}`"\
"  Race time: `expr $FINISH_TIME - $START_TIME` secs"

# Restore cursor and old colors.
echo -en "\E[?25h"
echo -en "\E[0m"

# Restore echoing.
stty echo

# Remove race temp directory.
rm -rf $HORSE_RACE_TMP_DIR

tput cup 19 0

exit 0
}

See also TODO Example A-21, Example A-44, Example A-52, and Example
A-40.

Caution: There is, however, a major problem with all this. ANSI escape
sequences are emphatically non-portable. What works fine on some
terminal emulators (or the console) may work differently, or not at
all, on others. A "colorized" script that looks stunning on the script
author's machine may produce unreadable output on someone else's. This
somewhat compromises the usefulness of colorizing scripts, and
possibly relegates this technique to the status of a
gimmick. Colorized scripts are probably inappropriate in a commercial
setting, i.e., your supervisor might disapprove.

Alister's ansi-color utility (based on Moshe Jacobson's color utility)
considerably simplifies using ANSI escape sequences. It substitutes a
clean and logical syntax for the clumsy constructs just discussed.

Henry/teikedvl has likewise created a utility (◊url[#:link
"http://scriptechocolor.sourceforge.net/"]{}) to simplify creation of
colorized scripts.


