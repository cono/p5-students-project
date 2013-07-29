#!/usr/bin/perl -w
use strict;


my $test_file_path = $ARGV[0];

open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) {
		my $file="";
		$file=$_;
		my @array;
		(@array)=split(/ /,$_);
		my @sorted=sort(@array);
		my @test;
		my $len=@sorted;
		my $count="0";
		my $tmp;
		my $str=0.0;
		my $i;
		for ($count=0;$count<$len;$count++){
			if ($sorted[$count] =~ /(^\w+$)/){
				for ($tmp=0;$tmp<length($file);$tmp++){
					if ($file=~s/$sorted[$count] /""/){
						$str++;
					}
				}
				if ($str==0) {
					$sorted[$count]="!!!!!";
					}
				$str="*" x $str;
				if ($sorted[$count] ne "!!!!!"){
					$sorted[$count]=$sorted[$count]." $str";
					print STDOUT "$sorted[$count]\n";
				
				}
			}
			else{
				print STDERR "$sorted[$count] not letters\n";
				}
			$str=0.0;
		}
		
	
	if($.==2) {
		print STDERR "WARNING: Mnogostrochnui file na vhode\n";
		last;
	}
	#print STDOUT "$digstr\n";
}
close( FH );