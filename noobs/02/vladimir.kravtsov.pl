#!/usr/bin/perl -w
use strict;
use diagnostics;




my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";


my $fsrt ="";
my @word;

if ( $fsrt = <FH> )
 {

	$fsrt =  " ".$fsrt." ";
	$fsrt =~ s/\s/ /g;
	$fsrt =~ y/ / /s;
	$fsrt =~ s/ //;
	
	if (length $fsrt == ($fsrt =~ y/a-zA-Z_ 0-9//) and $fsrt ne "")
	{
		@word = split(/ /,$fsrt );
		my %res;
		for (@word)
		{
			if ($res {$_})
				{
					$res {$_} = $res {$_}."*";
				}
			else
				{
					$res {$_} = "*";
				}
		
		}
		foreach my $key (sort keys %res)
		{
			print "$key $res{$key}\n";
		}
	}
	else
	{
		print "error\n";
		print STDERR "File contains invalid data\n";
	}
}
else
{
	print "error\n";
	print STDERR "File empty";
}
close ( FH );



