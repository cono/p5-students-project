#!/usr/bin/perl -w
use strict;


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my ($a,$b,$c);
my $n_line=0;


while ( <FH> ) {

	$_ =~ s/\s//g;
	$n_line++;
	($a,$b,$c) = split(/,/,$_,3);
	unless ((defined $a) and (defined $b) and (defined $c) and !($a eq "") and !($b eq "") and !($c eq ""))
	{
		print "Error\n";
		print STDERR "Line $n_line data file contains invalid data\n";
	}
	else
	{
		if (($b**2-4*$a*$c)>0)
		{
			print "2 (",( -$b + ($b**2-4*$a*$c)**0.5)/(2*$a)," ",( -$b - ($b**2-4*$a*$c)**0.5)/(2*$a),")\n";
		}
		elsif (($b**2-4*$a*$c)==0)
		{
			print "1 (",-$b/(2*$a),")\n";
		}
		else
		{
			print "0\n";
		}
	}
}
close ( FH );