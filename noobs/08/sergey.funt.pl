#!/usr/bin/perl -w
#task_08
use strict;
use Data::Dumper;
use Time::localtime;

package Date;
my $year;
my $month;
my $day;
sub new {
	my $class = shift;
	my ($f)=@_;
    if (@_>0)
	{
		if  (ref $f eq 'HASH')
		{
			my $count = (keys $f);
			$year=$$f{year};
			$month=$$f{month};
			$day=$$f{day};

		}
		elsif (ref $f eq 'ARRAY')
		{	
			$year=@$f[0];
			$month=@$f[1];
			$day=@$f[2];			
		}		
	}
	else
	{
		$year=Time::localtime::localtime->year()+1900;
		$month=Time::localtime::localtime->mon();
		$day=Time::localtime::localtime->mday();
	}
	
	my $self = bless {} , $class;

    return $self;
}
sub day 
{
	if (@_==1)
	{
		return $day;
	}
	else
	{
		shift(@_);
		$day=shift;	
		return $day;
	}	
}
sub year
{
	if (@_==1)
	{
		return $year;
	}
	else
	{
		shift(@_);
		$year=shift;	
		return $year;
	}
}
sub month
{
	if (@_==1)
	{
		return $month;
	}
	else
	{
		shift(@_);
		$month=shift;	
		return $month;
	}
}	
sub get_struct
{	
	if (defined($year),defined($month),defined ($day))
	{
		print "$year/$month/$day\n";
	}
	else
	{
		print "Object not created\n";
	}
}

1;
package Calendar;
our @ISA = qw(Date);
sub add_months
{
	shift(@_);
	$month=shift;
}
sub add_years
{
	shift(@_);
	$year=shift;
}
sub add_days
{
	shift(@_);
	$day=shift;
}
sub get_struct
{
	if (defined($year),defined($month),defined ($day))
	{
		return "$year/$month/$day\n";
	}
	else
	{
		return "Object not created\n";
	}
}
1;
my %h=(year=>2012, month=>6);
my @a=(2012,  21,5);
my $myDate;	
my $myCalendar;
my $test_file_path = $ARGV[0];
open( FHI, "<", $test_file_path) or die "Can not open test file: $!";
while (<FHI>)
{
	my $et=$_;
	if (m/^print[ ]\"(.+)\\n\"\;/m)
	{	
		
		print $1."\n";
		
	}
	if ($et=~/Date->new/)
	{
		$_=$et;
		if (m/\{(.+)\}/ig)
		{
			my @er=split(/[=>\,\s]/,$1 );			
			my @r=();
			foreach (@er)
			{
				if ($_ ne '' && $_ ne 'undef')
				{
					push @r,$_;
				}
			}
			my %hesh=@r;
			$myDate=Date->new(\%hesh);			
		}
		if (m/\[(.+)\]/ig)
		{
		
			my @er=split(/[\,\s]/,$1 );		
			my @r=();
			my $i=0;
			foreach(@er)
			{
				 if ($_ ne 'undef' && $_ ne '')
				{
					$r[$i]=$_;
					$i++;
				}
				
			}
			$myDate=Date->new(\@r);			
		}
		$myDate=Date->new() if ($et=~/Date->new\(\)/);				
	}
	print $myDate->year."\n" 	if ($et=~/\-\>year[ ]?\. \"\\n\"\;/);	
	print $myDate->day."\n" if ($et=~/\-\>day[ ]?\. \"\\n\"\;/);
	print $myDate->month."\n" if ($et=~/\-\>month[ ]?\. \"\\n\"\;/);
	print $myDate->get_struct."\n" if ($et=~/get_struct[ ]?\. \"\\n\"\;/);
	print "\n" if ($et=~/^print[ ]\"\\n\"\;$/);
	
	$myDate->year($1)."\n" 	if ($et=~/\-\>year\((.+)\);/);	
	$myDate->day($1)."\n" if ($et=~/\-\>day\((.+)\);/);
	$myDate->month($1)."\n" if ($et=~/\-\>month\((.+)\);/);
	
}
close(FHI)
