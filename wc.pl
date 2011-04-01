#!/usr/bin/perl -w

# #array with the 4 options, set to 0s
# if all 4 are 0, use default (-lwc in that order)
# else, use as set

sub lineProcessing($);

use constant {
    LINECOUNT   => 0,
    WORDCOUNT   => 1,
    CHARCOUNT   => 2,
    LONGESTLINE => 3,
};

@files = ();

%options = ("-l", 0,
            "-w", 0,
            "-c", 0,
            "-L", 0);

#          line  word  char  long  file
@count = ();

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
Usage: $0 [OPTION]... [FILE]...
       
Print newline, word, and byte counts for each FILE, and a total line if
more than one FILE is specified.  With no FILE, or when FILE is -,
read standard input.

    --help      display this help and exit
    --version   output version information and exit
    -c,         print the byte counts
    -w,         print the word counts
    -l,         print the newline counts

    -L,         print the length of the longest line

Report bugs to jwon145\@cse.uns -- wait no, ignore them. They are features.
ENDHELP
        exit(0);
    }
    if ($arg =~ /-([A-KM-Za-bd-km-vx-z])/) {
        die("$0: invalid option -- '$1'\nTry `$0 --help' for more information.\n");
    }
    if ($arg =~ /(-[lwcL])/) {
        $options{"$1"} = 1;
    }
	else {
		push @files, $arg;
	}
}

if (scalar(@files) == 0) {
    ($charCount, $wordCount, $lineCount, $longestLine) = (0, 0, 0, 0);
    while (<STDIN>) {
        lineProcessing($_);
    }
    push(@count, [$lineCount, $wordCount, $charCount, $longestLine]);
} else {
    foreach $f (@files) {
        open(F,"<$f") or die "$0: Can't open $f: $!\n";
        ($charCount, $wordCount, $lineCount, $longestLine) = (0, 0, 0, 0);
        while (<F>) {
            lineProcessing($_);
        }
        push(@count, [$lineCount, $wordCount, $charCount, $longestLine, $f]);
        close(F);
    }
}

for $i (0..$#count) {
    for $j (0..$#{$count[$i]}) {
        print("$count[$i][$j] ");
    }
    print("\n");
}

sub lineProcessing($) {
    my ($line) = @_;
    my $tempCharCount = 0;

    foreach $c (split(//, $line)) {
        $tempCharCount++;
        if ($c eq "\n") {
            $lineCount++;
        }
    }

    if ($tempCharCount > $longestLine) {
        $longestLine = $tempCharCount;
        if ($line =~ /\n/) {    # longest line doesn't count newlines; char count does
            $longestLine--;
        }
    }
    $charCount += $tempCharCount;

    @words = split(' ', $line);
    $wordCount += scalar(@words);
    @words = ();
}
