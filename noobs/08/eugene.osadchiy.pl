#!/usr/bin/perl -w
use strict;

{
	package Date;
	use Time::Local;

	sub new {
		my $class = shift;
		my $self;
		if(!@_) {
			$self = {
				year => (localtime(time))[5]+ 1900,
				month => (localtime(time))[4] + 1,
				day => (localtime(time))[3],
			};
		}
		else {
			if("ARRAY" eq ref $_[0]) {
				my ($year, $month, $day) = (@{$_[0]});
				eval {
					timelocal( 0, 0, 0, $day, $month-1, $year);
				};
				if($@) {
					print STDERR "$@\n";
					return undef;
				}
				$self = {
					year => $year,
					month => $month,
					day => $day,
				};
			}
			elsif("HASH" eq ref $_[0]) {
				my $year = $_[0]{year};
				my $month = $_[0]{month};
				my $day = $_[0]{day};
				eval {
					timelocal( 0, 0, 0, $day, $month-1, $year);
				};
				if($@ || !defined($year)) {
					print STDERR "$@\n";
					return undef;
				}
				$self = {
					year => $year,
					month => $month,
					day => $day,
				};
			}
			else {
				print STDERR "Not valid object.\n";
				return undef;
			}
		}
		bless $self, $class;
		return $self;
	}

	sub year {
		my $self = shift;
		if(@_) {
			my $year = shift;
			eval {
				timelocal( 0, 0, 0, $self->{day}, $self->{month}-1, $year);
			};
			if($@) {
				print STDERR "$@\n";
				return $self->{year};
			}
			$self->{year} = $year;
			return $self;
		}
		return $self->{year};
	}
	sub month {
		my $self = shift;
		if(@_) {
			my $month = shift;
			eval {
				timelocal( 0, 0, 0, $self->{day}, $month-1, $self->{year});
			};
			if($@) {
				print STDERR "$@\n";
				return $self->{month};
			}
			$self->{month} = $month;
			return $self;
		}
		return $self->{month};
	}
	sub day {
		my $self = shift;
		if(@_) {
			my $day = shift;
			eval {
				timelocal( 0, 0, 0, $day, $self->{month}-1, $self->{year});
			};
			if($@) {
				print STDERR "$@\n";
				return $self->{day};
			}
			$self->{day} = $day;
			return $self;
		}
		return $self->{day};
	}
	sub get_struct {
		my $self = shift;
		eval {
			timelocal( 0, 0, 0, $self->{day}, $self->{month}-1, $self->{year});
		};
		if($@) {
			print STDERR "$@\n";
			return;
		}
		return $self->{year} . "/" . $self->{month} . "/" . $self->{day};
	}

	1;
}

{
	package Calendar;
	use Time::Local;
	our @ISA = qw(Date);

	sub add_years {
		my $self = shift;
		if(@_) {
			$self->{year} += shift;
			return $self;
		}
		return $self->{year};
	}
	sub add_months {
		my $self = shift;
		if(@_) {
			my $mon = shift;
			my $delta = $mon + $self->{month};
			$self->{month} = $delta % 13;
			if($self->{month} == 0)
			{
				$self->{month} = 1;
			} 
			$self->{year} += int($delta/13);
			return $self;
		}
		return $self->{month};
	}
	sub add_days {
		my $self = shift;
		if(@_) {
			my $time = timelocal( 0, 0, 0, $self->{day}, $self->{month}-1, $self->{year});
			my $delta = shift;
			$time += $delta * 24 * 60 * 60;
			$self->{day} = (localtime($time))[3];
			$self->{month} = (localtime($time))[4]+1;
			$self->{year} = (localtime($time))[5]+1900;
			return $self;
		}
		return $self->{days};
	}
	1;
}

{
	package main;

	my $test_file_path = $ARGV[0];
	open (FH, "<", "$test_file_path") or die "Can not open test file: $!";

	my $file;
	while (<FH>) {
		$file .= $_;
	}

	eval ($file);
	if ($@) {
		print "ERROR\n";
		die "$@\n";
	}
}