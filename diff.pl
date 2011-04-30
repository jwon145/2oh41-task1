#!/usr/bin/perl -w

sub main;
sub getOpts;
sub printHelp;
sub printVersion;
sub removeDirPrefix(\@$);
sub isEqual($$);
sub LCSLength(\@\@);
sub backTrack(\@\@\@$$);
sub getDiff(\@\@\@$$);
sub printDiff;

%options = ("1", 0,
            "q", 0,
            "w", 0,
            "B", 0,
            "r", 0,
            "N", 0,
            "p", 0,
            "y", 0,
            "scl", 0,
            "I", undef,
            "c", undef,
            "u", undef,
            "F", undef,
            "bothDir", 0); # when both files are directories, output is different

@diff_output = ();

sub main {
    getOpts();

    my (@file1, @file2);

    if (-f $ARGV[0]) {
        open(my $fh1, "< $ARGV[0]") or die "$0: Can't open $file: $!\n";
        @file1 = <$fh1>;
        close($fh1);
    } elsif (-d $ARGV[0]) {
        @file1 = glob("$ARGV[0]/*");
        removeDirPrefix(@file1, $ARGV[0]);
    }
    if (-f $ARGV[1]) {
        open(my $fh2, "< $ARGV[1]") or die "$0: Can't open $file: $!\n";
        @file2 = <$fh2>;
        close($fh2);
    } elsif (-d $ARGV[1]) {
        @file2 = glob("$ARGV[1]/*");
        removeDirPrefix(@file2, $ARGV[1]);
    }

    my @c = LCSLength(@file1, @file2);

    my $i = scalar(@file1);
    my $j = scalar(@file2);
    getDiff(@c, @file1, @file2, $i, $j);
    printDiff();
}

sub getOpts {
    my $numberOfArgs = scalar(@ARGV);
    for (1..$numberOfArgs) {
        last if (scalar(@ARGV) == 0);
        $arg = shift(@ARGV);

        printVersion() if ($arg eq "--version");
        printHelp() if ($arg eq "--help");

        if ($arg eq "--suppress-common-lines") {
            $options{"scl"} = 1;
        } elsif ($arg =~ /^-/) {
            $arg =~ s/-//;
            my @clusteredArgs = split(//, $arg);
            foreach my $a (@clusteredArgs) {
                if ($a =~ /[uUcC]/) {    # takes numbers
                    $a_lwr = $a;
                    $a_lwr =~ tr/A-Z/a-z/;
                    $options{$a_lwr} = $arg;
                    $options{$a_lwr} =~ s/^.*n//;
                    $options{$a_lwr} = shift(@ARGV) if ($options{$a_lwr} =~ /^$/);
                    if (not defined $options{$a_lwr}) {
                        unshift(@ARGV, $options{$a_lwr});
                        $options{$a_lwr} = 3;
                    } elsif ($options{$a_lwr} =~ /^[^0-9]+$/) {
                        die "$0: invalid number for -$a option\n";
                    }
                    last;
                } elsif ($a =~ /[IF]/) {    # takes regex
                    $options{$a} = $arg;
                    $options{$a} =~ s/^.*I//;
                    $options{$a} = shift(@ARGV) if ($options{$a} =~ /^$/);
                    if (not defined $options{$a}) {
                        die "$0: invalid number for -$a option\n";
                    }
                    last;
                } elsif ($a =~ /[iqwBrNpy]/) {
                    $options{$a} = 1;
                } else {
                    die("$0: invalid option -- '$a'\nTry `$0 --help' for more information.\n");
                }
            }
        } else {
            push(@ARGV, $arg);
        }
    }
    if (-d $ARGV[0] and -d $ARGV[1]) {
        $options{"bothDir"} = 1;
    }
    if (not -d $ARGV[0] and not -f $ARGV[0]) {
        die "$0: $ARGV[0] not a file or directory\n";
    }
    if (not -d $ARGV[1] and not -f $ARGV[1]) {
        die "$0: $ARGV[1] not a file or directory\n";
    }
}

sub printVersion { 
print <<ENDVERSION;
$0 (new coreutils) git
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

sub removeDirPrefix(\@$) {
    my ($list, $dir) = @_;
    foreach my $x (@$list) {
        $x =~ s/^$dir//;
        $x =~ s/^\/// if ($x =~ /^\//);
    }
}

sub isEqual($$) {
    my ($lineA, $lineB) = @_;
    my ($line1, $line2) = ($lineA, $lineB);

    if ($options{"i"}) {
        $line1 =~ tr/A-Z/a-z/; 
        $line2 =~ tr/A-Z/a-z/; 
    }

    if ($options{"w"}) {
        $line1 =~ s/\s//g; 
        $line2 =~ s/\s//g; 
    }

    if ($line1 eq $line2) {
        return 1;
    } else {
        return 0;
    }
}

sub LCSLength(\@\@) {       # based on pseudocode on wikipedia page for longest common subsequence problem
    my ($ref1, $ref2) = @_;
    my @file1 = @$ref1;
    my @file2 = @$ref2;

    for my $i (0..scalar(@file1)) {
        $c[$i][0] = 0;
    }
    for my $j (0..scalar(@file2)) {
        $c[0][$j] = 0;
    }
    for my $i (1..scalar(@file1)) {
        for my $j (1..scalar(@file2)) {
            if (isEqual($file1[$i-1], $file2[$j-1])) {
                $c[$i][$j] = $c[$i-1][$j-1] + 1;
            } else {
                $c[$i][$j] = $c[$i][$j-1] > $c[$i-1][$j] ? $c[$i][$j-1] : $c[$i-1][$j];
            }
        }
    }
    return @c;
}

sub getDiff(\@\@\@$$) {       # based on pseudocode on wikipedia page for longest common subsequence problem
    my ($ref1, $ref2, $ref3, $i, $j) = @_;
    my @c = @$ref1;
    my @file1 = @$ref2;
    my @file2 = @$ref3;

    if ($i > 0 and $j > 0 and isEqual($file1[$i-1], $file2[$j-1])) {
        getDiff(@c, @file1, @file2, $i-1, $j-1);
        push(@diff_output, "  $file1[$i-1]");
    } else {
        if ($j > 0 and ($i == 0 or $c[$i][$j-1] >= $c[$i-1][$j])) {
            getDiff(@c, @file1, @file2, $i, $j-1);
            push(@diff_output, "> $file2[$j-1]");
        } elsif ($i > 0 and ($j == 0 or $c[$i][$j-1] < $c[$i-1][$j])) {
            getDiff(@c, @file1, @file2, $i-1, $j);
            push(@diff_output, "< $file1[$i-1]");
        }
    }
}

sub printDiff {
    if (not $options{"bothDir"}) {
        foreach my $diff_line (@diff_output) {
            print "$diff_line" unless ($diff_line =~ /^ /);
        }
    } else {
        foreach my $diff_line (@diff_output) {
            $diff_line =~ s/^</Only in $ARGV[0]:/;
            $diff_line =~ s/^>/Only in $ARGV[1]:/;
            print "$diff_line\n" unless ($diff_line =~ /^ /);
        }
    }
}

main();
