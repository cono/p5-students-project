#!/usr/bin/perl -w
use strict;

my $counter = 0;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
while ( defined(my $file_string = <FH>) ) {
	$file_string =~ s/\s*//g;
	$counter++;
	my($a, $b, $c) = split(/,/, $file_string);
	my $res = "";
	my $errType = undef;
	my $D = 0;
	
	my $myString = join("",my @tmpArray=(0..9,'+','-','.')); #hell
	
	if($file_string){
		my @arrayA = split(//, $a);
		my @arrayB = split(//, $b);
		my @arrayC = split(//, $c);
		
		#AAA
		if(!$a){$a = 1;}		
		else{
			for (my $i=0; $i<=(scalar(@arrayA)-1); $i++){
				my $tmp1 = $arrayA[$i];
				if(index($myString,$tmp1)>=0){
					if(($tmp1 eq '+' || $tmp1 eq '-') && $i!=0){
						$errType = "Coefficient A='$a' contains the expression."; #содержит выражение
						last;
					}					
				}
				else{
					$errType = "Coefficient A='$a' is not a number or decimal number!";
					last;
				};
			};			
		};
		#BBB
		if(!$b){$b = 1;}
		else{
			for (my $i=0; $i<=(scalar(@arrayB)-1); $i++){
				my $tmp1 = $arrayB[$i];
				if(index($myString,$tmp1)>=0){
					if(($tmp1 eq '+' || $tmp1 eq '-') && $i!=0){
						$errType = "Coefficient B='$b' contains the expression."; #содержит выражение
						last;
					}			
				}
				else{
					$errType = "Coefficient B='$b' is not a number or decimal number!";
					last;
				};
			};
		};
		#CCC
		if(!$c){$c = 0;}
		else{
			for (my $i=0; $i<=(scalar(@arrayC)-1); $i++){
				my $tmp1 = $arrayC[$i];
				if(index($myString,$tmp1)>=0){
					if(($tmp1 eq '+' || $tmp1 eq '-') && $i!=0){
						$errType = "Coefficient C='$c' contains the expression."; #содержит выражение
						last;
					}			
				}
				else{
					$errType = "Coefficient C='$c' is not a number or decimal number!";
					last;
				};
			};
		};
		if($errType){
			$res = "Error";
		}
		else{
			if(int($a)==0){
				$res = "Error";
				$errType = "It is not quadratic equation. Coefficient A='$a'";
			}
			else{
				$D = $b**2 - 4 * $a * $c;
				if ($D == 0) {
					my $x = (-$b)/(2*$a);
					$res = "1 ($x)";
				}
				elsif ($D > 0) {
					my $x1 = (-$b + sqrt($D))/(2*$a);
					my $x2 = (-$b - sqrt($D))/(2*$a);
					$res = "2 ($x1 $x2)";
				}
				elsif ($D < 0) {
					$res = "0";
				}
				else {
					$res = "Error";
					$errType = "Some error.";
				};
			};
		};
		
	}
	else{
		$res = "Error";
		$errType = "No data.";
	};
	
	print STDOUT "$res\n";
	print STDERR "ERROR: $test_file_path : string №: $counter : $errType \n\n" if ( index(lc($res),'error') >= 0 );	
}
close ( FH );
