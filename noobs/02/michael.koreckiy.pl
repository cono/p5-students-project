#!/usr/bin/perl -w
use strict;


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") || die "Can not open test file: $!";
my $counter = 0;
$_ = <FH>;
do {
	chomp();
	if ($counter == 0)
	{	
		$_ =~s/^\s*//;
		$_ =~ s/\s+/ /g;
		
		my @string = split(/ /, $_);
		
		@string = sort @string;
		
		
		my %result;
		for (my $itr = 0; $itr < @string; $itr++)
		{
			if ($string[$itr] =~ m/^\w+$/)
			{
				if (exists $result{$string[$itr]})
				{
					$result{$string[$itr]}++; 
				}
				else
				{
					$result{$string[$itr]} = 1;
				}
			}
			else
			{
				print STDOUT "error\n";
				print STDERR "Error! Wrong symbols: $string[$itr]\n";
				exit -1;
			}
		}		
		my $key;		
		if (scalar(%result))
		{
			foreach $key (sort keys %result) 
			{
				print STDOUT "$key" . " " . "*" x $result{$key} . "\n";
			}
		}
		else
		{
			print STDOUT "error\n";
			print STDERR "Error! The string doesn`t have appropriate words!\n";
		}
		
		
		$counter++;
	}
	else
	{
		print STDERR "Warning! The file has more then 1 string.\n";
		exit 0;
	}
}while ( <FH> );
	
close ( FH );