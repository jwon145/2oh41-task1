#!/usr/bin/perl -w

sub main;
sub getOpts;
sub printHelp;
sub printVersion;
sub lineProcessing($);
sub storeCounts($);
sub addTotal;
sub printWC;

@files = ();

%options = ("l", 0,
            "w", 0,
            "c", 0,
            "L", 0);

sub main {
    getOpts();

    if (scalar(@ARGV)) {
        foreach my $file (@ARGV) {
            open(FILE, "<$file") or die "$0: Can't open $file: $!\n";
            ($charCount, $wordCount, $lineCount, $longestLine) = (0, 0, 0, 0);
            while (<FILE>) {
                lineProcessing($_);
            }
            storeCounts($file);
            close(FILE);
        }
    } else {
        ($charCount, $wordCount, $lineCount, $longestLine) = (0, 0, 0, 0);
        while (<STDIN>) {
            lineProcessing($_);
        }
        storeCounts("");
        push(@ARGV, "");
    }

    
    addTotal() if (scalar(@ARGV) > 1);
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
$0 (new coreutils) v1.0.0
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

sub storeCounts($) {
    my ($file) = @_;
    push(@files, {"file" => $file,
                  "l"    => $lineCount,
                  "w"    => $wordCount,
                  "c"    => $charCount,
                  "L"    => $longestLine});
}

sub addTotal {
    my ($l, $w, $c, $ll) = (0, 0, 0, 0);

    foreach my $i (0..$#files) {
        $l += $files[$i]{"l"};
        $w += $files[$i]{"w"};
        $c += $files[$i]{"c"};
        $ll = $files[$i]{"L"} if ($files[$i]{"L"} > $ll);
    }

    push(@files, {"file" => "total",
                  "l"    => $l,
                  "w"    => $w,
                  "c"    => $c,
                  "L"    => $ll});
}

sub printWC {
    if (not $options{"l"} and not $options{"w"} and not $options{"c"} and not $options{"L"}) { # default
        foreach my $i (0..$#files) {
            foreach my $opt qw(l w c) {
                print "$files[$i]{$opt}\t";
            }
            print "$files[$i]{'file'}\n";
        }
    } else {
        foreach my $i (0..$#files) {
            foreach my $opt qw(l w c L) {
                print "$files[$i]{$opt}\t" if ($options{$opt});
            }
            print "$files[$i]{'file'}\n";
        }
    }
}

main();
