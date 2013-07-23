#!/usr/bin/perl -w
use strict;


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $i=0.0;
my $res="asd";
while ( <FH> ) {
	$_=~s/\s//g;# удаляем пробелы
	chomp;# режем перевод строки
	my $A;
	my $B;
	my $C;
	($A, $B, $C)=split(/,/,$_);
	$i++;
	if (defined $A){

		if (($A=~/^[+-]?\d+$/) && ($B =~ /^[+-]?\d+$/) && ($C =~ /^[+-]?\d+$/)){
			my $D=($B**2)-(4*$A*$C);
			# D это дискриминант
			if ($D < 0){
			#Корни не существуют 
				print STDOUT "0\n";
			}
				#Два корня
			elsif ($D > 0) {
				my $X1 = ((-1*$B) + (sqrt($D))) / (2*$A);
				my $X2 = ((-1*$B) - (sqrt($D))) / (2*$A);
				print STDOUT  "2 (", $X1;
				print STDOUT " ", $X2, ")\n";
			}
					#один корень
			else {
				my $X1 = ((-1*$B) + (sqrt($D))) / (2*$A);
				print STDOUT "1 (", $X1, ")\n";
			}
		}
			else{
				$res="Error";
				print STDOUT "Error\n";
			}
				print STDERR "Stroka '#'$i sodergit nevernie dannie \n" if ( $res eq 'Error' );
				$res="";
	}
	else {	print STDOUT "Error\n";
			print STDERR "Stroka '#'$i ne sodergit dannih \n";
	}
}
close ( FH );
