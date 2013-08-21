#!/usr/bin/perl

my $test_file_path = $ARGV[0];

package Date;
sub new
{
	my $class;
	my $self;
	if (defined(@_[1]))
	{
		($class,$self)=@_;
		if (ref($self) eq "ARRAY")
		{
			$self={year=>$self->[0], month=>$self->[1], day=>$self->[2]};
		}
		if (ref($self) eq "HASH")
		{
			if (defined($self->{year}) and defined($self->{month}) and defined($self->{day}))
			{
				if ($self->{year}.$self->{month}.$self->{day}=~/\d/g)
				{
					if (($self->{month}>=1) and ($self->{month}<=12))
					{
						my $data=$self->{day};
						my $days;
						if ($self->{month}==6){$days=29;}
						elsif ($self->{month}%2!=0){$days=30}
						else{$days=31}
						if (($data<=$days) and($data>=1))
						{
							bless $self, $class;
						}
						else {return undef;}
					}
					else {return undef;}
				}
				else {return undef;}
			}
			else {return undef;}
		}
		else {return undef;}
	}
	else 
	{
		$class=shift;
		my @loc=localtime();
		my $da=@loc[3];
		my $mon=@loc[4]+1;
		my $ye=@loc[5]+1900;
		$self={"day"=>$da, "month"=>$mon, "year"=>$ye};
		bless $self, $class;
		return $self;
	}
}
sub get_struct
{
	my $self=shift;
	my $line=$self->{year}."/".$self->{month}."/".$self->{day};
	return $line;
}
sub year
{
	my $self=shift;
	if (@_[0]=~/\d/g or !defined(@_[0]))
	{
		if ((defined(@_[0])) and (!defined(@_[1])))
		{
			my $data=shift;
			$self->{year}=$data;
			return $self->{year};
		}
		elsif (!defined(@_[0]))
		{
			return $self->{year};
		}
		elsif (defined(@_[2])){return "ERROR";print STDERR "too much arguments\n";}
	}
	else{return "ERROR";print STDERR "NaN\n";}
	
}
sub month
{
	my $self=shift;
	if (@_[0]=~/\d/g or !defined(@_[0]))
	{
		if ((defined(@_[0])) and (!defined(@_[1])))
		{
			my $data=shift;
			if (($data<=12) and ($data>=1))
			{
				$self->{month}=$data;
				return $self->{month};
			}
			else{return "ERROR";print STDERR "Nuber is too big\n";}
		}
		elsif (!defined(@_[1]))
		{
			return $self->{month};
		}
		elsif (defined(@_[2])){return "ERROR";print STDERR "too much arguments\n";}
	}
	else{return "ERROR";print STDERR "NaN\n";}
	
}
sub day
{
	my $self=shift;
	if (@_[0]=~/\d/g or !defined(@_[0]))
	{
		if ((defined(@_[0])) and (!defined(@_[1])))
		{
			my $data=shift;
			my $days;
			if ($self->{month}==6){$days=29;}
			elsif ($self->{month}%2!=0){$days=30}
			else{$days=31}
			if (($data<=$days) and($data>=1))
			{
				$self->{day}=$data;
				return $self->{day};
			}
			else{return "ERROR";print STDERR "Nuber is too big\n";}
		}
		elsif (!defined(@_[0]))
		{
			return $self->{day};
		}
		elsif (defined(@_[1])){return "ERROR";print STDERR "too much arguments\n";}
	}
	else{return "ERROR";print STDERR "NaN\n";}
}
1;

package Calendar;
our @ISA=qw(Date);
sub new
{
	my $class=shift;
	my $self;
	if (!defined(@_[0])){$self=Date->new();}
	else {$self=Date->new(shift);}
	bless $self, $class;
	return $self;	
}
sub add_days
{
	my $self=shift;
	if (@_[0]=~/\d/g and defined(@_[0]))
	{
		my $add=shift;
		$tmp=$self->{day};
		$tmp+=$add;
		$res=$self->day($tmp);
		if ($res eq "ERROR"){print STDOUT "ERROR\n";print STDERR "can't add days\n";}
		return $self;
	}
}
sub add_months
{
	my $self=shift;
	if (@_[0]=~/\d/g and defined(@_[0]))
	{
		my $add=shift;
		$tmp=$self->{month};
		$tmp+=$add;
		$res=$self->month($tmp);
		if ($res eq "ERROR"){print STDOUT "ERROR\n"; print STDERR "can't add month\n";}
		return $self;
	}
}
sub add_years
{
	my $self=shift;
	if (@_[0]=~/\d/g and defined(@_[0]))
	{
		my $add=shift;
		$tmp=$self->{year};
		$tmp+=$add;
		$res=$self->year($tmp);
		if ($res eq "ERROR"){print STDOUT "ERROR\n";print STDERR "can't add years\n";}
		return $self;
	}
}

1;

package main;
open (FH, "<", "$test_file_path");
while (<FH>)
{
	$expr.=$_;
}
eval($expr);
if ($@){print STDOUT "ERROR\n"; print STDERR "$@\n";}