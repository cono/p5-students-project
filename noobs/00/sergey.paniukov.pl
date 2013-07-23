#!/usr/bin/perl -w
use strict;

# online calculator:
# http://numsys.ru/


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";


while ( <FH> ) 
{
    my $a;
    my $b;
    my $c;
    my $Dscr;
    my $res;
    my $x;
    my $x1;
	
   ($a, $b, $c) = split(/,/, $_);
	if($a != 0){
		       $Dscr = $b**2-4*$a*$c;
		       if ($Dscr < 0){
		                     $res = '0';
	                         }
		       elsif ($Dscr == 0) {
			                      $x = -$b/(2*$a);
	                              $res = "1 ($x)";
		                          }
	           else {
		            $x = (-$b + $Dscr**0.5)/(2*$a);
			        $x1 = (-$b - $Dscr**0.5)/(2*$a);
			        $res = "2 ($x $x1)";
	                }
	           }
	else {
	     $res="Error";
	     }
	print STDOUT "$res\n";
	print STDERR "$res\n" if ( $res eq 'Error' );
}

close ( FH );
