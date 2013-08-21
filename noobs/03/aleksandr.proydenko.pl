#!/usr/bin/perl -w
use strict;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
chomp(my $as=<FH>);
chomp(my $s=<FH>);
if($as=~/^[^\w\s]*$/){print "error\n";exit 0}	
if($s=~/[^\w\s\,=>]|\,\s*$/){print "error\n";exit 0}	
my $ab=$as;
my @tmp=$s;
my $s1=$s;
my $key;
my $i;
my @array;
my $gg=0;
$s1=~s/\s+/ /g;
$tmp[0]=$s1;
if(!defined($s) || $tmp[0] eq " "){print "error\n";exit 0}
my @hg=split(//,$s);
my $num;
my $num1;
for($num=0;$num<scalar(@hg);$num++){
	if($hg[$num] eq ","){$num1++}
}
$s=~s/,/ /g;	
$s=~s/\s+/ /g;
$s=~s/\s*\=\>\s*/\=>/g;																																																					
my @arr2=split(/ /,$s);
if($arr2[0] eq ""){$i=1}
for($i=1;$i<scalar(@arr2);$i++){
		unless($arr2[$i]=~/=>/){print "error\n";exit 0}
 }
$s=~s/=>/ /g;
 if($s=~/[=>]/){print "error";exit 0} 
$i=0;
my @arr1=split(/ /,$s);
if($arr1[0] eq ""){$i=1}
if((scalar(@arr1)-(2+$i))/2 != $num1){print "error\n";exit 0}
my %hash=();
if($arr1[0] eq ""){$i=1}
my $l=$i;
while ($i<scalar(@arr1)+$l){
	$hash{$arr1[$i]} = $arr1[$i+1];
	$i+=2;	
}
my @keys1 = keys %hash;
 unless (grep {$as eq $_} @keys1) {print "error\n";exit(1)}
while(exists($hash{$ab})){ 
	
	if(defined $key && !defined $hash{$key} && !exists $hash{$key}){print "error\n";exit 0}    
        foreach $key(keys %hash){       	
        	if($key eq $ab){
        		print "$ab-";
        			push(@array,$ab);
        		$ab=$hash{$key};  
        		last;		    		        	
        }        	
}
for(my $j=0;$j<scalar(@array);$j++){
	if($ab eq $array[$j]){print "$ab\n";print"looped\n";exit 0}
}
}
print $ab, "\n";
