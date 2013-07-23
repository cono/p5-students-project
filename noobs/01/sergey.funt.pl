#!/usr/bin/perl -w
#task_01
use strict;
use Scalar::Util qw(looks_like_number);
#print "Content-type: text/plain\n\n";
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
			
			
			if (looks_like_number($a[0]) && ($a[1]!~ /[A-Za-z]/) && looks_like_number($a[2]))
			{
				
				$a[0]=int($a[0]);
				$a[1]=int($a[1]);
				$a[2]=int($a[2]);
				my @numbLet=('0'..'9','A'..'Z');				
				my @rount=undef;
				my $countDig=0;
				if ($a[0] eq 1)
				{
					if ($a[1] < $a[2])
					{
						$res=$numbLet[$a[1]];
					}
					else
					{						
						my $su=int($a[1]/$a[2]);
						while ($su > $a[2])
						{							
							$rount[$countDig++]=$numbLet[$a[1]%$a[2]];
							$a[1]=int($a[1]/$a[2]);
							$su=int($a[1]/$a[2]);
						}
						$rount[$countDig++]=$numbLet[$a[1]%$a[2]];
						$rount[$countDig++]=$numbLet[$su];
						$res=undef;
						for (my $i=$countDig-1;$i>=0;$i--)
						{												
							$res.=$rount[$i];							
						}
					}				
				}
				elsif($a[0] eq 2)
				{
					$res="Parameter 2 in process";					
				}
				else
				{
					$res='Error';
					print STDERR "Incorrect type of operations\n";
				}				
			}
			else
			{
				$res="Parameter 2 in process";
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
	#print "$res \n";
	print STDOUT "$res\n";
	#print STDERR "Empty string\n" if ( $res eq 'Error' );
}
close ( FH );
