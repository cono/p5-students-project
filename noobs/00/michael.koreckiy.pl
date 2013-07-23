#!usr/bin/perl
#use warnings;
use strict;


my $test_file_path = $ARGV[0];
open(FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) {
	chop();
	$_ =~ s/\s*//g;
	if (($_ =~ m/[+-]?\d+\.?\d*,[+-]?\d+\.?\d*,[+-]?\d+\.?\d*/) && ($_ != 0))
	{	
		my ($a, $b, $c) = split(/,/, $_);
		my @result;
		my $d = (($b**2) - (4 * $a * $c));
		
		if ($d > 0)
		{
			push @result, ((-$b + sqrt $d) / (2*$a));
			push @result, ((-$b - sqrt $d) / (2*$a));			
			print STDOUT scalar(@result)." (".$result[0]." ".$result[1].")\n";
		} elsif ($d == 0)
		{
			push @result, (-$b/2/$a);
			print STDOUT "1 (".(pop @result).")\n";
		} else
		{
			print "0\n";
		}
	}
	else
	{
		print STDOUT "Error\n";
		if ($_ =~ m/-?\d+,-?\d+,-?\d+/)		{
			print STDERR "Error! This is not a quadratic equation!(a = 0)!\n"
		}
		else
		{
			print STDERR "Error! Look what you`ve done: $_!\n";
		}
	}	
}
close ( FH );