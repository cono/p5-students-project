#!/usr/bin/perl -w
use strict;

# online calculator:
# http://numsys.ru/


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) {

(my $a,my $b,my $c)=split(/,/,$_,3);

if(!defined($a)||!defined($b) || !defined($c) || ($c < 2 || $c>36) || $b<0){print "Error"}else{
	my $l;
	my @arr;
	my $o=0;
	my $out="";
	my $v1=0;
	for($l=0;$l<10;$l++){           
			$arr[$l]=$o;
			$o++;
		}
		$o="A";
		for($l=10;$l<36;$l++){      
			$arr[$l]=$o;
			$o++;
		}
	if($a==1){
if($b=~/[A-Za-z]/){print"Error"}else{
		do{	
			$l=int($b%$c);	
			$v1=$arr[$l];				
		$out=$v1 . $out;
		$b/=$c;
		}	
		while(int($b/$c)!=0);	
		my $f=int($b);
		if($f>0){
		print "${arr[${f}]}$out";
		} else{ print "$out";	}
	
}
}
 elsif($a==2){
 	my @temp=split(//,$b);
	my $num;
 	for(my $j=0;$j<length($b);$j++){
 		for($l=0;$l<36;$l++)
{
	if($arr[$l] eq $temp[$j]){
		$num=$l;
		$temp[$j]=$l;
		last;
	}
}
 	if($c<=$num){
 		print"Error";
 		exit 0;
 	}
 	}
for(my $h=length($b)-1;$h>=0;$h--){	
	$out+=$temp[$v1]*($c**$h);
	$v1++;
	
}
print "$out";
 } else{print "Error"}
}	
	print STDOUT "\n";
	print STDERR "\n" if ( my $res eq 'Error' );
}
close ( FH );

