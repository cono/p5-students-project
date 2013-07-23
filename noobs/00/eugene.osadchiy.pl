#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open (FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) {
	unless($_ eq "\r\n" || $_ eq "\n" )
	{
		chomp($_);
		(my $a, my $b, my $c) = (split /,/, $_);
		
		
		if($a == 0) 
		{
			print STDOUT "Error\n";
			print STDERR "Error. $_. Division by zero. It's a linear equation.\n";
			next;
		}

		if(!defined($a) || $a eq "" || !defined($b) || $b eq "" || !defined($c) || $c eq "")
		{
			print STDOUT "Error\n";
			print STDERR "Error. $_. One or more fiels are undefined.\n";
			next;
		}
		
		if($b==0)
		{
			my $x=sqrt(-$c / $a);
			print STDOUT "2 ($x -$x)\n";
		}
		else
		{
			my $D = $b**2-4*$a*$c;

			if($D > 0) {
				my $x1 = (-$b + sqrt($D)) / (2*$a);
				my $x2 = (-$b - sqrt($D)) / (2*$a);
				print STDOUT "2 ($x1 $x2)\n";
			} else {
				if($D == 0) {
					my $x = -$b / (2*$a);
					print STDOUT "1 ($x)\n";
				} else {
					print STDOUT "0\n";
				}
			}	
		}
	}
	else
	{
		print STDOUT "Error\n";
		print STDERR "Error. Fiels are undefined. Line is empty\n";
	}
}
close (FH);