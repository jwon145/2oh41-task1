#!/usr/bin/perl -w

@files = ();

%options = ("-u", 0,
            "-d", 0,
            "-i", 0,
            "-c", 0,
            "-f", 0,
            "-w", 0);

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
Usage: $0 [OPTION]... [INPUT [OUTPUT]]

Discard all but one of successive identical lines from INPUT (or
standard input), writing to OUTPUT (or standard output).

    --help              display this help and exit
    --version           output version information and exit
    -u,                 only print unique lines

    -i,                 ignore differences in case when comparing
    -c,                 prefix lines by the number of occurrences
    -d,                 only print duplicate lines

    -f,                 avoid comparing the first N fields
    -w,                 compare no more than N characters in lines

A field is a run of whitespace, then non-whitespace characters.
Fields are skipped before chars.

Note: 'uniq' does not detect repeated lines unless they are adjacent.
You may want to sort the input first, or use `sort -u' without `uniq'.

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
