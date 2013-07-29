#!/usr/bin/perl -w
#task_03
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "test2.txt") or die "Can not open test file: $!";

my $EnterPoint=<FH>;
my $string=<FH>;

if ($EnterPoint eq '\n' || $string eq '\n')
{
	print STDOUT "error\n";
	print STDERR " not enough arguments\n";
}	
else
{
	$_=$string;
	my $FalseCountq=s/[^\w\s=>,]//ig;
	if (!$FalseCountq)
	{
		
		$EnterPoint=~s/\r\n//ig;
		$_=$EnterPoint;
		my $FalseCountChar=s/\W//ig;
		if (!($FalseCountChar))
		{
			$string=~s/\s//g;
			$_=$string;
			my @B=split (',', $_);
			my %myHash;
			foreach (@B)
			{
				my @Mytemp=split('=>',$_);
				$myHash{$Mytemp[0]}=$Mytemp[1];			
			}		
			my $flag=1;
			my $flagLoop=1;
			my $EnterPointBuf=$EnterPoint;
			my $k;
			my $val;
			my $flagEnter=0;
			my $flagT;
			do
			{
				$flagT=1;
				while ( ( $k, $val) = each %myHash) 
				{				
					if ($k eq $EnterPointBuf)
					{
						if (!$flagEnter)
						{		
							print STDOUT "$EnterPointBuf";
							$flagEnter=1;
						}
						print STDOUT "-$val";
						$EnterPointBuf=$val;
						$flagT=0;
						if ($EnterPointBuf eq $EnterPoint)
						{
							print STDOUT "\n";
							$flagLoop=0;
							$flag=0;
							last;
						}
					}
				}
				if ($flagT)
				{
					if	($flagEnter)
					{
						print STDOUT "\n";
					}
					else 
					{
						print STDOUT "error\n";
						print STDERR "Absent enter point \n";
					}
					last;
				}
			}while ($flag || $flagLoop);
			if (!$flagLoop)
			{
				print STDOUT "looped\n";
			}
		}
		else
		{
			print STDOUT "error\n";
			print STDERR "Wrong type of argument #1\n";
		}
	}
	else
	{
		print STDOUT "error\n";
		print STDERR "Wrong type of argument #2\n";
	}
}

close ( FH );