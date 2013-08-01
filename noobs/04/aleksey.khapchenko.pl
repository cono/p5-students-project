#!/usr/bin/perl -w
use strict;
	my @array;
	my $count=0;
	my $hashcounter=0;
	my $string;
	my $err=0;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
while ( <FH> ) {
	

		if ($.==1){
		$string=$_;
		#print STDOUT $string;
	}
	else
	{
		if ($_ =~ /^#/ or $_=~ /^ +$/ or $_=~/^\s/){
			next;
		}
		elsif ($_=~s/\s{0,1}//g && $_=~s/>{0,1}//g && $_=~/^("(\w+)"="(\w+)"|(\w+)="(\w+)"|"(\w+)"=(\w+)|(\w+)=(\w+)|'(\w+)'='(\w+)'|(\w+)='(\w+)'|'(\w+)'=(\w+))$/)
		{
		 	$hashcounter++;
			if (defined($2) && defined($3)){
				$array[$count]=$2;
				$count++;
				$array[$count]=$3;
				$count++;
			}
			else{
				if (defined($4) && defined($5)){
						$array[$count]=$4;
						$count++;
						$array[$count]=$5;
						$count++;
				}
				else{
					if (defined($6) && defined($7)){
						$array[$count]=$6;
						$count++;
						$array[$count]=$7;
						$count++;
					}
					else{
						if (defined($8) &&  defined($9)){
							$array[$count]=$8;
							$count++;
							$array[$count]=$9;
							$count++;
						}
						else {
							if (defined ($10) && defined ($11)){
								$array[$count]=$10;
								$count++;
								$array[$count]=$11;
								$count++;
							}
							else {
								if (defined($12) && defined(13)){
									$array[$count]=$12;
									$count++;
									$array[$count]=$13;
									$count++;
								}
							}
						}
					}	
				}
			}
		}	
		else{
			$hashcounter=0;
			$err=1;
			last;
		}
	}
}
close (FH);

###################################                HASH           ###############################	
my 	%hash=@array;
my @hashkeys;
my $key;
my @sortedkeys;
$count=0;
foreach $key(keys %hash){
	$hashkeys[$count]=$key;
	$count++
}
@hashkeys=sort @hashkeys;
@sortedkeys= reverse(@hashkeys);
my $temp="#";
my $tempspace;
my @temparr;
my %temphash;
my $changedstring;
my $leng=@sortedkeys;
my $outstring;
for($count=0;$count<$leng;$count++){
	$tempspace=$temp."!";
	$string=~s/$sortedkeys[$count]/$tempspace/g;
	$temparr[$count]=$tempspace;
	$temphash{$temparr[$count]}=$hash{$sortedkeys[$count]};
	$temp=$temp.'#';
}
@temparr= reverse @temparr;
for ($count=0;$count<$leng;$count++){
	$string=~s/$temparr[$count]/$temphash{$temparr[$count]}/g;
	}
if ($hashcounter==0) {
		print STDOUT "0";
		if ($err==0) {
			print STDERR "Can/'t find hash in this file";
		}
		elsif($err==1){
			print STDERR "Input error: Out of range\n";
		}
}	
else{
	print STDOUT $string;
}