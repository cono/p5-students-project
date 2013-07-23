#!/usr/bin/perl -w
use strict;

my $digit = '-?\d+';
my $file = $ARGV[0];

open (FIN, "<", $file) or die "Can't open $file file: $!";

my $strings = 0;
while(my $line = <FIN>){
	++$strings;
	chomp($line);
	my $out = "";
	my $error = "";
	
	$line =~ s/([A-Za-z_])/ /g;

	if ($line =~ /($digit)\D+?($digit)\D+?($digit)/){
		
		$line =~ s/($digit)\D+?($digit)\D+?($digit)/$1,$2,$3/g;

		my ($a, $b, $c) = split(/,/, $line);
		
		my $d = $b ** 2 - 4 * $a * $c;
		
		if ($d < 0){
			$out = "0";
		} elsif ($d == 0) {
			my $x = -$b / (2 * $a);
			$out = "1 ($x)";
		} else {
			my $x1 = (-$b + sqrt($d))/ (2 * $a);
			my $x2 = (-$b - sqrt($d))/ (2 * $a);
			$out = "2 ($x1 $x2)";
		}
		
	} else {
		$out = "Error";
		$error = "Wrong data format at line ".$strings." file $file\n";
	}
	
	print STDOUT "$out\n";
	print STDERR "Error. $error\n" if ($out eq "Error");
}

close (FIN);
