#!/usr/bin/perl -w
use strict;
use warnings;
#variables
my $filename = 'results.log';
my $filename2 = $ARGV[0];
#my $filename2 = 'tests.dat';
open (HANDLE,'>',$filename) or die "Can not open result file: $!";
open (HANDLE2,'<',$filename2) or die "Can not open test file: $!";
my $counter = 0;
my @array;
my @array2;
my $a = 0;
my $b = 0;
my $c = 0;
my $desc = 0;
my $res1;
my $res2;
# form of array from file and counter
while (<HANDLE2>) {		
	push @array, $_;		
	$counter = $counter + 1; 	
}
#work with every srting
my $i = 0;
while ($i < $counter) {
	my $str_content = $array[$i];
	@array2 = split(",",$str_content);
	if( (defined $array2[0]) && (defined $array2[1]) && (defined $array2[2]) ) {			
		#quadratic equation
		$a = $array2[0];
		$b = $array2[1];
		$c = $array2[2];
		$desc = $b * $b - 4 * $a * $c;
		if($desc > 0) {
			$res1 = (-$b + sqrt($desc) ) / (2 * $a);
			$res2 = (-$b - sqrt($desc) ) / (2 * $a);
			print STDOUT "2($res1 $res2)\n";
		} elsif($desc == 0) {
			$res1 = (-$b + sqrt($desc) ) / (2 * $a);
			print STDOUT "1($res1)\n";
		} else {			
			print STDOUT "0\n";	
		}			
	} else {			
		print STDOUT "Error\n";			
	}
	$i = $i + 1;	
}
close (HANDLE);
close (HANDLE2);