#!/usr/bin/perl -w

use strict;
use Scalar::Util "looks_like_number";

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my @numbers = ('0'..'9', 'A'..'Z');
my %mapNumbers = ('0', 0, '1', 1, '2', 2, '3', 3, '4', 4, '5', 5, '6', 6, '7', 7, '8', 8, '9', 9, 'A', 10, 'B', 11, 'C', 12, 'D', 13, 'E', 14, 'F', 15, 'G', 16, 'H', 17, 'I', 18, 'J', 19, 'K', 20, 'L', 21, 'M', 22, ,'N', 23, 'O', 24, 'P', 25, 'Q', 26, 'R', 27, 'S', 28, 'T', 29, 'U', 30, 'V', 31, 'W', 32, 'X', 33, 'Y', 34, 'Z', 35);

OUTER:
while ( <FH> ) {
	my @inputFromFile = split /,/;
	
	if(@inputFromFile != 3){
		print STDOUT "Error\n";
		print STDERR "Number of input parametrs not equal 3.\n";
		next;
	}
	
	my ($inOrFrom10, $valueForConvertion, $radix) = @inputFromFile;
	chomp $radix;
	if((!looks_like_number $inOrFrom10) || (!looks_like_number $radix)){
		print STDOUT "Error\n";
		print STDERR "First or/and third parameter is not number.\n";
		next;
	}
	
	if(($radix < 2) || ($radix > 36)){
		print STDOUT "Error\n";
		print STDERR "Radix can't be $radix.\n";
		next;
	}
	
	if(length $valueForConvertion == 0){
		print STDOUT "Error\n";
		print STDERR "Second parameter is absent.\n";
		next;
	}

	if($inOrFrom10 == 1){
		if((!looks_like_number $valueForConvertion) || ($valueForConvertion < 0)){
			print STDOUT "Error\n";
			print STDERR "Number $valueForConvertion in second parameter($valueForConvertion) not included in numeric system with radix 10.\n";
			next;
		}
		my $result = '';
		while($valueForConvertion != 0){
			$result = @numbers[$valueForConvertion % $radix] . $result;
			$valueForConvertion = int($valueForConvertion / $radix);
		}
		print $result . "\n";
	} elsif($inOrFrom10 == 2){
		$valueForConvertion =~ s/\s+//g;
		$valueForConvertion = uc $valueForConvertion;
		my @numbersForConvertion = split(//, $valueForConvertion);
		foreach my $number(@numbersForConvertion){
			if((($number ge '0') && ($number le '9')) || (($number ge 'A') && ($number le 'Z'))){
				if($number gt $numbers[$radix - 1]){
					print STDOUT "Error\n";
					print STDERR "Number $number in second parameter($valueForConvertion) not included in numeric system with radix $radix.\n";
					next OUTER;
				}
			} else {
				print STDOUT "Error\n";
				print STDERR "Number $number in second parameter($valueForConvertion) not included in the interval(1..9, A..Z).\n";
				next OUTER;
			}
		}
		
		my $result = 0;
		@numbersForConvertion = reverse @numbersForConvertion;
		for(my $p = @numbersForConvertion - 1; $p >= 0; $p--){
			$result += ($mapNumbers{$numbersForConvertion[$p]} * ($radix ** $p));
		}
		print $result . "\n";
	} else {
			print STDOUT "Error\n";
			print STDERR "First parameter is not equal to 1 or 2.\n";
			next;
	}
}
close ( FH );