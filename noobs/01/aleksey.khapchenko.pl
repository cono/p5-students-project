#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $i=0.0;
while ( <FH> ) {
	$_=~s/\s//g;# удаляем пробелы
	chomp;# режем перевод строки
	my $napr;
	my $num="";
	my $base;
	($napr, $num, $base)=split(/,/,$_);
	$i++;
	my @digits = ('0'..'9','A'..'Z');
	if (defined $napr){
		if ($napr==1) {
			if ($num =~ /^[+-]?\d+$/){
				if (($base>"1")&&($base<="36")){
					my $ret = "";
					do {
						$ret = $digits[$num % $base] . $ret;
						$num = int($num / $base);
					} while ($num);
					print STDOUT "$ret\n";
				}
			}
		
			else{
				print STDOUT "Error \n";
				print STDERR "Stroka '#'$i sodergit ne 10-chnoe znachenie \n";
			}
		}
		elsif ($napr==2){
			my $ret="";
			if (($base>"1")&&($base<="36")){
				my @arr=split(//, uc $num);
				my $len=length $num;
				$#digits=$base;
				my $digstr="";
					for ($i=0;$i<$base;$i++){
						$digstr= $digstr.$digits[$i]
					}
				my $j=0.0;
				for ($j=0;$j<=$len-1;$j++){
						my $tmp = index ("$digstr", "$arr[$j]");
						if ($tmp>=0 && $tmp<$base){
						$arr[$j]=$tmp;
						}
						
					}
				my $counter="0";
				my $ret="0";
				for ($counter=0;$counter<=($len-1);$counter++){
					if ($arr[$counter] =~ /^[+-]?\d+$/){ ######################################
						if ($arr[$counter]>"-$base" && $arr[$counter]<$base){
							$ret=$ret+($arr[$counter]*($base**($len-($counter+1))));
						}
						else {
							print STDOUT "Error\n";
							
						}
					}	
					else{
					print STDOUT "Error\n";
					print STDERR "Chislo $arr[$counter] ne vhodit v ety CC s osnovaniem $base\n"
					}
				}
				print STDOUT "$ret\n";	
			}
			
			
		}
		else { 
			print STDOUT "Error\n";
			print STDERR "Stroka '#'$i sodergit nevernoe napravlenie perevoda \n";
		}
   	}
	else {	print STDOUT "Error\n";
			print STDERR "Stroka '#'$i ne sodergit dannih \n";
	}
	}
	#print STDOUT "...\n";
	#print STDERR "...\n" if ( $res eq 'Error' );
close ( FH );
