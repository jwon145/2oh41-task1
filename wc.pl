#!/usr/bin/perl -w

sub main;
sub getOpts;
sub printHelp;
sub printVersion;
sub lineProcessing($);
sub printWC;

use constant {
    LINECOUNT   => 0,
    WORDCOUNT   => 1,
    CHARCOUNT   => 2,
    LONGESTLINE => 3,
};

#          line  word  char  long  file
@count = ();

%options = ("l", 0,
            "w", 0,
            "c", 0,
            "L", 0);

sub main {
    getOpts();

    if (scalar(@ARGV) == 0) {
        ($charCount, $wordCount, $lineCount, $longestLine) = (0, 0, 0, 0);
        while (<STDIN>) {
            lineProcessing($_);
        }
        push(@count, [$lineCount, $wordCount, $charCount, $longestLine]);
    } else {
        foreach $file (@ARGV) {
            open(FILE, "<$file") or die "$0: Can't open $file: $!\n";
            ($charCount, $wordCount, $lineCount, $longestLine) = (0, 0, 0, 0);
            while (<FILE>) {
                lineProcessing($_);
            }
            push(@count, [$lineCount, $wordCount, $charCount, $longestLine, $file]);
            close(FILE);
        }
    }
    printWC();
}

sub getOpts {
    my $numberOfArgs = scalar(@ARGV);
    for (1..$numberOfArgs) {
        $arg = shift(@ARGV);

        printVersion() if ($arg eq "--version");
        printHelp() if ($arg eq "--help");

        if ($arg =~ /^-$/) {
            push(@ARGV, $arg);
        } elsif ($arg =~ /^-/) {
            $arg =~ s/-//;
            my @clusteredArgs = split(//, $arg);
            foreach my $a (@clusteredArgs) {
                if ($a =~ /[wclL]/) {
                    $options{$a} = 1;
                } else {
                    die("$0: invalid option -- '$a'\nTry `$0 --help' for more information.\n");
                }
            }
        } else {
            push(@ARGV, $arg);
        }
    }
}

sub printVersion { 
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

sub printHelp {
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

sub printWC {
# if ($options{"-l"} == 0 && $options{"-w"} == 0 && $options{"-c"} == 0 && $options{"-L"} == 0) { # when no args
#     for $row (0..$#count) {
#         $count[$row][LONGESTLINE] = "";
#     }
# } else {
#     foreach $key (keys(%options)) {
#         if (%option{$key}) {
#             for $row (0..$#count) {
#                 $count[$row][]
#     }
# }

    for $i (0..$#count) {
        for $j (0..$#{$count[$i]}) {
            print("$count[$i][$j] ");
        }
        print("\n");
    }
}

main();
