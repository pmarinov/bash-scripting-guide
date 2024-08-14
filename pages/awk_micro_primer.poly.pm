#lang pollen

◊page-init{}
◊define-meta[page-title]{Awk Micro-Primer}
◊define-meta[page-description]{Awk Micro-Primer}

Anybody deeply interested in shell scripting will at some point come
across ◊command{awk} ◊footnote{Its name derives from the initials of
its authors, Aho, Weinberg, and Kernighan.}. In the spirit of
◊emphasize{do one thing and do it well}, ◊command{awk} can be defined
as a ◊strong{line-oriented} processor ◊strong{with state}. In
contrast, ◊command{sed} is a line-oriented with rules that provide
only a stateless form.


◊section{Parsing columns}

While it possesses an extensive set of operators and
capabilities, we will cover only a few of these here - the ones most
useful in shell scripts. 

Awk breaks each line of input passed to it into fields. By default, a
field is a string of consecutive characters delimited by whitespace,
though there are options for changing this. Awk parses and operates on
each separate field. This makes it ideal for handling structured text
files -- especially tables -- data organized into consistent chunks,
such as rows and columns.

Strong quoting and curly brackets enclose blocks of ◊command{awk} code
within a shell script.

◊example{
# $1 is field #1, $2 is field #2, etc.

$ echo one two | awk '{print $1}'
one

$ echo one two | awk '{print $2}'
two

# But what is field #0 ($0)?
$ echo one two | awk '{print $0}'
one two
# All the fields!
}


◊section{Arithmetic within columns}

Awk is a full-featured text processing language with a syntax
reminiscent of C. The parsing of columns can be combined with
arithmetic operations and the use of variables.

In this example, we have downloaded the dividends of Starbucks for the
last 2 years. With the help of ◊command{awk} we can compute how much
we'll earn per share by summing all of the 8 dividend values.

Notice that because the downloaded data is in '.csv' format, we
configure ◊command{awk} to use "," as a field separator

◊example{
# Dividens of Starbucks
$ cat SBUX.csv 
Date,Dividends
2022-08-11,0.490000
2022-11-09,0.530000
2023-02-09,0.530000
2023-05-11,0.530000
2023-08-10,0.530000
2023-11-09,0.570000
2024-02-08,0.570000
2024-05-16,0.570000

# Sum the column of the dividends,
# print it at the end
$ cat SBUX.csv | awk -F',' '{sum+=$2} END {print sum}'
4.32
}

The new element here is the command block ◊code{END}. Unlike the
command block that accumulates the sum, which is executed once per
each line of the input data file, ◊code{END} is run once at the end,
we use it to print the final accumulated value.


◊section{Rendering Markdown (.md) files in the terminal}

Markdown is a technique of text decoration of semantic structures of a
page, such as titles, lists, code sections, etc. For example, chapter
titles are marked with ◊code{#}, the number of ◊code{#} representing
nest level. A multi-line section of code starts and ends with
◊code{```}, etc.

The format was made particularly popular after its adoption by GitHub
for rendering of README.md files.

The rendering of .md files is usually an HTML output, in the context
of the terminal it is, however, nice to be able to read such files
with coloring using ANSI escape sequences.

A markdown decoration can start on one line and continue on the next,
or across multiple-lines, using its stream-processing capabilities,
combined with the ability to manage state, makes ◊command{awk}
suitable for the task.

◊example{
#!/usr/bin/awk -f

# md-color.awk
#
# Markdown highlighting for ANSI terminal
#
# NOTE: Processes only a subset of Markdown as a demo of AWK
#
# [2024-06-05]
# Written by Peter M., this is public domain
# (see: https://unlicense.org/)
#
# Usage (on terminal)
# $ md-color.awk demo.md
#
# Usage (via pager)
# $ md-color.awk demo.md | less -r
#
# Colors can be configured via env. variable MD_COLORS
#


function print_wrapped(long_line, prefix) {
  # Split words into an array
  split(long_line, list_of_words)

  line_len = 0
  num_words = length(list_of_words)

  for(i = 1; i <= num_words; i++) {
    word = list_of_words[i]
    word_len = length(word)

    # ~~~ Before word is printed ~~~

    # Check if we go beyond width of the block
    if ((line_len + word_len) > 78) {
      # Wrap the line
      line_len = 0
      printf("\n")
    }

    # At start of the line (line_len is 0 before we print first word)
    if (line_len == 0) {
      # Start with line prefix
      printf(prefix)

      # If inside multi-line bold
      if (bold_section)
        printf(ANSI_BOLD)

      # If inside multi-line inline code
      if (codeinline_section)
        printf(ANSI_CODE)
    }

    # Word begins with "**", set to bold
    if (match(word, "[*]{2}[^ ].*")) {
      printf(ANSI_BOLD)
      bold_section = 1
    }

    # Word begin with "`", set to code
    if (match(word, "`[^ ].*")) {
      printf(ANSI_CODE)
      codeinline_section = 1
    }

    # Advance length by one word
    line_len += word_len + 1

    # Special processing of punctuation at end of words
    # Example: "*word*," or "`word`."
    punct = substr(word, word_len)
    if ((punct == ".") || (punct == ",") || (punct == ":")) {
      # Separate punctuation from the word
      word = substr(word, 0, word_len - 1)
      word_len = word_len - 1
    }
    else
      punct = ""

    # ~~~ Print a word ~~~
    printf("%s", word)

    # ~~~ After the word is printed ~~~

    # Closing of bold
    if (substr(word, word_len - 1) == "**") {
      printf("%s", ANSI_NO_COLOR)
      bold_section = 0
    }

    # Closing of inline code
    if (substr(word, word_len) == "`") {
      printf("%s", ANSI_NO_COLOR)
      codeinline_section = 0
    }

    # Print the punctuation + a space
    printf("%s ", punct)
  }

  # Handle case of empty lines
  if (length(long_line) == 0)
    printf(prefix)

  # The line ends with a new-line
  printf("\n")
}


BEGIN {
  code_section = 0
  codeinline_section = 0
  bold_section = 0

  # Docs: ANSI Escape sequences at
  # https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797

  # Use environment variable to set colors, or use defaults
  if (length(ENVIRON["MD_COLORS"]) > 0)
    color_set = ENVIRON["MD_COLORS"]
  else
    color_set = "*e[0;34m *e[0;32m *e[0m*e[1m"

  # Subsusute "*e" with actual ESC character
  gsub(/\*e[[]/, "\033[", color_set)

  # Split into an array
  split(color_set, md_colors)

  ANSI_NO_COLOR = "\033[0m"
  ANSI_BOLD = "\033[1m"
  ANSI_QUOTE = md_colors[1]
  ANSI_CODE = md_colors[2]
  ANSI_HEADING = md_colors[3]
}


# Quote, single line
/^[[:blank:]]*>/ {
  if (code_section == 0) {
    # Strip leading "> "
    line = substr($0, 2)

    # Print folded block + setting color + using "> " as a line prefix
    print_wrapped(line, ANSI_QUOTE "> ")

    # Switch off color at the end of the quote block
    printf("%s", ANSI_NO_COLOR)
    next
  }
}


# Code section, multi-line
/^[[:blank:]]*```/ {
  if (code_section == 0)
      # Activate color for code section
      printf("%s%s\n", ANSI_CODE, $0)
  else
      # Remove color at the end of the code section
      printf("%s%s%s\n", ANSI_CODE, $0, ANSI_NO_COLOR)
  # Toggle flag
  code_section = 1 - code_section
  next
}


# Heading, single line
/^#.*/ {
  if (code_section == 0) {
    printf("%s%s%s\n", ANSI_HEADING, $0, ANSI_NO_COLOR)
    next
  }
}


# Everything else, the text of the file that is not prefixed by any markup
{
  if (code_section == 0)
    # Outside code section, fold long lines, prefix = switch off the color
    print_wrapped($0, ANSI_NO_COLOR)
  else
    # Inside code section, print line unmodified (no folding), apply color for code
    printf("%s%s\n", ANSI_CODE, $0)
}
}

Download full source code from: ◊url[#:link
"https://git.sr.ht/~pem/dotfiles/tree/master/item/scripts/md-color.awk"]{}


◊section{Resources}

There hasn't been much new development of ◊command{awk} in the last
couple of decades. Recent enhancements of note are the ability to
process Unicode characters and an option for native correct parsing of
.csv files.

There are 3 major implementations. The original Unix ◊command{awk},
GNU's ◊command{gawk}, and ◊command{mawk}. In Debian (and by extension
Ubuntu), the default is ◊command{mawk} while ◊command{gawk} is
available for an easy install.

The LWN has a good article of introduction and history of
◊command{awk}: ◊url[#:link "https://lwn.net/Articles/820829/"]{}

Home page of the regulars from the ◊code{#awk} channel on irc.libera.chat:
◊url[#:link
"http://awk.freeshell.org/HomePage"]{}

A focal point of updates on AWK development is ◊url[#:link
"https://github.com/freznicek/awesome-awk"]{}

