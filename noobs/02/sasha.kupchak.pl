#!/usr/bin/perl


use warnings;
@arr2=("!","@","#","%","^","&","*","(",")","_","-","+","=",",",".","<",">","/","?","[","]","{","}","|","\n","`","",);
# print "Enter string\n";
# my $str = <STDIN>;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

# while ( <FH> ) {

$str=<FH>;chomp ($str);
if($str eq ""){
 
print STDOUT "Error\n" ;
print STDERR "do not enter\n";
exit;}
if($str eq "\t"){
 
print STDOUT "Error\n" ;
print STDERR "enter tab\n";
exit;
}

 @str1=split(/ /,$str);
 @cop1=@str1;
 @mas=qw();
 for(my $i=0;$i<scalar(@str1);$i++){
@massluch=split(//,$str1[$i]);
push(@mas,@massluch);
}
for(my $i=0;$i<scalar(@mas);$i++){
for(my $j=0;$j<scalar(@arr2);$j++){
if($mas[$i] eq $arr2[$j]){
print STDOUT "Error\n"; 
print STDERR "undef symbol\n";
 exit;}
}}
$prov="";
# pop(@cop1);# если читать с файла то удаление не надо
 @cop=sort@cop1;
for(my $i=0;$i<scalar(@cop);$i++){
 $kol=0;for($f=0;$f<scalar(@cop);$f++){

 if($cop[$i] eq $cop[$f]){
 $kol++;}
 }
 if($cop[$i] ne $prov){
  $prov=$cop[$i];
$stars="*" x $kol;
print STDOUT "$cop[$i]\t";
 print STDOUT "$stars\n";
}}
close ( FH );
