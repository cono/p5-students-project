#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

       
	my (@str, %count, $str, $x, $res);
       my $stream=<FH>;
       if ($stream eq ''||$stream eq "\n"){
              print STDOUT "error\n";
              die "No data";
              }
       chomp(@str=split(/ /, $stream));
	foreach $str(@str){
		if($str=~/\W\S/){
                     print STDOUT "error\n";
                     die "Invalid data";
                     }
		$count{$str}+=1;
	       }
	foreach $str(sort keys %count){
		$x='*' x $count{$str};
		print STDOUT "$str", " ", "$x\n";
	       }
my $more=<FH>;
if(defined $more){
print STDOUT "File not empty after data";
warn "File not empty after data";
}

close ( FH );