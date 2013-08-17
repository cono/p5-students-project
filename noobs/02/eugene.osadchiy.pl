#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open (FH, "<", "$test_file_path") or die "Can not open test file: $!";

$_=<FH>;

if(/[^\w\s]/)
{
	print STDOUT "error\n";
	die "error. Not valid data in string. Symbols.\n";
}
else
{
	my %hash = ();
	my @array = split /\s+/, $_;
	
	if($array[0] eq '')
	{
		shift @array;			
	}	
	if(scalar @array==0)
	{
		print STDOUT "error\n";
		die "error. Not valid data in string. Empty line.\n";
	}
	foreach my$item (@array)
	{
		if(exists $hash{$item})
		{
			$hash{$item}++; 
		}
		else
		{
			%hash = (%hash, $item => 1);
		}
	}
	foreach my $key (sort keys %hash)
	{
		print "$key ",'*' x $hash{$key}, "\n"; 
	}
}
close(FH);
