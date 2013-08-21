#!/usr/bin/perl -w
use strict;

sub Replace;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") || die "Can not open test file: $!";

my $firstString = <FH>;

#Reading first string with data

if ( defined ($firstString) )
{
	chomp $firstString;
	if ($firstString =~ /^[\s]*([\w]+)[\s]*(#.*)?$/)
	{     #/^[\s]*(?:[\w]+[\s]*)+$/
		$firstString = $1;			
	}
	else 
	{
		print STDOUT "0\n";
		print STDERR "Error! Wrong substitution string: \"$firstString\".\n";
		exit 0;
	}
}

my %substList;

while ( <FH> ) {
	chomp;
	if ($_ =~ /^\s*(['"]?)([\w]+)\1\s*=>?\s*(['"]?)([\w]+)\3\s*(#.*)?$/)
	{		
		$substList{$2} = $4;
	}
	elsif ($_ =~ /^\s*(#.*)?$/)
	{
		next;
	}
	else
	{
		print STDOUT "0\n";
		print STDERR "Error! Wrong line: \"$_\"\n";
		exit -1;
	}
}
my @keys = sort {$b ge $a} keys %substList;


my $result = Replace($firstString);

print "$result\n";

close ( FH );
exit 0;

####################################################
sub Replace
{
	my ($temp) = $_[0];
	local $_;
	local $`;
	local $';
	local $&;
	
	if (@_ == 1)
	{			
		foreach (@keys)
		{
			if ($temp =~ /$_/)
			{			
				my ($before) = $`;
				my ($after) = $';
				$before = Replace($before);
				$after = Replace($after);				
				return $before.$substList{$_}.$after;
			}
		}		
		return $temp;
	}
	else
	{
		print STDOUT "Error! Subroutine \"Replace\" was invoked with wrong parameter.\n"
	}	
}
