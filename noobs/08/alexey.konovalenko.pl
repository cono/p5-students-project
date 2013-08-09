#!/usr/bin/perl -w

use strict;

package Date;

sub new {
	my$class = shift;
	my $self = {};
	if (@_) {
		my$ref = shift;
		if (ref($ref) eq "HASH" ) {			
			$self -> {year} = $ref->{year};
			$self -> {month} = $ref->{month};
			$self -> {day} = $ref->{day};					
		}
		elsif ( ref($ref) eq "ARRAY" ) {
			$self -> {year}  = $ref->[0];
			$self -> {month} = $ref->[1];
			$self -> {day}   = $ref->[2];			
		}
		else{
			return;
		}
		foreach my$key(keys %$self){				
				if(!($self->{$key})){return;}
		}

	}
	else {

		#Current date:
		#my ( $second, $minute, $hour, $day, $month, $year ) = localtime;
		$self->{year}  = (localtime)[5]+1900;   
		$self->{month} = (localtime)[4]+1; 
		$self->{day}   = (localtime)[3];
		
	}

	return bless($self,$class);
}

#YEAR
sub year {

	my$self = shift;
	if (@_) {
		$self->{year} = shift;
	}

	return $self->{year};

}

#MONTH
sub month {

	my $self = shift;
	if (@_) {
		$self->{month} = shift;
	}
	return $self->{month};
}

#DAY
sub day {
	my $self = shift;
	if (@_) {
		$self->{day} = shift;
	}
	return $self->{day};
}

sub get_struct {	
	my $self = shift;
	return "$self->{year}/$self->{month}/$self->{day}";
}


package Calendar;
#use Date;
our @ISA = qw(Date);
#sub new{
#	my $self = {};
#	return bless($self);
#}

#ADD DAYS
sub add_days{
		my $ref = shift;
	if (@_) {
		$ref->{day} +=shift;
	}
	return $ref;
}

#ADD MONTHS
sub add_months{
		my $ref = shift;
	if (@_) {
		$ref->{month} +=shift;
	}
	return $ref;
}

#ADD YEARS
sub add_years{
		my $ref = shift;
	if (@_) {
		$ref->{year} +=shift;
	}
	return $ref;
}





package main;
if (@ARGV>1){die "Wrong file parameters"; exit 1;}
my$file_param = $ARGV[0];

open(FH,"<",$file_param)or die"Unable to open $file_param: $!\n";
my @lines = readline FH;
close(FH);
 my$test_code = "";
foreach my$line(@lines){
	if(!($line=~/[^\s]/)){next;}
	$test_code.=$line;
}

eval($test_code);
if($@){ print "$@\n";}


