#!/usr/bin/perl -w
use strict;


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $lines = 0;


while ( <FH> ) {	
	my $a = 0;
	my $b = 0;
	my $c = 0;
	my $D = 0;
	my $x1 = 0;
	my $x2 = 0;
	$lines++;		
	
	chomp($_);
	if ($_ ne "") {		
		$_ =~ s/\s*//g;	#The "g" stands for "global", which tells Perl to replace all matches, and not just the first one.	
		unless (/^
		    [+-]?\d+(\.\d+)?
		    \,
		    [+-]?\d+(\.\d+)?
		    \,
		    [+-]?\d+(\.\d+)?
		    $/)
		{		
			($a,$b,$c) = split(/,/,$_,3);
			if ($a != 0) {
				$D = ($b**2)-(4*$a*$c);			
			
				if ($D<0) {
					print STDOUT "0\n";				
				}
				elsif ($D==0) {
					$x1 = -($b/(2*$a));
					print STDOUT "1 ($x1)\n";				
				}
				else {
					my $sqrD = sqrt($D);
					$x1 = (-$b+$sqrD)/(2*$a);
					$x2 = (-$b-$sqrD)/(2*$a);
					print STDOUT "2 ($x1 $x2)\n";				
				}			
			}
			else {			
				print STDOUT "Error\n";
				print STDERR "line $lines: Not a quadratic equation\n";
			}
		}
		else {
			print STDOUT "Error\n";
			print STDERR "line $lines: Incorrect input. Digits only\n";	
		}
		
								
	}	
	else {
		print STDOUT "Error\n";
		print STDERR "line $lines: No arguments in line\n";	
	}    
}
close ( FH );

#unless (/^\s*$/) { # if blank lines contain spaces or tabs
	#	print STDOUT "Error\n";	
	#}
	#unless ($_ =~ /^\s*$/) { # =~ binding operator
	#	print STDOUT "Error\n";			
	#}
