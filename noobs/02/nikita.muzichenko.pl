#!/usr/bin/perl -w
use strict;

sub getAmount() {
	my %hash = ();
	if ( substr( $_, -1 ) eq " " ) {
		$! = "(' ') incorrect symbol";
		return %hash;
	}
	my @arr = ( split( / /, $_ ) );
	foreach (@arr) {
		if ( $_ =~ /^[A-Za-z0-9_ ]+$/ ) { $hash{$_}++; }
		else {
			$! = "incorrect symbol function will not work";
			return %hash = ();
		}
	}
	return %hash;
}
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path" ) or die "Can not open test file: $!";
while (<FH>) {
	my %res = getAmount();
	unless (  keys %res ) { print STDOUT "error\n"; print STDERR "$!\n" }
	else {
		my @res1 = sort( keys %res );
		foreach (@res1) { print STDOUT  $_ . ' ' . '*' x $res{$_} . "\n" }
	}

}
close(FH);
