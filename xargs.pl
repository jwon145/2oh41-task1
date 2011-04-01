#!/usr/bin/perl -w

@files = ();

foreach $arg (@ARGV) {
	if ($arg eq "--version") {
print <<ENDVERSION;
$0 (GNU coreutils) git
License WTFPLv2: 
This is free software: it comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar.

Written by Johnny Wong and no other cs2041 students.
ENDVERSION
		exit(0);
	} 
    if ($arg eq "--help") {
print <<ENDHELP;
Usage: $0 [-n max-args] [-I replace-str] [--version] [--help] [command [initial-arguments]]

    --help                  Print a summary of the options to xargs and exit.
    --version               Print the version number of xargs and exit.

    -n max-args             Use at most max-args arguments per  command  line.

    -I replace-str          Replace occurrences of replace-str in the initial-arguments with
                            names  read  from  standard input.  Also, unquoted blanks do not
                            terminate input items; instead  the  separator  is  the  newline
                            character.  Implies -x and -L 1.

Report bugs to jwon145\@cse.uns -- wait no, ignore them. They are features.
ENDHELP
        exit(0);
    }
	# handle other options
	# ...
	else {
		push @files, $arg;
	}
}

foreach $f (@files) {
	open(F,"<$f") or die "$0: Can't open $f: $!\n";
	# process F
	#...
	close(F);
}
