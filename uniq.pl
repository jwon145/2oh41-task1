#!/usr/bin/perl -w

sub main;
sub getOpts;
sub printHelp;
sub printVersion;
sub printUniq($$$);
sub printUniqLast($$);
sub isNotEqual($$);     # for -[ifw] since they change what gets compared
                        # yeah, didn't take into consideration I would be using not on this; double negs throughout!

%options = ("u", 0,
            "i", 0,
            "c", 0,
            "d", 0,
            "f", -1,
            "w", -1);

sub main {
    getOpts();

    exit(0) if ($options{"u"} and $options{"d"}); # mutually exclusive switches that is allowed but do nothing
    
    my $beforeprev;
    my $prev;
    my $line;
    $count = 1;     # for -c
    $isDupe = 0;
    $first = undef;

    while (<>) {
        $beforeprev = $prev;
        $prev = $line;
        $line = $_;
        $first = $line if (not defined $first);
        printUniq($beforeprev, $prev, $line);
    }
    printUniqLast($prev, $line);
}

sub getOpts {
    my $numberOfArgs = scalar(@ARGV);
    for (1..$numberOfArgs) {
        last if (scalar(@ARGV) == 0);
        $arg = shift(@ARGV);

        printVersion() if ($arg eq "--version");
        printHelp() if ($arg eq "--help");

        if ($arg =~ /^-$/) {
            push(@ARGV, $arg);
        } elsif ($arg =~ /^-/) {
            $arg =~ s/-//;
            my @clusteredArgs = split(//, $arg);
            foreach my $a (@clusteredArgs) {
                if ($a =~ /([wf])/) {
                    $options{$a} = $arg;
                    $options{$a} =~ s/^.*$1//;
                    $options{$a} = shift(@ARGV) if ($options{$a} =~ /^$/);
                    if ($options{$a} =~ /^[^0-9]+$/) {
                        die "$0: invalid number for -$a option\n";
                    }
                    last;   # no more options in that cluster; uniq -w9u not allowed
                } elsif ($a =~ /[uicd]/) {
                    $options{$a} = 1;
                } else {
                    die("$0: invalid option -- '$a'\nTry `$0 --help' for more information.\n");
                }
            }
        } else {
            push(@ARGV, $arg);
        }
    }
    
    if (scalar(@ARGV) > 2) {
        die("$0: extra operand `$ARGV[2]'\nTry `$0 --help' for more information.\n");
    } else {
        $output = pop(@ARGV) if (defined $ARGV[1]);
    }
}

sub printVersion { 
print <<ENDVERSION;
$0 (new coreutils) v1.0.2
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

sub printUniq($$$) {
    if (defined $output) {
        open($fh, "> $output") or die "$0: Can't open $output: $!\n";
    } else {
        $fh = *STDOUT;
    }

    my ($beforeprev, $prev, $line) = @_;

    if ($options{"u"}) {
        if (defined $prev and isNotEqual($prev, $line)) {
            if (not defined $beforeprev or isNotEqual($prev, $beforeprev)) {
                print $fh "\t1 " if ($options{"c"});
                print $fh "$prev";
            }
        }
    }
    if (not $options{"u"}) {
        if (not isNotEqual($line, $first)) {
            $count++;
            $isDupe = 1;
        } elsif ($isDupe or not $options{"d"}) {
            print $fh "\t$count " if ($options{"c"});
            print $fh "$first";
            $count = 1;
            $isDupe = 0;
            $first = $line;
        }
    }
}

# can't determine if there will be more lines of input in the while loop
# for example, uniq -u needs to know this, so part of uniq -u has to be outside the loop
sub printUniqLast($$) {
    my ($prev, $line) = @_;
    exit(0) if (not defined $line);  # empty file

    if ($options{"u"}) {
        if (defined $line and (not defined $prev or isNotEqual($line, $prev))) {
            print $fh "\t1 " if ($options{"c"});
            print $fh "$line";
        }
    } else {
        if (not isNotEqual($line, $first)) {
            $count++;
            print $fh "\t$count " if ($options{"c"});
            print $fh "$first";
        } elsif (not $options{"d"}) {
            if (not defined $first or isNotEqual($line, $first)) {
                print $fh "\t1 " if ($options{"c"});
                print $fh "$line";
            }
        }
    }

    if (defined $output) {
        close($fh);
    }
}

sub isNotEqual($$) {
    my ($lineA, $lineB) = @_;
    my ($line1, $line2) = ($lineA, $lineB);  # perl does pass by reference, right?

    if ($options{"i"}) {
        $line1 =~ tr/A-Z/a-z/;
        $line2 =~ tr/A-Z/a-z/;
    }

    if ($options{"f"} > 0) {
        for (1..$options{"f"}) {
            $line1 =~ s/^\s*\S+//;
            $line2 =~ s/^\s*\S+//;
        }
    }

    if ($options{"w"} != -1) {
        $line1 =~ s/^(.{$options{"w"}}).*$/$1/;
        $line2 =~ s/^(.{$options{"w"}}).*$/$1/;
    }

    if ($line1 ne $line2) {
        return 1;
    } else {
        return 0;
    }
}

main();
