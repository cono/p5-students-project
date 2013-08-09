#!/usr/bin/perl


use strict;
use warnings;

{
	package Date;
    use POSIX;
    use Time::Local;
	sub new {
		my $class = shift;
		my $self = shift;
        if (!defined $self) {
            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime(time);
            $self = {
                year  => 1900+$year, 
                month => $mon,
                day   => $mday
            };
        } elsif (ref($self) eq "ARRAY") {
            foreach my $tmp(@$self) {
                if (!defined $tmp) {
                    return undef;
                }
                return undef if (! $tmp =~ m/^\d+/);
            }
            $self = {
                year  => @$self[0], 
                month => @$self[1],
                day   => @$self[2]
            };
        } 
        if (scalar(keys %$self) != 3) {
            return undef;
        }
        foreach my $key (keys %$self) {
            if (!defined $self->{$key}) {
                return undef;
            }
            return undef if (! $self->{$key} =~ m/^\d+/);
        }
		bless $self, $class;
		return $self;
	}

	sub get_struct {
		my $self = shift;
		return $self->{"year"}."/".$self->{"month"}."/".$self->{"day"};
	}
    
	sub year {
		my $self = shift;
        my $oldval = $self->{year};
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

}
{
	package Calendar;
    use POSIX;
    use Time::Local 'timelocal_nocheck';
    our @ISA = ('Date');
     
	sub add_years {
		my $self = shift;
		if(@_){
            my $tmp = shift;
            $self->{year} = int(strftime("%Y", 0, 0, 0, $self->{day}, $self->{month}-1, $self->{year}+$tmp - 1900, -1, -1, -1));
            $self->{month} = int(strftime("%m", 0, 0, 0, $self->{day} , $self->{month}-1, $self->{year}+$tmp - 1900, -1, -1, -1));
            $self->{day} = int(strftime("%d", 0, 0, 0, $self->{day} , $self->{month}-1, $self->{year}+$tmp - 1900, -1, -1, -1));
		}
		return $self;
	}
    
	sub add_months {
		my $self = shift;
		if(@_){
            my $tmp = shift;
            $self->{year} = int(strftime("%Y", 0, 0, 0, $self->{day}, $self->{month}-1+$tmp, $self->{year} - 1900, -1, -1, -1));
            $self->{month} = int(strftime("%m", 0, 0, 0, $self->{day} , $self->{month}-1+$tmp, $self->{year} - 1900, -1, -1, -1));
            $self->{day} = int(strftime("%d", 0, 0, 0, $self->{day} , $self->{month}-1+$tmp, $self->{year} - 1900, -1, -1, -1));
		}
		return $self;
	}
    
	sub add_days {
		my $self = shift;
		if(@_){
            my $tmp = shift;
            #my $unixtime = timelocal_nocheck(0,0,0,$self->{day} + $tmp,$self->{month},$self->{year});
            #my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($unixtime);
            $self->{year} = int(strftime("%Y", 0, 0, 0, $self->{day}+$tmp , $self->{month}-1, $self->{year} - 1900, -1, -1, -1));
            $self->{month} = int(strftime("%m", 0, 0, 0, $self->{day}+$tmp , $self->{month}-1, $self->{year} - 1900, -1, -1, -1));
            $self->{day} = int(strftime("%d", 0, 0, 0, $self->{day}+$tmp , $self->{month}-1, $self->{year} - 1900, -1, -1, -1));
            #print int(strftime("%m", 0, 0, 0, $mday , $mon-1, $year, -1, -1, -1));
		}
		return $self;
	}
}

# use first argument of script as file name whith data
my $test_file_path = $ARGV[0];
# open file and get file handler or die
open( FH, "<", "$test_file_path") or die "Missing file names";
my $ptrname;
my $code;
my $first = 0;
$code = do {local $/;<FH>;};

eval($code);
if ($@) {
    print "ERROR\n";
    warn("$@");
    exit 1;
}


exit 0;

