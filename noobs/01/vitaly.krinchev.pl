#!/usr/bin/perl -w
use strict;

# online calculator:
# http://numsys.ru/

# http://192.168.1.3/script.pl%20test.dat%3Eresults.log%202%3Eerrors_descriptions.log

my $test_file_path = $ARGV[0];
my ($n,$pr,$rest,$result,$z,$flag,$number,$base)=undef;
my @array=();
my $res='';
my $x=0;
my $step=0;
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) {
	$_=~s/\s*//g;
	#$_=~s/\r//g;
	#$_=~s/\n//g;

	if ($_ ne '') 
	{ 
		($flag,$number,$base)=split(/,/,$_);
		$number=uc($number);
		$n=1;
		if (($flag==1) && (($base>1) && ($base<37)))
		{
			$z=$number; 
			$number=$z; $rest=0; $result='';
			do 
				{
					$rest = $number%$base;
					if ($rest<10) { $result=$rest.$result; } 
					else { $result=chr($rest+55).$result; }
					$number=($number-$rest)/$base;
				}
			while ($number>0);
			if ($z==0 && $result==0 ) {print STDERR "„исло $number не соответствует дес€тичной системе исчислени€  \n";}
			else {print STDOUT "$result\n"; }
		}
		elsif (($flag==2) && (($base>1) && ($base<37)))
		{
			$step=0;
			@array=split(//,$number);
			$x=@array-1;
			for (my $i=0;$i<=@array-1;$i++)
			{
				if ( $array[$i] lt '9' && $array[$i] ge '0')  {$z=$array[$i];} else {$z=ord($array[$i])-55;}
				if ($z>=$base) {print STDERR "„исло 0$number не соответствует системе исчислени€ с основанием $base \n"; $n=0;last;}
				$step=$step+$base**$x*$z;
				$x--;
			}
			if ($n==1) {print STDOUT "$step\n";}
			
		}
		else {print STDOUT "\n";} 
	}
	else {print STDERR "Ќет данных дл€ обработки \n";}
	
	
	print STDERR "...\n" if ( $res eq 'Error' );
}
close ( FH );
