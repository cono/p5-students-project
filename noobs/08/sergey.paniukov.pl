#!/usr/bin/perl
use warnings;
{
	package Date;
    use POSIX;
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
                return undef if ($tmp !~/^\d+$/);
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
            return undef if ($self->{$key} !~/^\d+$/);
        }
        my $buff = strftime("year>%Y,month>%m,day>%d", 0, 0, 0, $self->{day}, $self->{month}-1, $self->{year} - 1900, -1, -1, -1);
        $self = {split /[,>]/, $buff};
		bless $self, $class;
		return $self;
	}
sub get_struct {
		my $self = shift;
		return $self->{"year"}."/".int($self->{"month"})."/".int($self->{"day"});
	}
sub year {
		my $self = shift;
		if(@_){
            my $tmp = shift;
            if ($tmp =~/^\d+$/) {
                my $buff = strftime("year>%Y,month>%m,day>%d", 0, 0, 0, $self->{day}, $self->{month}-1, $tmp - 1900, -1, -1, -1);
                my %hash = split /[,>]/, $buff;
                foreach my $key (keys %hash) {
                    $self->{$key} = $hash{$key};
                }
            } else {
                warn("Can`t add years");
            }
		}
		return $self->{year};
	}
sub month {
		my $self = shift;
		if(@_){
            my $tmp = shift;
            if ($tmp =~ /^\d+$/) {
                my $buff = strftime("year>%Y,month>%m,day>%d", 0, 0, 0, $self->{day}, $tmp-1, $self->{year} - 1900, -1, -1, -1);
                my %hash = split /[,>]/, $buff;
                foreach my $key (keys %hash) {
                    $self->{$key} = $hash{$key};
                }
            } else {
                warn("Can`t add years");
            }
		}
		return int($self->{month});
	}
sub day {
		my $self = shift;
		if(@_){
            my $tmp = shift;
            if ($tmp =~ /^\d+$/) {
                my $buff = strftime("year>%Y,month>%m,day>%d", 0, 0, 0, $tmp, $self->{month}-1, $self->{year} - 1900, -1, -1, -1);
                my %hash = split /[,>]/, $buff;
                foreach my $key (keys %hash) {
                    $self->{$key} = $hash{$key};
                }
            } else {
                warn("Can`t add years");
            }
		}
		return int($self->{day});
	}
}
{
	package Calendar;
    use POSIX;
    our @ISA = ('Date');
	sub add_years {
		my $self = shift;
		if(@_){
            my $tmp = shift;
            if ($tmp =~/^\d+$/) {
                my $buff = strftime("year>%Y,month>%m,day>%d", 0, 0, 0, $self->{day}, $self->{month}-1, $self->{year}+$tmp - 1900, -1, -1, -1);
                my %hash = split /[,>]/, $buff;
                foreach my $key (keys %hash) {
                    $self->{$key} = $hash{$key};
                }
            } else {
                warn("Can`t add years");
            }
		}
		return $self;
	}
sub add_months {
		my $self = shift;
		if(@_){
            my $tmp = shift;
            if ($tmp =~/^\d+$/) {
                my $buff = strftime("year>%Y,month>%m,day>%d", 0, 0, 0, $self->{day}, $self->{month}-1+$tmp, $self->{year} - 1900, -1, -1, -1);
                my %hash = split /[,>]/, $buff;
                foreach my $key (keys %hash) {
                    $self->{$key} = $hash{$key};
                }
            } else {
                warn("Can`t add months");
            }
		}
		return $self;
	}
sub add_days {
		my $self = shift;
		if(@_){
            my $tmp = shift;
            if ($tmp =~/^\d+$/) {
                my $buff = strftime("year>%Y,month>%m,day>%d", 0, 0, 0, $self->{day}+$tmp, $self->{month}-1, $self->{year} - 1900, -1, -1, -1);
                my %hash = split /[,>]/, $buff;
                foreach my $key (keys %hash) {
                    $self->{$key} = $hash{$key};
                }
            } else {
                warn("Can`t add days");
            }
		}
		return $self;
	}
}
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or print "ERROR\n" and die "Can`t open test file!";
my $ptrname;
my $code;
my $first = 0;
$code = do {local $/;<FH>;};
eval($code);
if ($@) {
    print "ERROR\n" and warn("$@") and exit 1;
}
exit 0;