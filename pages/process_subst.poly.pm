#lang pollen

◊page-init{}
◊define-meta[page-title]{Process Substitution}
◊define-meta[page-description]{Process Substitution}

Piping the stdout of a command into the stdin of another is a powerful
technique. But, what if you need to pipe the stdout of multiple
commands? This is where process substitution comes in.

Process substitution feeds the output of a process (or processes) into
the stdin of another process.

Command list enclosed within parentheses

◊example{
>(command_list)

<(command_list)
}

Process substitution uses ◊fname{/dev/fd/<n>} files to send the
results of the process(es) within parentheses to another
process. ◊footnote{This has the same effect as a named pipe (temp
file), and, in fact, named pipes were at one time used in process
substitution.}

Caution: There is no space between the the "<" or ">" and the
parentheses. Space there would give an error message.

◊example{
bash$ echo >(true)
/dev/fd/63

bash$ echo <(true)
/dev/fd/63

bash$ echo >(true) <(true)
/dev/fd/63 /dev/fd/62



bash$ wc <(cat /usr/share/dict/linux.words)
 483523  483523 4992010 /dev/fd/63

bash$ grep script /usr/share/dict/linux.words | wc
    262     262    3601

bash$ wc <(grep script /usr/share/dict/linux.words)
    262     262    3601 /dev/fd/63
}



