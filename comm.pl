#!/usr/bin/perl -w

sub main;
sub getOpts;
sub printHelp;
sub printVersion;

%options = ("1", 0,
            "2", 0,
            "3", 0);

sub main {
    getOpts();

    open(FILE1, "< $ARGV[0]") or die "$0: Can't open $file: $!\n";
    open(FILE2, "< $ARGV[1]") or die "$0: Can't open $file: $!\n";
    my $line1 = <FILE1>;
    my $line2 = <FILE2>;
    
    while (defined $line1 or defined $line2) {
        if (not defined $line1) {
            print "\t" unless ($options{"1"} or $options{"2"});
            print "$line2" unless ($options{"2"});
            $line2 = <FILE2>;
        } elsif (not defined $line2) {
            print "$line1" unless ($options{"1"});
            $line1 = <FILE1>;
        } else {
            if ($line1 lt $line2) {
                print "$line1" unless ($options{"1"});
                $line1 = <FILE1>;
            } elsif ($line1 gt $line2) {
                print "\t" unless ($options{"1"} or $options{"2"});
                print "$line2" unless ($options{"2"});
                $line2 = <FILE2>;
            } elsif ($line1 eq $line2) {
                print "\t" unless ($options{"1"} or $options{"3"});
                print "\t" unless ($options{"2"} or $options{"3"});
                print "$line1" unless ($options{"3"});
                $line1 = <FILE1>;
                $line2 = <FILE2>;
            }
        }
    }

    close(FILE1);
    close(FILE2);
}

sub getOpts {
    my $numberOfArgs = scalar(@ARGV);
    for (1..$numberOfArgs) {
        last if (not scalar(@ARGV));
        $arg = shift(@ARGV);

        printVersion() if ($arg eq "--version");
        printHelp() if ($arg eq "--help");

        if ($arg =~ /^-$/) {
            push(@ARGV, $arg);
        } elsif ($arg =~ /^-/) {
            $arg =~ s/-//;
            my @clusteredArgs = split(//, $arg);
            foreach my $a (@clusteredArgs) {
                if ($a =~ /[123]/) {
                    $options{$a} = 1;
                } else {
                    die("$0: invalid option -- '$a'\nTry `$0 --help' for more information.\n");
                }
            }
        } else {
            push(@ARGV, $arg);
        }
    }
    
    if (scalar(@ARGV) != 2) {
        die("$0: Inappropriate amount of operands\nTry `$0 --help' for more information.\n");
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

main();
