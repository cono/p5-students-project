#! /usr/bin/perl

use warnings;
use strict;

my $an = '[a-zA-Z0-9]+';

my $file = "";
my $target = "";
my $instructions = "";
my @instructions = ();
my %instructions = ();

open FIN, "<", $ARGV[0] or die "Can not open file $ARGV[0]: $!";

$target = <FIN>;
$instructions .= $_ while (<FIN>);

close FIN;

$target       = "" unless defined($target);
$instructions = "" unless defined($instructions);

$file = $target.$instructions;

if ($file =~ /^\s*$/){
		print STDOUT "0\n";
		print STDERR "Empty file!\n";
		exit 1;
}

$target =~ s/#.*?\n/\n/g;
$target =~ s/^\s+|\s+$//;

if ($target !~ m/^$an$/){
	
	print STDOUT "0\n";
	print STDERR "Incorrect target string!\n";
	exit 1;
}
$instructions =~ s/\n#.*?\n/\n/g;
$instructions =~ s/#.*?\n/\n/g;

$instructions =~ s/^\s+|\s+$//;

@instructions = split(/\n*/,$instructions);

foreach (@instructions){

	$_ =~ s/^\s+|\s+$//;
	if (m/^(["']?)($an)\1\s*?(?:=|=>)\s*?(["']?)($an)\3$/){
	
		$instructions{$2} = $4;
	} else {
	
		print STDOUT "0\n";
		print STDERR "Incorrect hash pair or wrong quotes or splitter!\n";
		exit 1;
	}
}

foreach (reverse sort keys %instructions){

	$instructions{$_} =~ tr/a-z0-9/A-Z&-\//;
	$target =~ s/$_/$instructions{$_}/g;
}
$target =~ tr/A-Z&-\//a-z0-9/;
print STDOUT $target."\n";
