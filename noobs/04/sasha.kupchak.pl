#!/usr/bin/perl


use warnings;
%hash=();
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
$str=<FH>;
while ( <FH> ) {

 $fh1=$_;
chomp($fh1);
  if($fh1=~/\#\w+/)
{
 $fh1="";
 }
 
chomp($str);
$str1=$str;
$str1=~s/\w+//g;
if($str1 ne ""){
print STDOUT "0\n";
print STDERR "Zapret na symvol $str1\n";
exit;
}
 $prob=$fh1;
$prob1=$prob;
$prob1=~s/>//g;
@arr1=split(/=/,$prob1);
  
 $prob=~s/>//g;
  @arr=split(/=/,$prob);
  
 for($i=0;$i<scalar(@arr);$i++){
   #
   $arr1[$i]=~s/"//g;
   $arr1[$i]=~s/'//g;
  $arr1[$i]=~s/\w+//g;
  $arr1[$i]=~s/\s+//g;
  if($arr1[$i] ne "")
  {print "0\n";
  print "Zapret na symvol v hash\n";
  exit;
  }
  
  
  # print $arr[$i];
  # print "\n";
  if($arr[$i]=~/\"\w+/||$arr[$i]=~/\w+\"/){
   
   if($arr[$i]=~/\"\s\w+/||$arr[$i]=~/\w+\s\"/)
   {
    print STDOUT "0\n";
   print STDERR "probel v znach\n";
   exit;
    }
   
  if($arr[$i]!~/\"\w+\"/){
   print STDOUT "0\n";
   print STDERR "ne parnyi kavychki\n";
   exit;
   }
  }
  
   if($arr[$i]=~/\'\w+/||$arr[$i]=~/\w+\'/){
    
    if($arr[$i]=~/\' \w+/||$arr[$i]=~/\w+ \'/)
   {
    print STDOUT "0\n";
   print STDERR "probel v znach\n";
    }
  if($arr[$i]!~/\'\w+\'/){
   print STDOUT "0\n";
   print STDERR "ne parnyi kavychki\n";
   exit;
   }
  }
  
  $arr[$i]=~s/"//g;
   $arr[$i]=~s/'//g;
 $arr[$i]=~s/\s+//g;
 
  
  }
  
  for($i=0;$i<scalar(@arr);$i++)
  {
   $hash{$arr[$i]}=$arr[$i+1];
   
   
    $str=~s/$arr[$i]/$hash{$arr[$i]}/g;
     $i++;
   }
  
}close ( FH );
print STDOUT "$str\n";