#!/usr/bin/perl -w
use strict;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
chomp(my $string=<FH>);
if($string=~m/[^\w]/){print "0\n";exit 0}
if($string eq ""){print "0\n";exit 0}
my @array;
my $hstr;
my @s2;
my $key;
while ( <FH> ){
if(m/^(['"]?)\w+(\1)\s*?=>?\s*?(["']?)\w+(\3)$/)
{}{
if(/^\s*#/ || /^\s*$/)
{}
  else
  {
if(/#/){}else{
$_ =~ s/['">\s]//g;
$hstr.="$_ ";
}
}
}
}
my $j;
$hstr=~s/=/ /g;
@array=split(/ /,$hstr);
my $i=0;
my %hash=();
my $q;
while ($i<scalar(@array)){
$q.="*";
	$hash{$array[$i]} = $q;
	$i+=2;	
}
$i=0;
$q="";
my %hash2=();
while ($i<scalar(@array)){
$q.="*";
	$hash2{$q} = $array[$i+1];
	$i+=2;	
}
foreach $key(sort {$b cmp $a}  keys %hash){
	$string=~s/$key/?$hash{$key}?/g;
}
foreach $key(keys %hash2){
 $string=~s/\Q?$key?\E/$hash2{$key}/g;       
}
	 print "$string\n";
