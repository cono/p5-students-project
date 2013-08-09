#! /usr/bin/perl

my $code = "";
my $file = $ARGV[0];

open my $fh, "<", $file or die "can not open file $file: $!";
$code .= $_ while(<$fh>);
close $fh;

{# class Date
	package Date;
	
	sub new{
		my $class = shift();
		my $self = shift();
		
		if (not defined $self){
		
			my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
			$self = {
				year	=>	$year + 1900,
				month	=>	$mon + 1,
				day		=>	$mday,
				backup	=> {
					year	=>	$year + 1900,
					month	=>	$mon + 1,
					day		=>	$mday,					
				},
			};
		} elsif (ref($self) eq "ARRAY"){
		
			return undef if (scalar(@$self) != 3);
			my ($year, $month, $day) = @$self;
			return undef if ($year	!~ /^-?\d+$/);
			return undef if ($month	!~ /^\d+$/ or ($month < 1 or $month > 12));
			return undef if ($day	!~ /^\d+$/ or ($day < 1 or (
				($month =~ m/^(?:[13578]|10|12)$/ and ($day > 31)) or
				($month =~ m/^(?:[469]|11)$/ and ($day > 30)) or
				($month == 2 and not ($year % 4) and $day > 29) or
				($month == 2 and ($year % 4) and $day > 28)
			)));
			$self = {
				year	=>	$year,
				month	=>	$month,
				day		=>	$day,
				backup	=> {
					year	=>	$year,
					month	=>	$month,
					day		=>	$day,		
				},
			};
		} elsif (ref($self) eq "HASH"){
		
			my $year	= $self->{'year'};
			my $month	= $self->{'month'};
			my $day		= $self->{'day'};

			return undef if (scalar(keys %$self) != 3);
			return undef if ($year	!~ /^-?\d+$/);
			return undef if ($month	!~ /^\d+$/ or ($month < 1 or $month > 12));
			return undef if ($day	!~ /^\d+$/ or ($day < 1 or (
				($month =~ m/^(?:[13578]|10|12)$/ and ($day > 31)) or
				($month =~ m/^(?:[469]|11)$/ and ($day > 30)) or
				($month == 2 and not ($year % 4) and $day > 29) or
				($month == 2 and ($year % 4) and $day > 28)
			)));
			
			$self = {
				year	=>	$year,
				month	=>	$month,
				day		=>	$day,
				backup	=> {
					year	=>	$year,
					month	=>	$month,
					day		=>	$day,		
				},
			};
		} else {
			return undef;
		}
		
		bless ($self, $class);
		return $self;
	}
	sub check{
		my $self = shift();
		
		my $year = $self->{'year'};
		my $month = $self->{'month'};
		my $day = $self->{'day'};
		
		return undef if ($year	!~ /^-?\d+$/);
		return undef if ($month	!~ /^\d+$/ or ($month < 1 or $month > 12));
		return undef if ($day	!~ /^\d+$/ or ($day < 1 or (
			($month =~ m/^(?:[13578]|10|12)$/ and ($day > 31)) or
			($month =~ m/^(?:[469]|11)$/ and ($day > 30)) or
			($month == 2 and not ($year % 4) and $day > 29) or
			($month == 2 and ($year % 4) and $day > 28)
		)));
		return 1;
	}
	sub backup{
	
		my $self = shift();
		my $backup = $self->{'backup'};
		
		$self->{'year'} = $backup->{'year'};
		$self->{'month'} = $backup->{'month'};
		$self->{'day'} = $backup->{'day'};
	}
	sub update{
		
		my $self = shift();
		my $backup = $self->{'backup'};
		
		$backup->{'year'} = $self->{'year'};
		$backup->{'month'} = $self->{'month'};
		$backup->{'day'} = $self->{'day'};
	}
	sub get_struct{
	
		my $self = shift();
		
		if($self->check()){
			
			$self->update();
		} else{
			
			$self->backup();
		}
		
		return $self->{'year'}.'/'.$self->{'month'}.'/'.$self->{'day'}; 
	}
	sub change{
		
		my $self = shift();
		my $value = shift();
		my $var = shift();
		
		$value =~ s/^\s+|\s+$//;
		
		if(defined $value){
			
			if(($var eq 'year' and $value =~ m/^-?\d+$/) or $value =~ m/^\d+$/){
				$self->{$var} = $value;
			}
			return;
		} else {
			
			return $self->{$var};
		}
	}
	sub year{
		return shift()->change(shift(), 'year');
	}
	sub month{
		return shift()->change(shift(), 'month');
	}
	sub day{	
		return shift()->change(shift(), 'day');
	}	
}
{# class Calendar
	package Calendar;
	
	our @ISA = ('Date');
	
	sub add_change{
		
		my $self = shift();
		my $value = shift();
		my $var = shift();
	
		$value =~ s/^\s+|\s+$//;
		
		if(defined($value) and $value =~ m/^-?\d+$/){
			
			$self->{$var} += $value;
			#recount
			return $self;
		} 
		return undef;
	}
	sub add_years{
		return shift()->add_change(shift(), 'year');
	}
	sub add_months{
		return shift()->add_change(shift(), 'month');
	}
	sub add_days{
		return shift()->add_change(shift(), 'day');
	}
}

eval $code;
if ($@){
	print STDERR $@;
	exit 1;
}
