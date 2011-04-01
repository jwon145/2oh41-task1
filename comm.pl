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
Usage: $0 [OPTION]... FILE1 FILE2
       
Compare sorted files FILE1 and FILE2 line by line.

With no options, produce three-column output.  Column one contains
lines unique to FILE1, column two contains lines unique to FILE2,
and column three contains lines common to both files.

    --help              display this help and exit
    --version           output version information and exit

    -1                  suppress lines unique to FILE1
    -2                  suppress lines unique to FILE2
    -3                  suppress lines that appear in both files

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
