#!/usr/bin/perl -w
use Data::Dumper;
use strict;

{	package Date;
	
	sub new
	{
		my $class = shift;
		my $self;
		if (defined $_[0])
		{			
			my $param = shift;
			if (ref($param) eq 'HASH')
			{
				$self = DateFromHash($param);
				#print $self;
			}
			elsif (ref($param) eq 'ARRAY')
			{
				$self = DateFromArray($param);
			}
			else
			{
				#What if $param is something else????
			}
		}
		else
		{
			my @date = localtime();
			
			$date[5] += 1900; 
			$date[4] += 1;
			$self = {	array => ["$date[5]",
									"$date[4]",
									"$date[3]"
								],
					 
						year => "$date[5]",
						month => "$date[4]",
						day => "$date[3]"
					};			
		}
				
		bless $self, $class if defined $self;	
		return $self;
	}

	sub DateFromHash
	{
		my $param = shift;
		my @example = ('year','month','day');
		my @temp;
		my @key = keys %$param;
		
		unless (scalar(@key) == 3)
		{
			return undef;
		}
		
		foreach (@example)
		{
			my $str = $_;
			my $count = 0;
			my $index;
			foreach my $itr ( @key)
			{
				if ($itr =~ /^$str$/i)
				{
					$count++;
					if (not defined $param->{$itr})
					{						
						return undef;
					}
					else
					{
						push @temp, $param->{$itr};
					}					
				}
			}
			return undef if($count != 1);
		}	
	
		my $obj = {array => \@temp,
					 
						year => "$temp[0]",
						month => "$temp[1]",
						day => "$temp[2]"
						
					 };
			return $obj;
	}
	
	sub DateFromArray
	{
		my $param = shift;
		unless (scalar(@$param) == 3)
		{
			return undef;
		}
		foreach (@$param)
		{
			return undef if not defined $_;
		}
		unless (($param->[0] > 0) & ($param->[1] <= 12) & ($param->[1] > 0) &
			($param->[2] > 0) & ($param->[2] <= 31))
		{
			return undef;
		}
		my $obj = {array => $param,
					 
						year => "$param->[0]",
						month => "$param->[1]",
						day => "$param->[2]"
						
					 };
			return $obj;
	}

	sub day
	{
		my $self = shift;
		if (defined $_[0])
		{
			my $param = shift;
			$self->{day} = $param;
			$self->{array}->[2] = $param;
		}
		return $self->{day};
	}
	
	sub month
	{
		my $self = shift;
		if (defined $_[0])
		{
			my $param = shift;
			$self->{month} = $param;
			$self->{array}->[1] = $param;
		}
		return $self->{month};
	}
	
	sub year
	{
		my $self = shift;
		if (defined $_[0])
		{
			my $param = shift;
			$self->{year} = $param;
			$self->{array}->[0] = $param;
		}
		return $self->{year};
	}
	
	sub get_struct
	{
		my $self = shift;		
		my $text = $self->{year}."/".$self->{month}."/".$self->{day};
		return "$text";
	}
	
	1;
	}

{	package Calendar;
	
	our @ISA = ('Date');
	
	sub add_months
	{
		my $self = shift;
		my $param = shift;
		
		my $dMonths = 0;
		my $dYears = 0;
		
		if ($param >= 0)
		{
			$dMonths = ($param + $self->{month}) % 12 ;
			$dYears = int (($param + $self->{month}) / 12);
		}
		elsif ($param < 0)
		{
			$dMonths = (($param % 12 - 12) + $self->{month});
			$dYears = int ($param / 12);
			if ($dMonths <= 0)
			{
				$dMonths += 12;
				$dYears-- if (($param % 12) != 0);
			}
		}
				
		
		
		#my $dMonths = ($param + $self->{month}) % 12 + 1;		
		#my $dYears = ($param + $self->{month} - $dMonths) / 12;
		
		$self->{year} += $dYears;
		$self->{array}->[0] = $self->{year};
		
		$self->{month} = $dMonths;
		$self->{array}->[1] = $self->{month};
		return $self;
	}
	
	
	sub add_years
	{
		my $self = shift;
		my $param = shift;
		
		$self->{year} += $param;
		$self->{array}->[0] = $self->{year};		
		
		return $self;
	}
	
	sub add_days
	{
		my @months = ('0','31','28','31','30','31','30','31','31','30','31','30','31');
		my $self = shift;
		my $param = shift;
		
		if ($param > 0)
		{
			while ($param)
			{
				my $temp = $months[$self->{month}] - $self->{day};
				if (($self->{month} == 2) & (($self->{year} % 4) == 0))	
				{
					$temp++;
				}			
			
				if ($param > $temp)
				{
					$self->{day} = 1;
					$self->add_months(1);
					$param -= $temp + 1;
				}
				else
				{
					$self->{day} += $param;
					$param -= $param;
				}
			}	
		}
		elsif ($param < 0)
		{
			while ($param)
			{
				if ((-$param) >= ($self->day()))
				{
					$param += $self->{day};
					$self->add_months(-1);				
					my $day = $months[$self->{month}];
					$self->day($day);
					$self->{day} += 1 if (($self->{month} == 2) & (($self->{year} % 4) == 0));	
				} 
				else
				{
					$self->{day} += $param;
					$param = 0;
				}
			}
		}		
		return $self;
	}
	
1;
}

my $filepath = $ARGV[0];
my $code = do {
	local $/;
	open (my $hand, "<", $filepath) or die "Can not open file $ARGV[0]\n";
	<$hand>;
};

my $result = eval $code;
if (not defined $result)
{
	print STDOUT "ERROR!$@\n";
	exit 1;
}

exit 0;