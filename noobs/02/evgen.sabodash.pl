#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];

open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my $str = <FH>; 
{
	my @array = split (/\s+/,$str);	
	
	foreach (@array) {
		if ($_ =~ /\W/)
		{
			print STDOUT "error\n";
			print STDERR "Expression has invalid characters!\n";
			exit;
		}
	}
	my %cnt; 
	@array = grep { ! $cnt{$_}++; } @array;
	@array = sort @array;
	foreach (@array) {
		print STDOUT $_." ".('*' x $cnt{$_})."\n";
	}
}

close ( FH );