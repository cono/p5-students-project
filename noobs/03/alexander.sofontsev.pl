#!/usr/bin/perl -w
use strict;
use warnings;
my $data_input = $ARGV[0];
open (FH,'<',$data_input) or die "Can not open test file: $!";
#variables
my $file_str;
my @str_arr;
my @sort_arr;
my @check_arr;
my @symb_arr;
my @sort_arr2;
my %hash = ();
#array of the data
my $str_count = 0;
while (<FH>) {	
	$file_str = $_;		
	@str_arr = split('\W',$file_str);
	@symb_arr = split('\w|\n|\r|\t|\s',$file_str);
	push @sort_arr, @str_arr;
	push @sort_arr2, @symb_arr;
	$str_count = $str_count + 1;	
}
my $ccc = 0;
foreach (0..$#sort_arr2) {
	if ( ($sort_arr2[$_] eq '=>') || ($sort_arr2[$_] eq ' =>') || ($sort_arr2[$_] eq '=> ') || ($sort_arr2[$_] eq ' => ') ) {
		#print STDOUT "$sort_arr2[$_], ";
		$ccc = $ccc + 1;
	}
}
my $num_data_elem = $ccc * 2 + 1;
#check file to empty
if($str_count != 0) {
	#del empty elements of mass
	my $k = 0;
	while(defined $sort_arr[$k]) {		
		if (length $sort_arr[$k] == 0) {
			splice(@sort_arr, $k, 1);				
		} else {		
			$k = $k + 1;
		}	
	}
	#check error (fatal wrong in data)
	if(scalar(@sort_arr) == $num_data_elem) {		
		#make hash
		for (my $i = 1; $i < $#sort_arr; $i = $i + 1) {
			$hash{$sort_arr[$i]} = $sort_arr[$i + 1];
			$i = $i + 1;	
		}
		#way
		my @keys = keys %hash;
		my $size = @keys;
		my $count = 0;
		my $point = $sort_arr[0];	
		#check error (no such key)
		my $index = 0;		
		foreach (0..$#sort_arr) {
			if ( ($point eq $sort_arr[$_]) && ($_%2 != 0) ) {
				$index = $index + 1;	
			}
		}		
		if($index != 0){
			push @check_arr, $point;
			print STDOUT "$point-";
			LINE:
			for (my $z = 0; $z < $size; $z = $z + 1) {				
				if( exists $hash{$point}) {					
					print STDOUT "$hash{$point}";						
					$point = $hash{$point};
					push @check_arr, $point; 
					my $yy = 0;	
					while(defined $check_arr[$yy]) {		
						if($check_arr[$yy] eq $point) {			
							my $zz = 0;
							while(defined $check_arr[$zz]) {
								if($check_arr[$zz] eq $point) {
									$count = $count + 1;					
									if($count > 1) {
										print STDOUT "\n";						
										print STDOUT "looped\n";
										last LINE;
									}
								}
								$zz = $zz + 1;
							}
							$count = 0;						
						}
						$yy = $yy + 1;
					}
				}
				if( exists $hash{$point}) {
					if($hash{$point} ne "") {
						print STDOUT "-";
					}
				}
			}
		} else {
			print STDOUT "error";
			print STDERR "no such key";
		}		
	} else {
		print STDOUT "error";
		print STDERR "fatal wrong in data";
	}
} else {
	print STDOUT "error";
	print STDERR "file empty";
}
close (FH);