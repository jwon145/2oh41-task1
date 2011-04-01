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
Usage: $0 [OPTION]... FILES
       
Compare files line by line.

    --help                  Output this help.
    --version               Output version info.

    -i                      Ignore case differences in file contents.
    -q                      Output only whether files differ.

    -w                      Ignore all white space.
    -B                      Ignore changes whose lines are all blank.
    
    -r                      Recursively compare any subdirectories found.
    -I RE                   Ignore changes whose lines all match RE.
    -N                      Treat absent files as empty.
    -c  -C NUM              Output NUM (default 3) lines of copied context.
    -u  -U NUM              Output NUM (default 3) lines of unified context.
    -p                      Show which C function each change is in.
    -F RE                   Show the most recent line matching RE.
    -y                      Output in two columns.
    --suppress-common-lines Do not output common lines.

FILES are `FILE1 FILE2' or `DIR1 DIR2' or `DIR FILE...' or `FILE... DIR'.
If a FILE is `-', read standard input.

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
