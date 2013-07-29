#! /usr/bin/perl -w
use strict;
my $file = "";
my %hash = ();

open FIN, $ARGV[0] or die "Can not open file $ARGV[0]: $!";
$file .= $_ while (<FIN>);
close FIN;

chomp($file);

if ($file =~ /^\s*$/){
		print STDOUT "Error\n";
		print STDERR "Empty file!\n";
		exit 1;
}

if (index($file,"\n") != -1){
		print STDOUT "Error\n";
		print STDERR "More than one line in file! Or empty first line\n";
		exit 1;
}

my @array = split(/\s+/,$file);

foreach (@array){

	if ($_ !~ m/^\w+$/){
		
		print STDOUT "Error\n";
		print STDERR "Not a word symbol!\n";
		exit 1;
	}
}

$hash{$_}++ foreach (@array);

print STDOUT $_." ".("*" x $hash{$_})."\n" foreach (sort keys %hash);
