#!/usr/bin/perl -w
use strict;

sub hash() {
	my @arr = @_;
	foreach (@arr) {
		if ( $_ !~ /^[A-Za-z0-9_ ,\=\>]+$/ ) {
			$! = "incorrect symbol";
			return "error";
		}
	}
	if ( @arr < 2 ) { $! = "empty start"; return "error" }
	my $start = $arr[0];
	shift @arr;
	foreach my $kk (@arr) {
		$_ = $kk;
		my $con1 = my $count1 += s/,//g;
		my $con2 = my $count2 += s/=>//g;
		if ( ( $con1 + 1 ) != $con2 ) {
			$! = "no correct hash";
			return "error";
		}
	}
	@arr = map { split( /, |,/, $_ ) } @arr;
	my %hash = map {

		#$_ =~ s/^\s+|\s+$//g;
		if ( substr( $_, 0, 1 ) eq '=' || substr( $_, -1, 1 ) eq '>' ) {
			$! = "there is no element in the hash";
			return "error";
		}
		split '=>'
	} @arr;
	if ( @arr != keys %hash ) {
		$! = "input double key not correct";
		return "error";
	}
	my @er = grep { $_ eq $start } keys %hash;
	unless ( defined $er[0] ) {
		$! = "input start ($start) not correct";
		return "error";
	}
	my @rez1 = '';
	print STDOUT $start;
	my @start = ($start);
	foreach ( keys %hash ) {
		my $el = $hash{$start};
		print STDOUT "-" . $el;
		$hash{$start} = '?';

		if ( $hash{$el} eq '?' ) { print "\nlooped\n"; return }
		@start = ( @arr . $el );
		$start = $el;
	}
	return '';
}
my $test_file_path = $ARGV[0];
my @arr;
open( FH, "<", "$test_file_path" ) or die "Can not open test file: $!";
while (<FH>) {
	$_ =~ s/[\r\n]+$//s;
	@arr = ( @arr, $_ );

}
my @rez = &hash(@arr);
print STDOUT "@rez\n";

print STDERR "$!\n" if ( @rez eq 'error' );

close(FH);
