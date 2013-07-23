#! /usr/bin/perl -w

use strict;
use Scalar::Util "looks_like_number";

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

OUTER:
while ( <FH> ) {

	my @constants = split /,/;
	if((@constants != 3) || ($constants[1] eq '')){
		print STDOUT "Error\n";
		print STDERR "Number of input parametrs not equal 3.\n";
		next;
	}	
	
	foreach my $number (@constants){
		if (!(looks_like_number $number)){
			chomp $number;
			$number =~ s/\s+//g;
			print STDOUT "Error\n";
			print STDERR "Value: '" . $number . "' is not a number.\n";
			next OUTER;
		}
	}
	
	my(($a, $b, $c)) = @constants;
	my $D = $b**2 - 4*$a*$c;
	
	if($D > 0){
		my $x1 = (-$b + sqrt($D)) / (2*$a);
		my $x2 = (-$b - sqrt($D)) / (2*$a);
		print STDOUT "2 (" . join(' ', $x1, $x2) . ")\n";
	} elsif($D == 0){
		my $x12 = (-$b) / (2*$a);
		print STDOUT "1 (" . $x12 . ")\n";
	} else {
		print STDOUT "0\n";
	}
}
close ( FH );
