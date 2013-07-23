#!/usr/bin/perl -w
use strict;
use warnings;
#functions
sub convertBaseToUni{
	my $number = shift;
	my $base = shift;
	return undef if $base > 36;
	my @symb = ('0'..'9','A'..'Z');	
	my $ret = "";
	do {
		$ret = $symb[$number % $base] . $ret;
		$number = int($number / $base);
	} while ($number);
	return $ret;
}
sub convertBaseFromUni{
	my $rep  = shift;
    my $base = shift;
	my $number = 0;
	my @nums = (0..9,'A'..'Z');
    my %nums = map { $nums[$_] => $_ } 0..$#nums;
	for( $rep =~ /./g ){
        $number *= $base;
        $number += $nums{$_};
    }
    return $number;	
}
sub checkBase{
	my $number = shift;
	my $base = shift;
	my $answer = 0;
	return undef if $base > 36;
	my @symb = ('0'..'9','A'..'Z');	
	my @res;	
	my $length_symb = scalar(@symb);
	my $length_res = 0;	
	my $i = 0;	
	my $j = 0;		
		foreach (split("",$number)) {
			push @res, $_;
		}		 
		$length_res = scalar(@res);
		for($i = 0; $i < $length_symb; $i = $i + 1) {
			for($j = 0; $j < $length_res; $j = $j + 1) {
				if($res[$j] eq $symb[$i]) {
					if($i >= $base) {
						$answer = $answer + 1;
					}
				}
			}
		}	
	return $answer;
}
#variables
my $filename = 'results.log';
my $filename2 = $ARGV[0];
#my $filename2 = 'tests.dat';
open (HANDLE,'>',$filename) or die "Can not open result file: $!";
open (HANDLE2,'<',$filename2) or die "Can not open test file: $!";;
my $counter = 0;
my @array;
my @array2;
my $result_convert = 0;
# form of array from file and counter
while (<HANDLE2>) {		
	push @array, $_;		
	$counter = $counter + 1; 	
}
my $i = 0;
while ($i < $counter) {
	my $str_content = $array[$i];
	#numbers of every string
	@array2 = split(",",$str_content);
	if( (defined $array2[0]) && (defined $array2[1]) && (defined $array2[2]) ) {		
		#from dec system
		if($array2[0] == 1) {				
			my $b = convertBaseToUni($array2[1], $array2[2]);
			print STDOUT "$b\n";
		}
		#to dec system
		if($array2[0] == 2) {
			my $check = checkBase($array2[1], $array2[2]);
			if($check == 0) {
				my $c = convertBaseFromUni($array2[1], $array2[2]);
				print STDOUT "$c\n";
			} else {
				print STDERR "Error of Base number on string $i\n";
			}
		}
	} else {
		print STDOUT "Error\n";
	}
	$i = $i + 1;		
}
close (HANDLE);
close (HANDLE2);