#!/usr/bin/perl -w
use strict;
use warnings;
package MySh;	
	#copy file
	sub copyfile {
		my $copyfrom = shift();
		my $copyto = shift();
		use File::Copy;
		copy($copyfrom, $copyto) or die "File cannot be copied.";
		print STDOUT "MySh::>copy $copyfrom $copyto\n";
	}
	#move
	sub movefile {
		my $old_name_move = shift();
		my $new_name_move = shift();
		rename $old_name_move, $new_name_move;
		print STDOUT "MySh::>move $old_name_move $new_name_move\n";
	}
	#delete file
	sub delete {
		my $delete = shift();
		unlink($delete);
		print STDOUT "MySh::>delete $delete\n";
	}
	#sort file
	sub sort {
		my $sort = shift();
		my $data_str_sort;
		my @main_arr_sort;
		my @str_arr_sort;
		open (SR,'<',$sort) or die "Can not open file: $!";
		while (<SR>) {			
			$data_str_sort = $_;
			@str_arr_sort = split('\n|\r|\t|\s',$data_str_sort);
			push @main_arr_sort, @str_arr_sort;
		}
		#del empty garbage elements of data's mass
		my $counter_sort = 0;
		while(defined $main_arr_sort[$counter_sort]) {		
			if(length $main_arr_sort[$counter_sort] == 0) {
				splice(@main_arr_sort, $counter_sort, 1);
			} else {		
				$counter_sort = $counter_sort + 1;
			}	
		}		
		@main_arr_sort = sort {$a cmp $b} @main_arr_sort;
		print STDOUT "MySh::>sort $sort\n";
		print STDOUT join("\n", @main_arr_sort);
		print STDOUT "\n";
		close (SR);		
	}
	#search elements of file
	sub search {
		my $element_search = shift();
		my $file_search = shift();
		my $data_str_search;
		my @main_arr_search;
		my @str_arr_search;
		open (SE,'<',$file_search) or die "Can not open file: $!";
		while (<SE>) {			
			$data_str_search = $_;
			@str_arr_search = split('\n|\r|\t|\s',$data_str_search);
			push @main_arr_search, @str_arr_search;
		}
		#del empty garbage elements of data's mass
		my $counter_search = 0;
		while(defined $main_arr_search[$counter_search]) {		
			if(length $main_arr_search[$counter_search] == 0) {
				splice(@main_arr_search, $counter_search, 1);
			} else {		
				$counter_search = $counter_search + 1;
			}	
		}
		print STDOUT "MySh::>search $element_search $file_search \n";
		for(my $counter_search = 0; $counter_search < scalar @main_arr_search; $counter_search = $counter_search + 1) {			
			if($main_arr_search[$counter_search] =~/$element_search/) {
				print STDOUT "$main_arr_search[$counter_search]\n";
			}
		}		
		close (SE);	
	}
	#print file
	sub print {		
		my $print = shift();
		my $data_str_print;
		open (PR,'<',$print) or die "Can not open file: $!";
		print STDOUT "MySh::>print $print\n";
		while (<PR>) {			
			$data_str_print = $_;
			print STDOUT "$data_str_print";
		}
		print STDOUT "\n";
		close (PR);		
	}		
1;
package main;
my $data_input = $ARGV[0];
open (FH,'<',$data_input) or die "Can not open test file: $!";
my $data_str_console;
my @data_str_console_array;
my @wrong_storage;
while (<FH>) {
	$data_str_console = $_;
	@data_str_console_array = split('\n|\r|\t|\s',$data_str_console);	
	my $counter_main = 0;
	while(defined $data_str_console_array[$counter_main]) {		
		if(length $data_str_console_array[$counter_main] == 0) {
			splice(@data_str_console_array, $counter_main, 1);
		} else {		
			$counter_main = $counter_main + 1;
		}	
	}	
	for (my $k = 0; $k < scalar(@data_str_console_array); $k = $k + 1) {
		#command string
		my $memory_results;
		my $checking  = join('', @data_str_console_array);
		my $count1 = index($checking, "copy");
		my $count2 = index($checking, "move");
		my $count3 = index($checking, "delete");
		my $count4 = index($checking, "sort");
		my $count5 = index($checking, "search");
		my $count6 = index($checking, "print");
		if(index($checking, "|") == -1) {		
			my $sum_count = $count1 + $count2 + $count3 + $count4 + $count5 + $count6;
			if( ($sum_count == $count1 - 5) || ($sum_count == $count2 - 5) || ($sum_count == $count3 - 5) || ($sum_count == $count4 - 5) || ($sum_count == $count5 - 5) || ($sum_count == $count6 - 5) ) {
				if($data_str_console_array[$k] eq "copy") {
					MySh::copyfile($data_str_console_array[$k+1],$data_str_console_array[$k+2]);
				}
				if($data_str_console_array[$k] eq "move") {
					MySh::movefile($data_str_console_array[$k+1],$data_str_console_array[$k+2]);
				}
				if($data_str_console_array[$k] eq "delete") {
					MySh::delete($data_str_console_array[$k+1]);
				}
				if($data_str_console_array[$k] eq "sort") {
					MySh::sort($data_str_console_array[$k+1]);
				}
				if($data_str_console_array[$k] eq "search") {
					MySh::search($data_str_console_array[$k+1], $data_str_console_array[$k+2]);
				}
				if($data_str_console_array[$k] eq "print") {
					MySh::print($data_str_console_array[$k+1]);
				}
			} else {
				print STDOUT "0\n";
				push @wrong_storage, "many command in one string - wrong in command syntax\n";
			}
		} else {
			if($data_str_console_array[0] ne "|") {
				if( (index($checking, "copy") == -1) && (index($checking, "move") == -1) && (index($checking, "delete") == -1) ) {								
					if($data_str_console_array[0] eq "print") {
						print STDOUT "0\n";				
					} else {
						print STDOUT "0\n";
						push @wrong_storage, "commands search and sort only after print - wrong in command syntax\n";
					}
				} else {
					print STDOUT "0\n";
					push @wrong_storage, "commands copy, move, delete don't work with | - wrong in command syntax\n";
				}
			} else {
				print STDOUT "0\n";
				push @wrong_storage, "| on string begin - wrong in command syntax\n";				
			}
		}
	}
}
print STDOUT "MySh::>exit\n";
my $res = "";
foreach (0..$#wrong_storage) {
	my $res = $res . $wrong_storage[$_] . "";
	print STDOUT "$wrong_storage[$_]\n";
}
close (FH);