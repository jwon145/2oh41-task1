#!/usr/bin/perl -w

# near-redundant program since the ARG_MAX limitation apparently removed as of the kernel that CSE's debian runs (ie. 2.6.23): 
# http://www.gnu.org/software/coreutils/faq/coreutils-faq.html#Argument-list-too-long

sub main;
sub getOpts;
sub printHelp;
sub printVersion;

%options = ("n", -1,
            "I", -1);

# $max_args = `getconf ARG_MAX`;    # are we allowed backticks? this would be more portable 
$max_args = 2097152 - 1;                # what it outputs on cse machines

$command = "echo";

sub main {
    getOpts();

    my @stdin_args = ();

    while (<STDIN>) {
        $line = $_;
        foreach $a (split(' ', $line)) {
            chomp $a;
            push(@stdin_args, $a)
        }
    }

    while (scalar(@stdin_args)) {
        my $number_of_args = ($max_args < scalar(@stdin_args)) ? $max_args : scalar(@stdin_args);
        my $args = join(' ', splice(@stdin_args, 0, $number_of_args));
        print `$command $args`;
    }
}

sub getOpts {
    my $numberOfArgs = scalar(@ARGV);
    for (1..$numberOfArgs) {
        last if (scalar(@ARGV) == 0);
        $arg = shift(@ARGV);

        printVersion() if ($arg eq "--version");
        printHelp() if ($arg eq "--help");

        if ($arg =~ /^[^-]/) {
            unshift(@ARGV, $arg);
            last;
        } elsif ($arg =~ /^-/) {
            $arg =~ s/-//;
            my @clusteredArgs = split(//, $arg);
            foreach my $a (@clusteredArgs) {
                if ($a =~ /n/) {
                    $options{$a} = $arg;
                    $options{$a} =~ s/^.*n//;
                    $options{$a} = shift(@ARGV) if ($options{$a} =~ /^$/);
                    if ($options{$a} =~ /^[^0-9]+$/) {
                        die "$0: invalid number for -$a option\n";
                    }
                    last;
                } elsif ($a =~ /I/) {
                    $options{$a} = $arg;
                    $options{$a} =~ s/^.*I//;
                    $options{$a} = shift(@ARGV) if ($options{$a} =~ /^$/);
                    if ($options{$a} =~ /^[^0-9]+$/) {
                        die "$0: invalid number for -$a option\n";
                    }
                    last;
                } else {
                    die("$0: invalid option -- '$a'\nTry `$0 --help' for more information.\n");
                }
            }
        } else {
            push(@ARGV, $arg);
        }
    }

    $command = join(' ', @ARGV) if (scalar(@ARGV));
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
Usage: $0 [-n max-args] [-I replace-str] [--version] [--help] [command [initial-arguments]]

    --help                  Print a summary of the options to xargs and exit.
    --version               Print the version number of xargs and exit.

    -n max-args             Use at most max-args arguments per  command  line.

    -I replace-str          Replace occurrences of replace-str in the initial-arguments with
                            names  read  from  standard input.  Also, unquoted blanks do not
                            terminate input items; instead  the  separator  is  the  newline
                            character.

Report bugs to jwon145\@cse.uns -- wait no, ignore them. They are features.
ENDHELP
    exit(0);
}

main();
