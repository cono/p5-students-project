#!/usr/bin/perl

#2
use warnings;

my $test_file_path = shift;

open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
while ( defined(my $file_string = <FH>) ) {
    my ($a, $b, $c) = split /\s*,\*/, $file_string;

if($a!=1&&$b!=2){
print "Error\n";
exit;
}
if($a eq "\n"||$b eq "\n"||$c eq "\n"){
 print "Error\n";
 exit;
 }
if($a eq ""||$b eq ""||$c eq "")
{
 print "Error\n";
 exit;
 }
 if($a == 0)
{
  print "Error\n";
  exit;
  }
 if($a eq ""||$b eq ""||$c eq ""){
 print "Error\n";
 exit;
 }



@arr1=qw();
@alf=(A..Z);
@cif=(0..9);
 if($a==1){
  my $q=$b;
  @str=split(//,$q);
  for(my $i=0;$i<scalar(@str-1);$i++){
  for(my $j=0;$j<scalar(@cif);$j++){
  if($str[$i]!=$cif[$j]){
   print "Error\n";
   exit;
   }
  }
  }
$x1=$b;
$x2=1;
  while($x1>=$c){
   $x2=$x1%$c;
    $x1=$x1/$c;
unshift(@arr1,$x2);
}
unshift(@arr1,int($x1));

for(my $i=0;$i<scalar(@arr1);$i++){
 for(my $j=0;$j<scalar(@alf);$j++){
if($arr1[$i]==$j+10){
$arr1[$i]=$alf[$j];
# splice($arr1,$i,$alf[$j]);
 # print  ($alf[$j]);
}

}
 # print "$arr1[$i]";
}
print @arr1;
print "\n";
 }
else{

$s=0;
@ch_b=split(//,$b);
$size=scalar(@ch_b);
for($i=0;$i<$size-1;$i++){
 for($j=0;$j<scalar(@alf);$j++){
if($ch_b[$i] eq $alf[$j]){
$ch_b[$i]=$j+10;
}}
}#print @ch_b;

for(my $i=0;$i<$size;$i++){
if($ch_b[$i]>$c){
print "Error\n";
exit;
}
}

for(my $i=0;$i<$size-1;$i++){
$s+=$ch_b[$i]*($c**(($size-1)-($i+1)));}
print $s;
print "\n";
}
}
