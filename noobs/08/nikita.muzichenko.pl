#!/usr/bin/perl -w
use strict;

package Date;

sub new {
	my $year  = (localtime)[5] + 1900;
	my $month = (localtime)[4] + 1;
	my $day   = (localtime)[3];
	my $self  = {};
	if ( ref $_[1] eq "HASH" ) {
		( $year, $month, $day ) =
		  ( $_[1]->{year}, $_[1]->{month}, $_[1]->{day} );
	}
	elsif ( ref $_[1] eq "ARRAY" ) { ( $year, $month, $day ) = @{ $_[1] } }
	elsif ( ref $_[1] eq "SCALAR" ) {
		( $year, $month, $day ) = ( $_[1], $_[2], $_[3] );
	}
	if ( $year !~ /^[\d]+$/ || $year < 0 ) {
		print STDERR"not full params correct" ;
		return $self = undef;
	}
	if ( $month > 12 || $month < 1 || $month !~ /^[\d]+$/ ) {
		print STDERR"not full params correct" ;
		return $self = undef;
	}
	if ( $day > 31 || $day < 1 || $day !~ /^[\d]+$/ ) {
		print STDERR"not full params correct" ;
		return $self = undef;
	}
	my $proto = shift;
	my $class = ref($proto) || $proto;
	$self->{year}  = $year;
	$self->{month} = $month;
	$self->{day}   = $day;
	bless $self, $class;
	return $self;
}

sub year {
	my $self = shift;
	if ( $_[0] ) { $self->{year} = $_[0] }
	return $self->{year};

}

sub month {
	my $self = shift;
	if ( $_[0] ) { $self->{month} = $_[0] }
	return $self->{month};

}

sub day {
	my $self = shift;
	if ( $_[0] ) { $self->{day} = $_[0] }
	return $self->{day};

}

sub get_struct {
	my $self = shift;
	return "$self->{year}/$self->{month}/$self->{day}";

}

package Calendar;
our @ISA = qw(Date);

sub add_days {
	my $self = shift;
	my $add  = shift;
	if ( $add !~ /^[-\d]+$/ ) {
		print STDERR $! = "outside the range";
		return $self;
	}
	$self->{day} = $self->{day} + $add;
	if ( $self->{day} > 31 || $self->{day} < 1 ) {
		$self->{day} = $self->{day} - $add;
		print STDERR $! = "outside the range";
	}
	return $self;
}

sub add_months {
	my $self = shift;
	my $add  = shift;
	if ( $add !~ /^[-\d]+$/ ) {
		print STDERR $! = "outside the range";
		return $self;
	}
	$self->{month} = $self->{month} + $add;
	if ( $self->{month} > 12 || $self->{month} < 1 ) {
		$self->{month} = $self->{month} - $add;
		print STDERR $! = "outside the range";
	}
	return $self;
}

sub add_years {
	my $self = shift;
	my $add  = shift;
	if ( $add !~ /^[-\d]+$/ ) {
		print STDERR $! = "outside the range";
		return $self;
	}
	$self->{year} = $self->{year} + $add;
	if ( $self->{year} < 0 ) {
		$self->{year} = $self->{year} - $add;
		print STDERR $! = "outside the range";
	}

	return $self;
}

package main;

my $arg;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path" ) or die "Can not open test file: $!";
while (<FH>) {
	$arg = $arg . $_;

	#print STDERR "$res[1]\n" if ( $res[0] eq 'Error' );
}
close(FH);

if ($arg) {
	print STDOUT eval $arg, return '';
}
else { print STDOUT "ERROR\n"; print STDERR $! = "file empty" }

