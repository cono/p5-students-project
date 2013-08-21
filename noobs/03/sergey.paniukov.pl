#!/usr/bin/perl -w
use strict;


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $enter=<FH>;
chomp ($enter);
if ($enter eq ''){
       print STDOUT "error\n";
       die "No entry";
       }
if ($enter=~/\W/){
       print STDOUT "error\n";
       die "Invalid entry";
       }
my $str=<FH>;
if($str eq '\n'|| $str eq ''){
       print STDOUT "error\n";
       die "Empty data";
       }
my @str = split(/, /, $str);
chomp(@str);
my (%path, $val, $k, $v);
foreach my $item(@str){
       ($k,$v)= split(/=>/, $item);
       $path{$k} = $v;
       }
my @arr=%path;
foreach my $arr(@arr){
              if($arr=~/\W/){
              print STDOUT "error\n";
              die "Invalid data";
              }
       }
$k=$enter;
print $k;
while (exists $path{$k}){
	print '-', $path{$k};
	$k=$path{$k};
	if($k eq $enter){
	print "\n", 'looped', "\n";
	last;
	}
}
my $more=<FH>;
if(defined $more){
print STDOUT "File not empty after data";
warn "File not empty after data";
}
close ( FH );

