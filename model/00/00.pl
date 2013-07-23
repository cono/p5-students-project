#!/usr/bin/perl -w
use strict;

main();

sub main {

    my $file_path = $ARGV[0];
    my $number = qr|[\-+]?\d*\.?\d+(?:[eE][\-+]?\d+)?|;

    open( FH, "<", "$file_path") or die "Can not open test file: $!";

    while ( <FH> ) {
        chomp;
        my ($a, $b, $c) = /^\s*($number)\s*,\s*($number)\s*,\s*($number)\s*$/o;

        my $is_correct_input = ( defined $a && defined $b && defined $c );
        unless ( $is_correct_input ) {
            print STDOUT "Error\n";
            print STDERR "Wrong input parameters for string: $_\n";
            next;
        }

        if ($a == 0) {
            print STDOUT "Error\n";
            print STDERR "Not a quadratic equation.\n";
            next;
        } else {
            my $D = $b * $b - 4 * $a * $c;
            if ($D == 0) {
                print STDOUT "1 (", -0.5 * $b / $a, ")\n";
            } else {
                if ($D > 0) {
                    print STDOUT "2 (", 0.5*(-$b + sqrt($D))/$a, " ", 0.5*(-$b - sqrt($D))/$a , ")\n";
                } else {
                    print STDOUT "0\n";
                }
            }
        }
    }
    close( FH );

    return;
}


