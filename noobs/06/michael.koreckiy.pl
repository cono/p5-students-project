#!/usr/bin/perl -w
use Data::Dumper;
use strict;

########################################
#MyMatrix 
########################################

{
	package MyMatrix;
	
	sub new
	{
		my $class = shift;
		my $self = shift;
		bless $self, $class;
	}
	
	sub element
	{
		my $self = shift;
		my $x = shift;
		my $y = shift;
		if (@_)
		{
			$self->[$y]->[$x] = shift;
		}
		return $self->[$y]->[$x];
	}
	
}

############################################
#          package main; 
############################################

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") || die "Can not open test file: $!";

my @matrix;

for (my $itr = 0; $itr < 2; $itr++)
{
	my @temp;
	my $x;
	while (<FH>)
	{	
		my $line = $.;
		my @row;
		chomp $_;
		$_ =~ s/^\s*//;
		if ($_ =~ /^(?:(?:[-+]?(?:\d*\.\d*|\d+)(?:[eE][-+]?\d+)?)\s*)+?\s*$/)
		{
			@row = split(/\s+/, $_);
			$x = scalar(@row) unless (defined $x);
			if (scalar(@row) == $x)
			{
				push (@temp, \@row);
			}
			else
			{
				print STDERR "Error! Wrong size of matrix.\n";
				print STDOUT "ERROR\n";
				exit 1;
			}
			
		}		
		elsif ($_ = /^\s*$/)
		{
			if (not defined $temp[0])
			{
				print STDOUT "ERROR\n";
				print STDERR "Empty line was founded.\n";
				exit 1;
			}
			last;
		}
	}	
	push (@matrix, \@temp);
}

$matrix[0] = MyMatrix->new($matrix[0]);
$matrix[1] = MyMatrix->new($matrix[1]);

if (scalar(@{$matrix[0]->[0]}) == scalar(@{$matrix[1]}))
{
	for (my $i = 0; $i < scalar(@{$matrix[0]}); $i++)
	{			
		for (my $j = 0; $j < scalar(@{$matrix[1]->[0]}); $j++)
		{
			unless ($j == 0)
			{
				print STDOUT " ";
			}
			my $sum = 0;
			for (my $c = 0; $c < scalar(@{$matrix[0]->[0]}); $c++)
			{
				$sum += $matrix[0]->element($c,$i) * $matrix[1]->element($j,$c);
			}
			print STDOUT "$sum";
		}
		print STDOUT "\n";
	}
}
else
{
	print STDERR "Error! Matrixes can not be multyplied.\n";
	print STDOUT "ERROR\n";
	exit 1;
}
exit 0;