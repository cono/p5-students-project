#!/usr/bin/perl


use strict;
use warnings;

my $prov;
my @refarr=qw();
my @refarr1=qw();
my $kol;
my $S=0;
my @res=qw();
my @resarr=qw();
my $filename=$ARGV[0];
open( FH, "<", "$filename") or die "Can not open test file: $!";
while(<FH>){
my $str=$_;
chomp($str);
my $str1=$str;

$str1=~s/\d+//g;
$str1=~s/\s+//g;
if($str1 ne ""){
	print STDOUT "ERROR\n";
print STDERR "letters\n";
exit 1;
}

if($str eq "")
{last;
	}
my @array=split(/ /,$str);

my $scalar1=\@array;
push(@refarr,$scalar1);
$prov=scalar(@array);}

while(<FH>){
my $str=$_;
chomp($str);
my $str1=$str;

$str1=~s/\d+//g;
$str1=~s/\s+//g;
if($str1 ne ""){
	print STDOUT "ERROR\n";
print STDERR "letters\n";
exit 1;
}

if($str eq "")
{last;
	}
my @array=split(/ /,$str);

my $scalar1=\@array;

push(@refarr1,$scalar1);
$kol=scalar(@array);

}

close(FH);





if($prov!= scalar(@refarr1)){
print STDOUT "ERROR\n";	
print STDERR "stolb != stroke\n";
exit 1;}

 for(my $i=0;$i<scalar(@refarr);$i++){
 for(my $j=0;$j<$kol;$j++){
for(my $k=0;$k<$kol;$k++){
$S+=$refarr[$i]->[$k]*$refarr1[$k]->[$j];


} 
	push(@res,$S);
	$S=0;
	
 	}
 	print "@res\n";
 	@res=();
 	}
0;
