#!/usr/bin/perl -w
use strict;

sub urovnenie() {
	$_ =~ s/\s//g;
	unless ( $_ =~ /^[0-9-,.]+$/ ) {
		return ( "Error", "incorrect symbol function will not work" );
	}
	my @arr = ( split( /,/, $_ ) );
	if ( @arr < 3 ) {
		return ( "Error", "Incorrectly entered value(@arr) " );
	}
	elsif ( $arr[0] == 0 ) {
		return ( "Error",
"(0) can not be a value because there will be a divide by zero error "
		);
	}

	my $a = $arr[0];
	my $b = $arr[1];
	my $c = $arr[2];
	my @x;
	my $discr = ( $b**2 ) - ( 4 * $a * $c );
	if ( $discr > 0 ) {
		$x[0] = ( -$b + sqrt $discr ) / ( 2 * $a );
		$x[1] = ( -$b - sqrt $discr ) / ( 2 * $a );
	}
	elsif ( $discr == 0 ) {
		$x[0] = ( -$b + sqrt $discr ) / ( 2 * $a );
	}
	else { return 0 }
	my $element = $#x + 1;
	my $rez     = "$element (@x)";
}

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path" ) or die "Can not open test file: $!";

while (<FH>) {

	my @res = &urovnenie();

	print STDOUT "$res[0]\n";
	print STDERR "$res[1]\n" if ( $res[0] eq 'Error' );
}
close(FH);
