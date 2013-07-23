#!/usr/bin/perl -w

use strict;

# online calculator:
# http://numsys.ru/


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) 
{

	# < обработка >
	my $flag=1;
	my $errdesc=undef;
	my $res=undef;
	my @arr=split(/,/,$_);
	my ($a,$b,$c)=@arr[0,1,2];
	my @test=undef;
	if ((defined $a) and (defined $b) and (defined $c))
	{
		@test[0,1,2]=($arr[0]/2,$arr[1]/2,$arr[2]/2);
		if ($arr[0]-1==0){$test[0]=1;}
		if ($arr[1]-1==0){$test[1]=1;}
		if ($arr[2]-1==0){$test[2]=1;}
		if (($test[0]==0) or ($test[1]==0) or ($test[2]==0)){$flag=0;}
	}
	else{$flag=0;}
	if ($flag==1)
	{
	my $d=($b**2)-4*$a*$c;
	if ($d>=0)
	{
		$d=sqrt($d);
		my $x1=(-$b+$d)/(2*$a);
		my $x2=(-$b-$d)/(2*$a);
		if ($x1!=$x2)
		{
			$res = "2 ($x1 $x2)";
		}
		else
		{
			$res =  "1 ($x1)";
		}
	}
	elsif ($d<0)
	{
		$res = 0;
	}
	else
	{
		$res = "Error";
		$errdesc = "Unknown Error";
	}
	}
	else
	{
		$res="Error";
		if ($flag==0){$errdesc="Input error: emty line, NaN, or smth";}
		else{$errdesc="Unknown Error";}
	}
	print STDOUT "$res\n";
	print STDERR "$errdesc\n" if ( $res eq 'Error' );
}
close ( FH );
