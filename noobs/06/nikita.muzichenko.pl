#!/usr/bin/perl -w
use strict;
my $test_file_path = $ARGV[0];
my @arr;
my @arr1;
open( FH, "<", "$test_file_path" ) or die "Can not open test file: $!";
while (<FH>) {
$_ =~ s/[\r\n]+$//s;
$_=~s/\s*//; 
	if($_=~/^$/){@arr=@arr1;@arr1=();next};
	if($_ !~ /^[\d -.]+$/){print STDOUT "ERROR\n";print STDERR "not correct simbol\n";exit }
	else {@arr1=(@arr1,[split(/ +/,$_)])}
}
close(FH); 
sub matrix {
unless(defined$arr[0]|defined$arr[0]){print STDOUT "ERROR\n";print STDERR"Bad matrix not standart\n";exit};
if(@arr1 !=@{$arr[0]}){print STDOUT "ERROR\n";print STDERR"Bad matrix not standart";exit};
foreach(@arr){if(@{$arr[0]} !=@{$_}){print STDOUT "ERROR\n";print STDERR"Bad matrix not standart1\n";exit}};
foreach(@arr1){if(@{$arr1[0]} !=@{$_}){print STDOUT "ERROR\n";print STDERR"Bad matrix not standart1\n";exit}};
my $rez=[];
my @rez1;
my $i;
my $f;
my $s;
my $n;
my $lon=@{$arr1[0]};
my $lon1=@{$arr[0]};
for($s=0;$s < @arr;$s++){
for($f=0;$f < $lon ;$f++){
for($i=0;$i < $lon1;$i++){$rez->[$s][$f]=$rez->[$s][$f]+$arr[$s][$i]*$arr1[$i][$f];	
}}};return $rez}
print STDOUT "@$_", "\n" foreach ( @{&matrix(@arr,@arr1);} );


