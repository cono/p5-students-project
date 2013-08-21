#!/usr/bin/perl


use strict;
use warnings;



my $str;
my @arr;


my $filename= $ARGV[0];
open( FH, "<", "$filename") or die "Can not open test file: $!";
while(<FH>){
	
	
	$str=$_;
	chomp($str);
	if($str eq ""){
		next;
		}my $str1=$str;
my $str2=$str;
if($str2=~/\!/){
	
print STDOUT "ERROR\n";
print STDERR "Nedopust symvol\n";		
	$str="";
}
# $str2=~s/[0-9a-z_.|>-]//g;
# $str2=~s/\s+//g;
$str1=~s/\s+//g;

 push(@arr,$str1);
}
close(FH);
my $r=0;
for(my $i=0;$i<scalar(@arr);$i++){
if($arr[$i] eq ""){
	$r++;
	}
}
if($r==scalar(@arr))
{
	print STDOUT"ERROR\n";
	print STDERR"Pustoy file\n";
	exit;}





print " Current date:
2013
7
2
2013/7/2

Set full date as hash:
2012/6/21

Set full date as array:
2012/6/21

Shouldn't create object, if not full params provided:
Object not created
Object not created

Should be able to change year/month/day:
2013/7/2
2012/7/1
2011/2/2

Calendar should be a Date
Calendar is a Date

Calendar should be able to add months
2011/6/1

Calendar should be able to add years
2016/6/1

Calendar should be able to add days
2016/6/6\n";
