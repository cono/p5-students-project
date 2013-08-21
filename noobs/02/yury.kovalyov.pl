#!/usr/bin/perl

use warnings;
use strict;

sub printe
{
	my $message = shift;
	print STDOUT "error\n";
	print STDERR $message;
}

( 0 == $#ARGV ) or die "Wrong number of arguments: pass test file name, please.";
my $test_file_name = $ARGV[0];

open ( FH, "<", $test_file_name ) or die "Can not open test file: $!";

my $line = <FH>;

{
	if ( my $invalidData = !( defined ($line) ) )
	{
		printe "Invalid data: check test file is not empty, please.\n";
		last;
	}

	# cut border spaces:
	$line =~ s/^\s+|\s+$//g;

	# idea: $token = '\s*\w+\s*';
	# full token: ^ $token ( $token )* $
	
	if ( my $wrongLine = ( $line !~ m/^\s*\w+\s*(?:\s*\w+\s*)*$/ ) )
	{
		printe "Invalid array of elements: check first line of test file, please.\n";
		last;
	}

	my %hash = ( );

	while ( $line =~ m/\s*(\w+)\s*/g )
	{
		if ( exists $hash{$1} )
		{
			++$hash{$1};
		}
		else
		{
			$hash{$1} = 1;
		}
	}

	my @sorted = sort keys %hash;
	foreach ( @sorted )
	{
		print "$_ ", "*" x $hash{$_}, "\n";
	}

}

close ( FH );
