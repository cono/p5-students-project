#!/usr/bin/perl -w
use strict;


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my %hash;
my @hash;
my @hashkeys;
my $tmp;
my $test=0;
my $firstkey="";
while ( <FH> ) {
	my $str="";
	
	my $key;
	my $testkey;
	my @hashkey;
	my $len=0.0;
	my $count=0.0;
	my $counter=0;
	if ($.==1){
		chomp($_);
		$firstkey=$_;
		$firstkey=~s/\s//g;
		$firstkey=~ s/[\r|]+$//;
		if ($firstkey!~ /^\w+$/){
		print STDOUT "error";
		print STDERR "$firstkey not alphanumeric";
		last;
		}
	}
	
		
	if ($.==2){
		$str=$_;
		$str=~s/\s//g;
		$str=~s/=>/,/g;
		my @array;
		
		(@array)=split(/,/,$str);
		my $leng=@array;
		%hash=@array;
		for ($count=0;$count<$leng;$count++){
			unless ($array[$count] =~ /^\w+$/){
				print STDOUT "error\n";
				print STDERR "Element Hash ($array[$count]) ne yavlyaetsya chislenno-bukvennim\n";
				$test=1;
				next;
			}
		}
		foreach $key(keys %hash){
			$hashkey[$count]=$key;
			$count++
			
		
		}
		if ($test==0){
			$len=@array/2;
			if (exists $hash{$firstkey}){
			$hashkey[0]=$firstkey;
			
			
			print STDOUT $hashkey[0];
			for ($count=0;$count<$len;$count++){
				$hashkey[$count+1]=$hash{$hashkey[$count]};
				if($count < ($len)){
					print STDOUT "-";
					print STDOUT "$hash{$hashkey[$count]}";
				}
					
					if ($hash{$hashkey[$count]}eq $firstkey){
						print STDOUT "\nlooped";
						next;
					}
			}
			}
			else {
				print STDOUT "error\n";
				print STDERR "Hash key $firstkey not found";
				last;
			}
		}	
	}

			
	if ($.>=3){ 
		print STDERR "Warning: more then two string in file";
		last;
	}
}

close ( FH );
