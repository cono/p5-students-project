#!/usr/bin/perl -w
use strict;

my $counter = 0;
my @myArray = (0..9);
push @myArray, ('A'..'Z');
my $myString = join('',@myArray);

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
while ( defined(my $file_string = <FH>) ) {
	$file_string =~ s/\s*//g;
	$counter++;
	my($a, $b, $c) = split(/,/, $file_string);
	my $res = "";
	my $errType = undef;
	my $tmpMyString = "";
		
	if($file_string){
		if(!$a){
			$res = "Error";
			$errType = "No translation Way.";
		}
		elsif($a == 1 || $a == 2){			
			if(!$b){
				$res = "Error";
				$errType = "No translation Number.";
			}
			else{				
				if(!$c){
					$res = "Error";
					$errType = "No scale of notation.";
				}
				else{
					if($c>=2 && $c<=36){
						#check B
						if($a==1){$tmpMyString = substr($myString,0,10)}
						else{$tmpMyString = substr($myString,0,$c)};
						my @arrayB = split(//, $b);
						for (my $i=0; $i<scalar(@arrayB); $i++){
							my $tmp1 = $arrayB[$i];
							if(index($tmpMyString,$tmp1,)>=0){
								if(($tmp1 eq '+' || $tmp1 eq '-') && $i!=0){
									$errType = "Coefficient B='$b' contains the expression."; #содержит выражение
									last;
								}			
							}
							elsif($tmp1 eq '.'){
								$errType = "SORRY. Translation of floating point numbers is not provided in this version of the program.";
								last;
							}
							else{
								if($a==1){$errType = "Coefficient B='$b' is not a decimal number!"}
								else{$errType = "Coefficient B='$b' is out of range for this scale of notation."}
								last;
							};
						};
						#END check B
					}
					else{
						$res = "Error";
						$errType = "Scale of notation is out of range.";
						print STDOUT "$res\n";
						print STDERR "ERROR: $test_file_path : string №: $counter : $errType \n\n" if ( index(lc($res),'error') >= 0 );	
						next;
					}
					
					my @arr;
					my $tmp = 0;
					#my $direction = '=>';
					my $tmpB = $b;
					if($a==1){
						if($errType){
							$res = "Error";
						}
						else{
							if($tmpB < $c){
								unshift(@arr,$myArray[$tmpB]);
							};
							while ($tmpB >= $c){
								my $e = $tmpB%$c;
								$tmpB = $tmpB/$c;
								unshift(@arr,$myArray[$e]);
								if(int($tmpB/$c) == 0){
									unshift(@arr,$myArray[$tmpB]);
								};
								#print "@arr\n";
							};
							$tmp = join('',@arr);
							$res =  $tmp;#"$b		$direction		$c		= $tmp		= @arr";
						}
					}
					else{
						if($errType){
							$res = "Error";
						}
						else{
							#$direction = '<=';
							@arr = split(//, $tmpB);
							@arr = reverse(@arr);
							for (my $i=0; $i<=(scalar(@arr)-1); $i++){
								$arr[$i] = index(join('',@myArray),$arr[$i]);
								$arr[$i] = $arr[$i]*($c**$i);
								$tmp += $arr[$i];
							};
							$res =  $tmp;#"$b		$direction		$c		= $tmp		= @arr";
						};
					};
					
				};
			};
		}
		else{
			$res = "Error";
			$errType = "Wrong translation Way. A='$a'";
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
