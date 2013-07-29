#!/usr/bin/perl -w
use strict;
use warnings;
my $data_input = $ARGV[0];
open (FH,'<',$data_input) or die "Can not open test file: $!";
#variables
my $file_str;
my @str_arr;
my @sort_arr;
my @all_data_arr;
my $counter = "";
#array of the data
my $str_count = 0;
while (<FH>) {
	$file_str = $_;	
	@str_arr = split('\W',$file_str);
	push @all_data_arr, @str_arr;
	push @sort_arr, @str_arr;
	$str_count = $str_count + 1;	
}
#check file to empty
if($str_count != 0) {
	#del repeat elements of mass
	my $i = 0;
	while(defined $sort_arr[$i]) {
		my $j = $i + 1;
		while(defined $sort_arr[$j]) {
			if ($sort_arr[$i] eq $sort_arr[$j]) {
				splice(@sort_arr, $j, 1); 
			} else {
				$j = $j + 1;
			}
		}
		$i = $i + 1;
	}
	#del empty elements of mass
	my $k = 0;
	while(defined $sort_arr[$k]) {		
		if (length $sort_arr[$k] == 0) {
			splice(@sort_arr, $k, 1);				
		} else {		
			$k = $k + 1;
		}
	}
	#sort mass
	@sort_arr = sort @sort_arr;
	#give the stars
	foreach (0..$#sort_arr) {
		my $check = $sort_arr[$_];
		foreach (0..$#all_data_arr) {
			if ($check eq $all_data_arr[$_]) {
				$counter = $counter . "*";	
			}
		}	
		print STDOUT "$sort_arr[$_] $counter\n";
		$counter = "";
	}
} else {
	print STDOUT "error";
	print STDERR "file empty";
}
close (FH);