#!/usr/bin/perl -w
use strict;
use Scalar::Util qw(looks_like_number);

my @matrix1 = ();
my @matrix2 = ();
my $key = 0;
my $arrLength = 0;
my $counter = 0;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
while ( defined(my $file_string = <FH>) ) {
	if($file_string =~ /^\s*?$/){$key += 1; $counter = 0; next}
	
	my @arr = split(/\s+?/, $file_string);
	foreach my $i (@arr){
		if(!looks_like_number($i)){print STDOUT "ERROR\n"; print STDERR "ERROR: [$test_file_path] : Matrix contain non number element [$i]. \n"; exit;}
	}
	if($key == 0){push @matrix1,[@arr]}
	elsif($key == 1){push @matrix2,[@arr]}
	
	if($counter){
		if( ($key =~ /0|1/) && ($arrLength != scalar @arr)){print STDOUT "ERROR\n"; print STDERR "ERROR: [$test_file_path] : Rows of matrix of different lengths. [$file_string].\n"; exit;}
	}
	
	$counter++;
	$arrLength = scalar @arr;
}
close ( FH );
if(!@matrix1 || !@matrix2){print STDOUT "ERROR\n"; print STDERR "ERROR: [$test_file_path] : Missing data in file.\n"; exit;}

my $temp1 = $matrix1[0];
my $temp2 = $matrix2[0];
my $rows1 = (scalar(@matrix1)-1);
my $rows2 = (scalar(@matrix2)-1);
my $cols1 = (scalar(@$temp1)-1);
my $cols2 = (scalar(@$temp2)-1);
if($cols1 == $rows2){
	for my $i ( 0..$rows1 ){
		my $string = '';
		for my $j ( 0..$cols2 ){
			my $some = 0;
			for my $k ( 0..$cols1 ){$some += $matrix1[$i][$k] * $matrix2[$k][$j]}
			$string .= "$some ";
		}
		$string =~ s/\s$//;
		print STDOUT "$string\n";
	}
}
else{print STDOUT "ERROR\n"; print STDERR "ERROR: [$test_file_path] : Cols matrix1 != Rows matrix2.\n"; exit;}
