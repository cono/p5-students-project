#!/usr/bin/perl -w
use strict;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
chomp(my $s=<FH>);
my @tmp=$s;
my $s1=$s;
$s1=~s/\s+/ /g;
$tmp[0]=$s1;
if(!defined($s) || $tmp[0] eq " "){print "error\n";exit 0}
$s=~s/\s+/ /g;
my $i=0;
my $count=1;

my @arr1=split(/ /,$s);
 for ($i=0;$i<scalar(@arr1);$i++){
 	if($arr1[$i] =~ m/[^a-zA-Z_0-9]/){print "error\n";exit 0}	
}
my @arr= sort @arr1;

$i=0;
if($arr[0] eq ""){$i=1}
while($i!=scalar(@arr)){
 if
($arr[$i] eq $arr[$i+1]){
 $count++;
 $i++;
 } else{
 print "$arr[$i] ";
 print '*' x $count;
 print "\n";
 $count=1;
 $i++;
 }
}
print "\n";


