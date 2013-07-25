#!/usr/bin/perl 

#1

use warnings;

my $test_file_path = shift;

open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
while ( defined(my $file_string = <FH>) ) {
    my ($a, $b, $c) = split /\s*,\*/, $file_string;



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

my $D=($b**2)-(4*$a*$c);
if($D<0){
print"0\n";
}
if($D==0){
my $x=-$b/(2.0*$a);
print"1 ($x)\n";
}
if($D>0){
my $x1=(-$b+sqrt $D)/(2.0*$a);
my $x2=(-$b-sqrt $D)/(2.0*$a);
print"2 ($x1 $x2)\n";}
}
