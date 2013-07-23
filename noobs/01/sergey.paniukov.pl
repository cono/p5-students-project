#!/usr/bin/perl -w
use strict;

# online calculator:
# http://numsys.ru/


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) {
	my $element;
	my @mas;
    my $res;
    my $a;
    my $b;
    my $c;
    my $i;
    my @digit;
   
    @mas=('0'..'9','A'..'Z');
    $res='';
    ($a, $b, $c) = split(/,/, $_);
    if($a!=1&&$a!=2){
                     $res='Error';
                    }
    elsif ($a==1){
    		       while ($b!=0){
  	                             $i=$b%$c;
  	                             $b=int($b/$c);
  	                             $res="$mas[$i]$res";
                                }
                  }
    elsif ($a==2){
    	          
    	          }
   	 
	print STDOUT "$res\n";
	print STDERR "$res\n" if ( $res eq 'Error' );
}
close ( FH );