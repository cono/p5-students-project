#!/usr/bin/perl -w
use strict;

sub discriminant {
    if (defined $_[0] && defined $_[1] && defined $_[2]) {
        my $a = $_[0];
        my $b = $_[1];
        my $c = $_[2];
        
        if (!(($a * 1) eq $a) || !(($b * 1) eq $b) || !(($c * 1) eq $c)) {
            print STDOUT "Error\n";
            print STDERR "Not integer value  $a, $b, $c !\n";
            return 1;
        }
        
        if ( $a == 0 ) {
            print STDOUT "Error\n";
            print STDERR "Not root equation !\n";
            return 2;
        }

        my $d = $b*$b-4*$a*$c;
        
        if ( $d > 0) {
            my $x1 = (-$b+sqrt($d))/(2*$a);
            my $x2 = (-$b-sqrt($d))/(2*$a);
            print STDOUT "2 ($x1 $x2)\n";
        } elsif ( $d == 0.0 ) {
            my $x1 = (-$b/(2*$a));
            print STDOUT "1 ($x1)\n";
        } else {
            print STDOUT "0\n";
            print STDERR "equation roots not found for values $a, $b, $c \n";
        }
    } else {
        print STDOUT "Error\n";
        print STDERR "Error! Not enough values\n";
    }
}

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( my $str = <FH> ) {
    # < обработка >
    $str =~ s/\s*//g;
    discriminant(split(",", $str));
}

close ( FH );

exit 0;
