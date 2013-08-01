#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open (FH, "<", "$test_file_path") or die "Can not open test file: $!";

$_ = <FH>;
if(/^\w+$/) 
{	
	my $str = $_;
	chomp($str);
	my %hash = ();
	while ( <FH> ) {
		if(/^\s*#/ || /^\s*$/)
		{
		}
		else
		{
			if(/^\s*(["']?)(\w+)(\1)\s*=>?\s*(["']?)(\w+)(\4)\s*$/)
			{
				%hash = (%hash, $2 => $5);
			}
			else
			{
				print "0\n";
				die "One or more strings are invalid\n";
			}
		}
	}
	close(FH);
	foreach my$item (sort{$b cmp $a} keys %hash)
	{
		unless($str =~ /<\w*$item\w*>/g)
		{
			$str =~ s/$item/<$hash{$item}>/g;
		}
	}
	$str =~s/<|>//g;
	print $str, "\n";
}
else
{
	print "0\n";
	die "First string has invalid characters.\n"
}