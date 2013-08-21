#!/usr/bin/perl -w
use strict;


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") || die "Can not open test file: $!";
my $enterPoint;
my $temp = <FH>;
chomp($temp);
if ($temp =~ /^\s*(\w+)\s*$/)
{
	$enterPoint = $1;
}
else 
{
	print STDOUT "error\n";
	print STDERR "Error! Enter point is not valid.\n";
	exit -1;
}
#print "$enterPoint\n";

$temp = <FH>;
$temp = "$temp ";
my @pairs = split(/,/, $temp);
my %path;
for (my $itr = 0; $itr < @pairs; $itr++)
{
	if ($pairs[$itr] =~ /^\s*(\w+)\s*=>\s*(\w+)\s*$/)
	{
		$path{$1} = $2;		
	}
	else
	{
		print STDOUT "error\n";
		print STDERR "Error! Check input data: \"$pairs[$itr]\"";
		exit -1;
	}
}
my %exposed;
$exposed{$enterPoint} = 0;
my $currentPoint = $enterPoint;
if (exists $path{$enterPoint})
{
	print "$enterPoint";
	do
	{
		print "-$path{$currentPoint}";
		unless (exists $exposed{$path{$currentPoint}})
		{
			$currentPoint = $path{$currentPoint};
			$exposed{$currentPoint} = 0;			
		}
		else
		{
			print "\nlooped\n";
			exit 0;
		}		
	}
	while (exists $path{$currentPoint})
}
else
{
	print STDOUT "error\n";
	print STDERR "Error! The entry point is referenced on not existing hash record.";
	exit -1;
}

close ( FH );