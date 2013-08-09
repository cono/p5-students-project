#!/usr/bin/perl
package My;
sub checkYearMonthDate {
	my $days_in_month = { '1' => 31, '2' => 28, '3' => 31, '4' => 30, '5' => 31, '6' => 30, '7' => 31, '8' => 31, '9' => 30, '10' => 31, '11' => 30, '12' => 31};
	my ($package, $year, $month, $day) = @_;
	$varYear = $year =~ m/^(\d+)$/i;
	$year = $1;
	$varMonth = $month =~ m/^(\d+)$/i;
	$month = $1;
	$varDay = $day =~ m/^(\d+)$/i;
	$day = $1;
	if ( $varYear && $varMonth && $varDay ) {
		if ( exists($days_in_month->{$month}) ) {
			if ( $year % 4 == 0 ) {
				$days_in_month->{2} = 29;
			}
			if ( ($day > 0) && ($day <= $days_in_month->{$month}) ) {
				return {year=>$year, month=>$month, day=>$day};
				
			}
			else {
				return {};
			}
		}
		else {
			return {};
		}
	}
	else {
		return {};
	}	
}
sub isNumber {
	if ( scalar(@_) == 2 ) {
		my ($package, $s) = @_;
		$varS = $s =~ m/^[+-]?\d+$/i;
		return $varS;
	}
	else {
		return 0;
	}
}
1;
package Date;
#use Data::Dumper;
sub new {
	my $class = shift;
	my $data = shift;
	my $type = ref $data;
	if ( $type eq "HASH" ) {
		@keys = keys $data;
		if ( scalar(@keys) == 3 ) {
			$countEq = 0;
			foreach $key (@keys) {
				if ( ($key eq 'year') || ($key eq 'month') || ($key eq 'day') ) {
					if ( $data->{$key} == undef ) {
						$data = {};
						last;
					}
					$countEq++;
				}
			}
			if ( $countEq == 3 ) {
				$data = My->checkYearMonthDate($data->{'year'}, $data->{'month'},$data->{'day'});
			}
			else {
				$data = {};
			}
		}
		else {
			$data = {};
		}
		
	}
	elsif ( $type eq "ARRAY" ) {
		if ( scalar(@{$data}) == 3 ) {
			$data = My->checkYearMonthDate($data->[0], $data->[1], $data->[2]);
		}
		else {
			$data = {};
		}
	}
	else {
		$data = {year=> (localtime)[5] + 1900, month=>(localtime)[4] + 1, day=>(localtime)[3]};
	}
	#print Dumper($data);
	my $self = $data;
	if ( exists($self->{"year"}) && exists($self->{"month"}) && exists($self->{"day"}) ) {
		bless $self, $class;
		return $self;
	}
	else {
		return undef;
	}
}
sub year {
	my $self = shift;
	if (@_) {
		$year = shift;
		$month = $self->{month};
		$day = $self->{day};
		$newData = My->checkYearMonthDate($year, $month, $day);
		if ( exists($newData->{"year"}) && exists($newData->{"month"}) && exists($newData->{"day"}) ) {
			$self->{year} = $year;
		}
	}
	return $self->{year};
}
sub month {
	my $self = shift;
	if (@_) {
		$year = $self->{year};
		$month = shift;
		$day = $self->{day};
		$newData = My->checkYearMonthDate($year, $month, $day);
		#print Dumper($newData);
		if ( exists($newData->{"year"}) && exists($newData->{"month"}) && exists($newData->{"day"}) ) {
			$self->{month} = $month;
		}
	}
	return $self->{month};
}
sub day {
	my $self = shift;
	if (@_) {
		$year = $self->{year};
		$month = $self->{month};
		$day = shift;
		$newData = My->checkYearMonthDate($year, $month, $day);
		if ( exists($newData->{"year"}) && exists($newData->{"month"}) && exists($newData->{"day"}) ) {
			$self->{day} = $day;
		}
	}	
	return $self->{day};
}
sub get_struct {
	my $self = shift;
	return $self->{year}.'/'.$self->{month}.'/'.$self->{day};
}
1;

package Calendar;
use Data::Dumper;
our @ISA = qw(Date);
sub add_years {
	my $self = shift;
	if (@_) {
		$yearAdd = shift;
		if ( My->isNumber($yearAdd) ) {
			$year = $self->{year};
			$month = $self->{month};
			$day = $self->{day};
			$newData = My->checkYearMonthDate($year, $month, $day);
			if ( exists($newData->{"year"}) && exists($newData->{"month"}) && exists($newData->{"day"}) ) {
				$self->year($year + $yearAdd);
				$self->day($day);
				$self->month($month);
				return $self;
			}
			else {
				return undef;
			}
		}
		else {
			return undef;
		}
	}
}
sub add_months {
	my $self = shift;
	if (@_) {
		$monthAdd = shift;
		if ( My->isNumber($monthAdd) ) {
			my $days_in_month = { '1' => 31, '2' => 28, '3' => 31, '4' => 30, '5' => 31, '6' => 30, '7' => 31, '8' => 31, '9' => 30, '10' => 31, '11' => 30, '12' => 31};
			$year = $self->{year};
			$month = $self->{month};
			$day = $self->{day};
			$newData = My->checkYearMonthDate($year, $month, $day);
			if ( exists($newData->{"year"}) && exists($newData->{"month"}) && exists($newData->{"day"}) ) {
				$yearAdd = int( $monthAdd / 12 );
				if ( $monthAdd >= 0 ) {
					$monthAdd = $monthAdd % 12;
					$month = $month + $monthAdd;
				}
				else {
					$monthAdd = abs($monthAdd) % 12;
					if ( $month <= $monthAdd) {
						$yearAdd = $yearAdd - 1;
						$month = 12 - ($monthAdd - $month);
					}
					else {
						$month = $month - $monthAdd;
					}
				}
				$year = $year + $yearAdd;
				
				if ( $year % 4 == 0 ) {
					$days_in_month->{2} = 29;
				}
				if ( $day > $days_in_month->{$month} ) {
					$day = $days_in_month->{$month};
				}
				$self->year($year);
				$self->day($day);
				$self->month($month);
				
				return $self;
			}
			else {
				return undef;
			}
		}
		else {
			return undef;
		}
	}	
}
sub add_days {
	my $self = shift;
	if (@_) {
		$daysAdd = shift;
		if ( My->isNumber($daysAdd) ) {
			my $days_in_month = { '1' => 31, '2' => 28, '3' => 31, '4' => 30, '5' => 31, '6' => 30, '7' => 31, '8' => 31, '9' => 30, '10' => 31, '11' => 30, '12' => 31};
			$year = $self->{year};
			$month = $self->{month};
			$day = $self->{day};
			$newData = My->checkYearMonthDate($year, $month, $day);
			if ( exists($newData->{"year"}) && exists($newData->{"month"}) && exists($newData->{"day"}) ) {
				if ( $daysAdd >= 0 ) {
					for ( $i = 1; $i <= $daysAdd; $i++ ) {
						if ( $year % 4 == 0 ) {
							$days_in_month->{2} = 29;
						}
						$day++;
						if ( $day > $days_in_month->{$month} ) {
							$day = 1;
							$month++;
						}
						if ( $month > 12 ) {
							$month = 1;
							$year++;
						}
					}
				}
				else {
					for ( $i = -1; $i >= $daysAdd; $i-- ) {
						$day--;
						if ( $day == 0  ) {
							$month--;
							if ( $month == 0 ) {
								$year--;
								$month = 12;
							}
							if ( $year % 4 == 0 ) {
								$days_in_month->{2} = 29;
							}
							$day = $days_in_month->{$month};
						}
					}
				}
				$self->year($year);
				$self->day($day);
				$self->month($month);
				
				return $self;
			}
			else {
				return undef;
			}
		}
		else {
			return undef;
		}
	}		
}

1;

package main;
unless (@ARGV) {
	print "ERROR\n";
	die "No data file" 
}
unless ( open(F1, $ARGV[0]) ) {
	print "ERROR\n";
	die "Open file data error\n $!";
}
@file = <F1>;
unless ( close(F1) ) { 
	print "ERROR\n";
	die $!
};
if ( scalar(@file) == 0) {
	print "ERROR\n";
	print STDERR "File $ARGV[0] no data\n";
}
else {
	my $evalCodeText = '';
	foreach $m (@file) {
		$evalCodeText = $evalCodeText.$m;
	}
	eval($evalCodeText);
}