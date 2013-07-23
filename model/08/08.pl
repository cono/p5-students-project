#!/usr/bin/perl 

use strict;
use warnings;

{
	package Date;	
	require Time::Local;

	sub new {
		my $class = shift;
		my $params = shift;

		my $params_type = ref $params;
		my($day, $month, $year, $weekday)=(localtime)[3,4,5,6];
		$year += 1900;

		if($params_type eq "HASH"){
			$year =  $params->{year}  ? $params->{year}  : undef;
			$month = $params->{month} ? $params->{month} : undef;
			$day   = $params->{day}   ? $params->{day}   : undef;
		}elsif($params_type eq "ARRAY"){
			$year  = $params->[0] ? $params->[0] : undef;
			$month = $params->[1] ? $params->[1] : undef;
			$day   = $params->[2] ? $params->[2] : undef;
		}

		unless( $year && $month && $day ){
			return undef;
		}
		
		my $self = {
			year  => $year,
			month => $month,
			day   => $day,
		};

		bless $self, $class;
		return $self;
	}

	sub year {
		my $self = shift;
		if(@_){
			$self->{year} = shift;
		}
		return $self->{year};
	}

	sub month {
		my $self = shift;
		if(@_){
			$self->{month} = shift;
		}
		return $self->{month};
	}

	sub day {
		my $self = shift;
		if(@_){
			$self->{day} = shift;
		}
		return $self->{day};
	}


	sub get_struct {
		my $self = shift;
		return $self->{year} . "/" . $self->{month} . "/" . $self->{day};
	}

};

{
	package Calendar;
	our @ISA = qw(Date);

	sub add_days {
		my $self = shift;
		my $days = shift;
		if($days){
			$self->{day} += $days;
		}
		return $self;
	}

	sub add_months {
		my $self = shift;
		my $months = shift;

		if($months){
			$self->{month} += $months;
		}

		return $self;
	}

	sub add_years {
		my $self = shift;
		my $years = shift;

		if($years){
			$self->{year} += $years;
		}
		return $self;
	}
	
	sub unixtime {
		my $self = shift;
		return timelocal(0, 0, 0, $self->{day}, $self->{month}, $self->{year})
	}
};


my $fl = $ARGV[0];
if(! $fl || ! -f $fl){
	print STDERR "Usage: $0 file\n";
	exit;
}
open(my $fh, '<', $fl) || die "Can't open file $fl \n";
my $code = "";
while(<$fh>){
	$code .= $_;
}
eval($code);



