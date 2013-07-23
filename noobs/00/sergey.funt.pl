#!/usr/bin/perl -w
#task_00
use strict;
use Scalar::Util qw(looks_like_number);
# online calculator:
# http://numsys.ru/


my $test_file_path = $ARGV[0];
open( FH, "<", $test_file_path) or die "Can not open test file: $!";

while ( <FH> ) {
	my $res=0;
	my @a=split (/,/, $_);
	if ($a[0] ne "\r\n")
	{
		if (defined($a[1]) && defined($a[2]))
		{
		if ($a[0] eq '' || $a[1] eq '' || $a[2] eq '' || $a[0] eq "\r\n" || $a[1] eq "\r\n" || $a[2] eq "\r\n")
		{
			$res='Error';
			print STDERR "Not enougth parameters\n";
		}
		else
		{
			if (looks_like_number($a[0]) && looks_like_number($a[1]) && looks_like_number($a[2]))
			{
				
			$a[0]=int($a[0]);
			$a[1]=int($a[1]);
			$a[2]=int($a[2]);
			
			
				my $diskr=$a[1]*$a[1]-4*$a[0]*$a[2];
				if ($a[0] eq 0 &&  $a[1] eq 0)
				{
					if ($a[2] eq 0)
					{
						$res='All real number';
					}
					else
					{
						$res='Error';
						print STDERR "It's not identity\n";
					}
				}
				elsif ($diskr eq 0)
				{
					$res='1 ('.-$a[1]/(2*$a[0]).')';
				}
				elsif ($diskr gt 0)
				{
					$res=(-$a[1]+sqrt($diskr))/(2*$a[0]);
					my $testVal=$res;
					$res=(-$a[1]-sqrt($diskr))/(2*$a[0]);
					$res="2 (".$testVal.' '.$res.")";
				}
				else
				{
					$res="0";
				}
			}
			else
			{
				$res="Error";
				print STDERR "Parametr is not a digit\n";
			}
			
		}}
		else{
		$res="Error";
		print STDERR "Not enougth parameters\n";		
		}
	}
	else
	{
		$res="Error";
		print STDERR "Empty string\n";
	}
	print STDOUT "$res\n";
	
}
close ( FH );
