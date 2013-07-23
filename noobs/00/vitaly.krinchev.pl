#!/usr/bin/perl -w
use strict;

# online calculator:
# http://numsys.ru/

my $test_file_path = $ARGV[0];
my ($D,$x1,$x2,$x,$a,$b,$c)=undef;
my $res='';
my $string='';
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
while ( <FH> ) {
$_=~s/ //g;
$_=~s/\r//g;
$_=~s/\n//g;
	if ($_ ne '') 
	{
			($a,$b,$c)=split(/,/,$_,3);
			if (($a,$b,$c)!=0){ 
			$D=$b**2-4*$a*$c;
			if ($a==0) {$x=($c/$b)*(-1);print STDOUT '1('.$x.')'."\n";}
		else{
			if ($D>0) 
				{$x1=(((-1)*$b)-sqrt($D))/(2*$a);
				 $x2=(((-1)*$b)+sqrt($D))/(2*$a);
				 print STDOUT '2('.$x1.' '.$x2.')'."\n";}
			elsif ($D<0) {print STDOUT 'Дискриминант меньше нуля, решением будут являтся комплексные числа'."\n";}
			else {print STDOUT '1('.(-1)*($b/(2*$a)).')'."\n";}
				
			}
	}
	else {print STDOUT "Не достаточно данных для решения уровнения \n";}
	}
	else {print STDOUT "Введены не верные данные \n";}
	print STDERR "...\n" if ( $res eq 'Error' );
}
close ( FH );


 
 
 
 
 
