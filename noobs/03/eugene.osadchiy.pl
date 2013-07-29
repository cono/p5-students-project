#! /usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open (FH, "<", "$test_file_path") or die "Can not open test file: $!";

$_=<FH>;
chomp($_);
if(/^\s*\w+\s*$/)
{
	$_=~s/\s*//g;
	my $start = $_;
	
	$_=<FH>;
	if(/[^\w\s\,=>]|\,\s*$/)
	{
		print STDOUT "error\n";
		die "error. Not valid data in second string\n";
	}
	else
	{
		chomp($_);
		my %hash;
		my @array = split /\s*,\s*/, $_;
		foreach my$item (@array)
		{
			if($item=~/^\s*\w+\s*=>\s*\w+\s*$/)
			{
				my @temp=(split /\s*\t*=>\s*\t*/, $item);
				$temp[0]=~s/\s*//g;
				$temp[1]=~s/\s*//g;
				%hash = (%hash, $temp[0] => $temp[1]);	
			}
			else
			{
				print STDOUT "error\n";
				die "error. Not valid data in one or move pair.\n";
			}
		}
		my $current = $start;
		my $path;

		if(exists $hash{$current})
		{
			do
			{
				$path=$path.$current."-";
				$current=$hash{$current};
				
				if($path=~/-?$current-?/)
				{
					$start=$current;
				}
					
			}while ($current ne $start && (exists $hash{$current}));
			$path=$path.$current;
			print STDOUT "$path\n";
						
			if($current eq $start)
			{
				print STDOUT "looped\n";
			}
		}
		else
		{
			print STDOUT "error\n";
			die "error. Start item not found\n";
		}
	}
}
else
{
	print STDOUT "error\n";
	die "error. Start item not found\n";
}
close (FH);
