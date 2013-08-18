#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open (FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) {
	my $res;
	unless($_ eq "\r\n" || $_ eq "\n")
	{
		(my $a, my $b, my $notation);
		chomp($_);
		if(/^\s*(\d+)\s*,\s*(\w+)\s*,\s*(\d+)\s*/)
		{
			($a, $b, $notation) = ($1, $2, $3);
		}
		else
		{
			print STDOUT "Error\n";
			print STDERR "Error. $_. One or more fiels are undefined.\n";
			next;
		}
		
		if($a == 1 && $notation<37 && $notation>1)
		{
			$res = "";
			while( $b >= $notation )
			{
				my $temp = $b % $notation;
				if($temp > 9)
				{
					$res = chr($temp%10 + 65).$res;
				}
				else
				{
					$res = $temp.$res;
				} 
				$b = int($b / $notation);
			}
			if ($b % $notation > 9) 
			{
				$res = chr(65+ $b % $notation%10).$res;	
			}
			else 
			{
				$res = $b.$res
			}
			print STDOUT "$res\n"
		}
		else {
			if($a == 2  && $notation<37 && $notation>1)
			{
				$b=uc($b);
				my @valid = split //, $b;
				my $i=0;
				my $notation_in_ascii = $notation < 10 ? ord($notation) : (65 + ($notation-10));
				my $cont = 1;
				while($i <= $#valid)
				{
					if(ord($valid[$i]) >= $notation_in_ascii)
					{
						print STDOUT "Error\n";
						print STDERR "Error. $_ Notation of number is over $notation.\n";
						$cont = 0;
						last;
					}
					$i++;
				}
				if($cont)
				{
					$res = 0;
					my @symb = split //, $b;
					my $i = $#symb;
					while ($i >= 0)
					{
						if(ord($symb[$#symb-$i])<65)
						{
							$res += $notation**$i * $symb[$#symb-$i];
						}
						else
						{
							$res += $notation**$i * (ord($symb[$#symb-$i])-55);
						}
						$i--;
					}
					print STDOUT "$res\n"
				}
			}
			else
			{
				print STDOUT "Error\n";
				print STDERR "Error. $_ Invalid operation. Check your notation (2..36) or operation type (1/2).\n"
			}	
		}
	}
	else
	{
		print STDOUT "Error\n";
		print STDERR "Error. Fiels are undefined. Line is empty.\n";
	}
}
