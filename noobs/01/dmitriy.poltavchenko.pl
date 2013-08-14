#!/usr/bin/perl -w
use strict;
use Switch;

my @symbols = ('0','1','2','3','4','5','6','7','8','9',
                 'A','B','C','D','E','F','G','H','I','J','K','L','M',
                 'N','O','P','Q','R','S','T','U','V','W','X','Y','Z');

sub index_of_array {
    if (!defined $_[0]) {
        print STDERR "Error! index_of_array require a parameter";
        return -2;
    }
    
    for (my $i=0; $i < $#symbols + 1; $i++) {
        if ( $_[0] eq $symbols[$i] ) {
            return $i;
        }
    }
    return -1;
}

sub number_base_check {
    my $res = 1;
    if (defined $_[0] && defined $_[1]) {
        my $number = $_[0];
        my $base = $_[1];
        my $tmp = 0;
        
        my $len = length($number) - 1; 
        for ( my $i = 0; $i <= $len; $i++ ) {
            my $num = index_of_array(substr( $number, $i, 1 ));
            if ( $num >= $base || $num < 0) {
                $res = undef;
                last;
            }
        }
        return $res;
    } else {
        print STDOUT "Error\n";
        print STDERR "Error! Not enough values in number_base_check function\n";
        return undef;
    }
}

sub dec2any {
    if (defined $_[0] && defined $_[1]) {
        my $number = $_[0];
        my $base = $_[1];
        my $tmp;
        
        if ($number < $base) {
            $tmp = $symbols[$number];
            return $tmp;
        }
        
        $tmp .= dec2any( ($number / $base), $base );
        return $tmp .= $symbols[$number % $base];
    } else {
        print STDOUT "Error\n";
        print STDERR "Error! Not enough values in dec2any function\n";
    }
}

sub any2dec {
    if (defined $_[0] && defined $_[1]) {
        my $number = $_[0];
        my $base = $_[1];
        my $tmp = 0;
        
        my $len = length($number) - 1; 
        for ( my $i = 0; $i <= $len; $i++ ) {
            my $num = index_of_array(substr( $number, $i, 1 ));
            $tmp = $tmp + $num * ($base**($len-$i));
        }
        return $tmp;
    } else {
        print STDOUT "Error\n";
        print STDERR "Error! Not enough values in any2dec function\n";
    }     
}

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( my $str = <FH> ) {
    # < обработка >
    $str =~ s/\s*,\s*/,/g;
    $str =~ s/^\s*//g;
    $str =~ s/\s*$//g;
    $str = uc($str);
    
    my ($a, $b, $c) = split(",", $str);
    if (defined $a && defined $b && defined $c &&
    $a ne "" && $b ne "" && $c ne "") {
        switch ($a) {
            case 1 {
                if ( number_base_check($b, 10) ) {
                    my $number = dec2any($b, $c);
                    print STDOUT "$number\n";
                } else {
                    print STDOUT "Error\n";  
                    print STDERR "Check number notation\n"; 
                }
            }
            case 2 {
                if ( number_base_check($b, $c) ) {
                    my $number = any2dec($b, $c);
                    print STDOUT "$number\n";
                } else {
                    print STDOUT "Error\n"; 
                    print STDERR "Check number notation\n";  
                }
            }
            else {
                print STDOUT "Error\n"; 
                print STDERR "Operation not supported\n";    
            }
        }
    } else {
        print STDOUT "Error\n";
        print STDERR "Error! Not enough values\n";
    }
}

close ( FH );

exit 0;
