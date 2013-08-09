#!/usr/bin/perl -w
use strict;


#use Scalar::Util qw(looks_like_number);
#my @arr = qw(1 -1 01 1.1 0.5 -0.5 1e1 51 0500 2013 -100 --500 -001);
#foreach my$i(@arr){print "$i = ".looks_like_number($i)."\n"};
#print "_____________\n";


#eval ($ARGV[0]);
#print "\n--------------------------------------\n\n";

{
	package Date;
	use Scalar::Util qw(looks_like_number);
	
	sub _init {
		my $self = shift;
		my @arrParams = ();
		my $error = undef;
		if(@_){
			if( scalar(@_) == 1 ){
				if(ref $_[0] eq 'HASH'){
					if(scalar(keys %{$_[0]}) == 3){
						foreach my $i (sort keys %{$_[0]}){
							if($i =~ /year|month|day/){unshift (@arrParams, ${$_[0]}{$i})}
							else{$error = 'Wrong parameters[1]: incorrect Key name'};
						}
					}
					else{$error = 'Wrong parameters[1]: Hash does not contain 3 parameters'}
				}
				elsif(ref $_[0] eq 'ARRAY'){
					if(scalar(@{$_[0]}) == 3){
						for my $i (0..2){
							if(${$_[0]}[$i]){push (@arrParams, ${$_[0]}[$i])}
							else{$error = 'Wrong parameters[1]: Array contain incorrect parameter'}
						}
						#@arrParams = @{$_[0]};
					}
					else{$error = 'Wrong parameters[1]: Array does not contain 3 parameters'}
				}
				else{$error = 'Wrong parameters[1]: link does not Hash or Array'}
			}
			#elsif(scalar(@_) == 3){
			#	for my $i (0..2){
			#		if(ref $@[$i] eq 'SCALAR'){push (@arrParams, ${$_[$i]})}
			#		elsif(!ref $@[$i]){push (@arrParams, $_[$i])}
			#		else{$error = 'Wrong parameters[3]: parameters does not equal scalar or link to scalar'}
			#	}
			#}
			else{$error = 'Wrong parameters: numbers of parameters does not equal 3'}
			if(scalar @arrParams == 3){$self = $self->_validate_date(@arrParams)}else{$error = 'data array is invalid'}
		}
		else{
			my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
			$self->{year} = $year+1900;
			$self->{month} = $mon+1;
			$self->{day} = $mday;
		}
		if($error){$self = undef; print STDERR "ERROR: _init : $error\n"};
		return $self
	};
	sub new {
		my $class = shift;
		my $self = bless {}, $class;
		#bless $self, $class;
		return $self->_init(@_);
	};
	sub year {
		my $self = shift;
		my $year;
		my $error;
		if(@_){
			if(scalar @_ > 1){$error = 1}
			else{
				if($year = $self->_validate_number(shift,0)){$self->{year} = $year;}
				else{$error = 1}
			}
			if($error){print STDERR "ERROR: set year : too many parameters\n"}
		}
		return $self->{year};
	};
	sub month {
		my $self = shift;
		my $month;
		my $error;
		if(@_){
			if(scalar @_ > 1){$error = 1}
			else{
				if($month = $self->_validate_number(shift,0)){#print "$month\n";
					if($month < 1 || $month > 12){$error = 1}
					else{$self->{month} = $month}
				}
				else{$error = 1}
			}
			if($error){print STDERR "ERROR: set month : too many parameters\n"}
		}
		return $self->{month};
	};
	sub day {
		my $self = shift;
		my $day;
		#my $month;
		#my $year;
		my $error;
		if(@_){
			if(scalar @_ > 1){$error = 1}
			else{
				if($day = $self->_validate_number(shift,0)){#print "$day\n";
					if($day < 1 || $day > $self->_day_in_month( $self->{month}, $self->{year} ) ){$error = 1}
					else{$self->{day} = $day}
				}
			}
			if($error){print STDERR "ERROR: set day : too many parameters\n"}
		}
		return $self->{day};
	};
	sub get_struct {
		my $self = shift;
		my $tmp = $self->{year}."/".$self->{month}."/".$self->{day};
		return $tmp;
	};
	sub _validate_date {
		my $self = shift;
		my $year = $self->_validate_number(shift,0);
		my $month = $self->_validate_number(shift,0);
		my $day = $self->_validate_number(shift,0);
		my $error;
		
		if($month < 1 || $month > 12){$error = 1}
		
		if($month == 4 || $month == 6 || $month == 9 || $month == 11){
			if($day < 1 || $day > 30){$error = 1}
		}
		if($month == 1 || $month == 3 || $month == 5 || $month == 7 || $month == 8 || $month == 10 || $month == 12){
			if($day < 1 || $day > 31){$error = 1}
		}
		if($month == 2){
			if($year%4 == 0){
				if($day < 1 || $day > 29){$error = 1}
			}
			else{if($day < 1 || $day > 28){$error = 1};}
		}
		
		if($error){$self = undef; print STDERR "ERROR: _validate_date : wrong date\n"}
		else{
			$self->{year} = $year;
			$self->{month} = $month;
			$self->{day} = $day;
		}
		return $self;
	}
	sub _validate_number {
		my $self = shift;
		my $number = shift;
		my $checkType = shift;
		my $likeNumber = looks_like_number("$number");
		if($likeNumber == 1 || $likeNumber == 9){
			if($checkType){
				if($likeNumber == 1 || $likeNumber == 9){return $number};} # + or -
			else{
				if($likeNumber == 1){return $number}; # only +
			}
		}
		else{print STDERR "ERROR: _validate_number : The number is not an integer [likeNumber=$likeNumber]\n"}
			
		return 0
	}
	sub _day_in_month {
		my $self = shift;
		my $month = shift;
		my $year = shift;
		my $numberOfDays = 0;
		if($month == 4 || $month == 6 || $month == 9 || $month == 11){$numberOfDays = 30}
		elsif($month == 1 || $month == 3 || $month == 5 || $month == 7 || $month == 8 || $month == 10 || $month == 12){$numberOfDays = 31}
		elsif($month == 2){ if(($year % 4) == 0){$numberOfDays = 29} else{$numberOfDays = 28} }
		else{return 0}
		return $numberOfDays
	}
	1;
}
{
	package Calendar;
	#use base qw(Date);
	our @ISA = qw(Date);
	
	sub add_years {
		my $self = shift;
		if(@_){
			if(scalar @_ > 1){print STDERR "ERROR: add_months : too many parameters\n"}
			else{$self->{year} += $self->_validate_number(shift,1);}
		}
		return $self;
	}
	sub add_months {
		my $self = shift;
		my $error;
		if(@_){
			if(scalar @_ > 1){$error = 1; print STDERR "ERROR: add_months : too many parameters\n"}
			else{
				my $currentMonth = $self->{month};
				my $plusMonth = $self->_validate_number(shift,1);
				my $plusYear = 0;
				my $tmpMonth = $currentMonth + $plusMonth;
				if($plusMonth > 0){
					while($tmpMonth > 12){ $tmpMonth -= 12; $plusYear++; }
				}
				elsif($plusMonth < 0){
					while($tmpMonth < 0){ $tmpMonth += 12; $plusYear--; }
				}
				$self->{month} = $tmpMonth;
				$self->{year} += $plusYear;
			}
		}
		return $self;
	}
	sub add_days {
		my $self = shift;
		my $error;
		if(@_){
			if(scalar @_ > 1){$error = 1; print STDERR "ERROR: add_days : too many parameters\n"}
			else{
				my $currentYear = $self->{year};
				my $currentMonth = $self->{month};
				my $currentDay = $self->{day};
				my $plusDay = $self->_validate_number(shift,1);
				my $plusMonth = 0;
				my $plusYear = 0;
				my $tmpDays = $currentDay + $plusDay;
				#my $tmpMonth = $currentMonth;
				if($plusDay > 0){
					while($tmpDays > $self->_day_in_month($currentMonth,$currentYear)){
						$tmpDays -= $self->_day_in_month($currentMonth,$currentYear);
						$currentMonth++;
						if($currentMonth > 12){$currentMonth -= 12; $currentYear++;}
					}
				}
				elsif($plusDay < 0){
					#print "BEGIN	-days:$tmpDays\n";
					while($tmpDays < 0){
						$currentMonth--;
						if($currentMonth == 0){$currentMonth += 12; $currentYear--;}
						#print "ETERATION: $tmpDays + ".$self->_day_in_month($currentMonth,$currentYear)." = ";
						$tmpDays += $self->_day_in_month($currentMonth,$currentYear);
						#print "$tmpDays	";
						#print "$currentMonth	$currentYear\n";
					}
					#print "END\n";
				}
				$self->{day} = $tmpDays;
				$self->{month} = $currentMonth;
				$self->{year} = $currentYear;
				
			}
		}
		return $self;
	}
	1;
}
	package main;
my $test_file_path;	
if(@ARGV){$test_file_path = $ARGV[0];}
else{print STDOUT "ERROR\n"; die "No incoming parameters\n";}
unless( open( FH, "<", $test_file_path) ){print STDOUT "ERROR\n"; die "Can not open file: $!";}
my $incomingCode = '';
while ( defined(my $file_string = <FH>) ) { $incomingCode .= $file_string; }
unless( close ( FH ) ){print STDOUT "ERROR\n"; die "Can not clouse file: $!";}
eval ($incomingCode);
if($@){print STDOUT "ERROR\n"; print STDERR $@."\n";}



