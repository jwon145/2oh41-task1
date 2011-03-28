#!/usr/bin/perl -w

@files = ();

foreach $arg (@ARGV) {
	if ($arg eq "--version") {
		print "$0-git\n";
		exit(0);
	} 
    if ($arg eq "--help") {
        print << ENDHELP;
	Usage: $0 [OPTION]... [FILE]...
       
        ENDHELP
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
