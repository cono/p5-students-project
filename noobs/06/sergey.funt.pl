#!/usr/bin/perl -w
#task_06
use strict;
use Data::Dumper;
use File::Copy;


package MySh;

sub MultiplayVector
{
	my ($vectorA,$vectorB)=@_;
	my $length=@$vectorB;
	my $cou=0;
	my $result=0;
	
		while ($cou<$length)
		{	
			my $a1=pop(@$vectorA);
			my $b1=pop(@$vectorB);
		
			$_=$a1;
			my $f1=s/^[+-]?\d+\.?\d*$//;
			$_=$b1;
			my $f2=s/^[+-]?\d+\.?\d*$//;
			if ($f1 && $f2)
			{			
				$result+=$a1*$b1;
				$cou++;
			}
			else
			{
				print STDOUT "ERROR\n";
				print STDERR "Matrix have components not digit\n";
				exit 1;
			}
	}
	return $result;
}
1;


my $test_file_path = $ARGV[0];
open( FHI, "<", $test_file_path) or die "Can not open test file: $!";
my $countChek=0;
my $chekMatrix=0;
my @matrixA;
my @matrixB;
my $countColumA=0;
my $countColumB=0;
my $countRowA=0;
my $countRowB=0;
while (<FHI>)
{	
	if ($_ eq "\n")
	{
		if ($chekMatrix==1)
		{
			$countChek=1;
		}
		next;
	}
	else
	{
		s/\s{1,}/ /g;
		my $readString=$_;
		my @readRow=split(/ /, $readString);
		if ($countChek==0)
		{	
			$chekMatrix=1;
			if ($countColumA==0 || $countColumA==@readRow)
			{
				$countColumA=@readRow;
				push @matrixA,[@readRow];
				
				$countRowA++;
			}
			else
			{
				print STDOUT "ERROR\n";
				print STDERR "Incorrect size of matrix A\n";
				exit 1;
			}
		}
		else
		{
			if ($countColumB==0 || $countColumB==@readRow)
			{
				
				$countColumB=@readRow;
				push @matrixB,[@readRow];
				$countRowB++;
			}
			else
			{
				print STDOUT "ERROR\n";
				print STDERR "Incorrect size of matrix B\n";
				exit 1;
			}		
		}
	}
}
close (FHI);
if ($countRowB!=$countColumA)
{
	print STDOUT "ERROR\n";
	print STDERR "Incorrect size of matrix A or B\n";
	exit 1;
}
if ($countRowA==0)
{
	print STDOUT "ERROR\n";
	print STDERR "Missing matrix A\n";
	exit 1;
}
my @matrixC=([]);
#print Data::Dumper::Dumper(@matrixA);
for (my $i=0;$i<$countRowA;$i++)
{
	my @str=$matrixA[$i];
	my @vectorA=();
	for (my $j=0;$j<$countColumB;$j++)
	{		
		my @vectorB=();
		for (my $k=0;$k<$countRowA;$k++)
		{	
			push @vectorB, $matrixB[$k][$j];
			push @vectorA, $matrixA[$i][$k];
		}
		$matrixC[$i][$j]=MultiplayVector(\@vectorA,\@vectorB);		
	}
}
for (my $i=0;$i<$countRowA;$i++)
{
	for (my $j=0;$j<$countColumB;$j++)
	{			
		print $matrixC[$i][$j];
		if ($j!=$countColumB-1)
		{
			print " ";
		}
	}
	print "\n";
}