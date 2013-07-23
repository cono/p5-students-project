#!/usr/bin/perl -w
use strict;
use Scalar::Util qw(looks_like_number);

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) {
        my @arr = split(/,/, $_);
                
        if(scalar(@arr) != 3){
            print STDOUT "Error\n";
            print STDERR "Error in line $. of file tests.dat. Incorrect number of parameters of the equation\n";
            next;
        }
        
        my ($a, $b, $c) = @arr;
        
        if (!looks_like_number($a) or !looks_like_number($b) or !looks_like_number($c)){
            print STDOUT "Error\n";
            print STDERR "Error in line $. of file tests.dat. The parameter is not a number\n";
            next;
        }
        
        if ($a == 0) {
           print STDOUT "Error\n";
           print STDERR "Error in line $. of file tests.dat. The equation is not quadratic\n";
           next;
        }
          
        my $D = $b**2 - 4 * $a * $c;
                
        if (NaNdetect($D) == 1) {
           print STDOUT "Error\n";
           print STDERR "Error in line $. of file tests.dat. In the calculations detected NaN\n";
           next;
        }

        my $result;
        
        if ($D < 0) {
            $result = "0\n";
        }
        elsif (($D == 0) or ($D eq "0")){
            my $x = -$b / (2 * $a);          
            $result = "1 ($x)\n";
        }
        else{
            my $DS = sqrt($D);
            my $a2 = $a * 2;
            
            my $x1 = (-$b + $DS) / $a2;
            my $x2 = (-$b - $DS) / $a2;
            
            $result = "2 ($x1 $x2)\n";
        }
           
  print STDOUT $result;
}
close ( FH );

sub NaNdetect{
   if(($_[0] eq "1.#INF") or ($_[0] eq "-1.#INF") or ($_[0] eq "1.#IND") or ($_[0] eq "-1.#IND"))
   {
        1
   } 
}
