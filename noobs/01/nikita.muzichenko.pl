#!/usr/bin/perl -w
use strict;

sub namber() {
	$_ =~ s/\s//g;
	unless ( $_ =~ /^[A-Za-z0-9,]+$/ ) {
		return ( "Error", "incorrect symbol function will not work" );
	}
	my @arr = ( split( /,/, $_ ) );
	if ( @arr < 3 ) { return ( "Error", "Incorrectly entered value(@arr)" ) }
	elsif ( $arr[0] > 2 ) {
		return ( "Error",
"Incorrectly entered value($arr[0]) because there can be only 1 or 2"
		);
	}
	elsif ( $arr[2] > 36 ) {
		return ( "Error",
"Incorrectly entered value($arr[2]) because there may be a maximum 36"
		);
	}
	my $coder  = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	my $a      = $arr[0];
	my $namber = uc( $arr[1] );
	my $sys    = $arr[2];
	my @rez    = ("");
	if ( $a == 1 ) {

		while ( $namber != 0 ) {
			my $r = $namber % $sys;
			$rez[0] = substr( $coder, $r, 1 ) . $rez[0];
			$namber = int( $namber / $sys );
		}
	}
	else {
		my @arrnamber = split( //, $namber );
		foreach (@arrnamber) {
			if ( index( $coder, $_ ) > $sys ) {
				return ( "Error",
"This number($namber) can not be transferred to this system value($sys)"
				);
			}

		}

		$rez[0] = 0;
		for ( my $int = 0 ; $int <= $#arrnamber ; $int++ ) {
			$rez[0] =
			  index( $coder, $arrnamber[$int] ) *
			  ( $sys**( $#arrnamber - $int ) ) + $rez[0];
		}
	}
	return @rez;
}
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path" ) or die "Can not open test file: $!";
while (<FH>) {

	my @res = &namber();
	print STDOUT "$res[0]\n";
	print STDERR "$res[1]\n" if ( $res[0] eq 'Error' );
}
close(FH);
