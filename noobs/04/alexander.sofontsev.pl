#!/usr/bin/perl -w
use strict;
use warnings;
my $data_input = $ARGV[0];
open (FH,'<',$data_input) or die "Can not open test file: $!";
#variables
my $file_str;
my @str_arr;
my @symb_arr;
my @sort_arr;
my @sort_arr2;
my $data_counter = 0;
my $symb_counter = 0;
my %hash = ();
my $work_str;
my $work_str_length;
my @work_str_arr;
#array of the data
my $str_count = 0;
while (<FH>) {	
	$file_str = $_;		
	#@str_arr = split('\W',$file_str);
	@str_arr = split('=>|=|"|\'|\n|\r|\t|\s',$file_str);
	@symb_arr = split('\w|\n|\r|\t|\s',$file_str);
	push @sort_arr, @str_arr;
	push @sort_arr2, @symb_arr;	
	$str_count = $str_count + 1;	
}
#check file to empty
if($str_count != 0) {
	#del empty garbage elements of data's mass
	my $k = 0;
	while(defined $sort_arr[$k]) {		
		if(length $sort_arr[$k] == 0) {
			splice(@sort_arr, $k, 1);
		} elsif(substr($sort_arr[$k], 0, 1) eq "#") {
			splice(@sort_arr, $k, 1);
		} else {		
			$k = $k + 1;
		}	
	}
	#del empty and garbage elements of symbol's mass
	my $m = 0;
	while(defined $sort_arr2[$m]) {		
		if(length $sort_arr2[$m] == 0) {
			splice(@sort_arr2, $m, 1);				
		} elsif($sort_arr2[$m] eq "\"") {
			splice(@sort_arr2, $m, 1);
		} elsif($sort_arr2[$m] eq "\'") {
			splice(@sort_arr2, $m, 1);
		} elsif($sort_arr2[$m] eq "#") {
			splice(@sort_arr2, $m, 1);
		} else {		
			$m = $m + 1;
		}	
	}
	foreach (0..$#sort_arr) {		
		$data_counter = $data_counter + 1;
	}
	foreach (0..$#sort_arr2) {	
		$symb_counter = $symb_counter + 1;
	}
	#check error (fatal wrong in input data)
	if($data_counter == $symb_counter * 2 + 1) {
		#make a hash
		for (my $i = 1; $i < $#sort_arr; $i = $i + 1) {
			$hash{$sort_arr[$i]} = $sort_arr[$i + 1];
			$i = $i + 1;	
		}
		my $key;
		my $value;				
		$work_str = $sort_arr[0];		
		$work_str_length = length $work_str;		
		#foreach $key(sort {$hash{$b} cmp $hash{$a}} keys %hash){
		foreach $key(sort {$b cmp $a} keys %hash){
			#print "$key => $hash{$key}\n";
			#parse work string
			my $pattern = $hash{$key};
			$pattern = join(':', split(//, $pattern));			
			#print STDOUT "$pattern\n";			
			my $key_length = length $key;			
			if($key_length == 1) {										
				my $pattern_work_str = join(';', split(//, $work_str));
				@work_str_arr = split(/;/, $pattern_work_str);				
				#foreach (0..$#work_str_arr) {
				#	print STDOUT "$work_str_arr[$_],";
				#}				
				for(my $z = 0; $z < scalar @work_str_arr; $z = $z + 1) {					
					if ( ($z > 0) && ($z <= scalar(@work_str_arr) - 2) ) {
						if ( ( ($work_str_arr[$z - 1] ne ":") && ($work_str_arr[$z + 1] ne ")") ) && ( ($work_str_arr[$z - 1] ne "(") && ($work_str_arr[$z + 1] ne ":") ) && ( ($work_str_arr[$z - 1] ne ":") && ($work_str_arr[$z + 1] ne ":") ) && ( ($work_str_arr[$z - 1] ne "(") && ($work_str_arr[$z + 1] ne ")") ) ) {
							$work_str_arr[$z] =~ s/$key/($pattern)/g;							
						}
					} elsif($z == 0) {					
						if ($work_str_arr[$z] ne "(") {
							$work_str_arr[$z] =~ s/$key/($pattern)/g;							
						}
					} else {
						if ($work_str_arr[$z] ne ")") {
							$work_str_arr[$z] =~ s/$key/($pattern)/g;							
						}
					}
				}				
				$work_str = join('', @work_str_arr);				
			} else {
				$work_str =~ s/$key/($pattern)/g;			
				#print STDOUT "$work_str\n";
			}				
		}		
		#print STDOUT "$work_str\n";
		#clear answer from garbage;
		my $cleaner = "";		
		$cleaner = join("", split('\W', $work_str));
		print STDOUT "$cleaner\n";		
	} else {
		print STDOUT "0\n";
		print STDERR "wrong in input data\n";
	}
} else {
	print STDOUT "0\n";
	print STDERR "file empty\n";
}
close (FH);