#! /usr/bin/perl

use warnings;
use strict;

my $np = qr/^-?\d+(?:\.\d+)?(?:[e|E]-?\d+)?$/;

my $file = $ARGV[0];

my $data = &read_file(\$file);

my @arr = split(/\n\n/,$$data);

if (scalar(@arr) != 2){

	print STDOUT "ERROR\n";
	exit 1;
}

my ($mtrx1, $mtrx2) = @arr;

if (not $mtrx1 = &parse_matrix($mtrx1) or not $mtrx2 = &parse_matrix($mtrx2)){

	print STDOUT "ERROR\n";
	exit 1;
}

if (not &check_matrix($mtrx1) or not &check_matrix($mtrx2)){

	print STDOUT "ERROR\n";
	exit 1;
}

$mtrx1 = &turn_matrix_into_hash($mtrx1);
$mtrx2 = &turn_matrix_into_hash($mtrx2);

my $res = [];
if (not $res = &matrix_multiplication($mtrx1, $mtrx2)){
	
	print STDOUT "ERROR\n";
	exit 1;
}

&print_result($res);

sub trim{
	my $str = shift;
	$str =~ s/^\s+|\s+$//g;
	return $str;
}
sub read_file{

	my $filename = shift;
	
	my $data = "";
	
	open my $fh, "<", $$filename or die "Cannot open file $$filename: $!\n";
	$data .= $_ while (<$fh>);
	close $fh;
	
	return \$data;
}
sub parse_matrix{
	
	my $target = shift;
	return 0 if not defined $target or $target eq "";
	
	my $matrix = [];
	my $t = 0;
	
	my @lines = split(/\n/, $target);

	foreach my $line (@lines){
		
		return 0 if not defined $line or $line eq "";
		my $tmp = [];
		my @line = split(/\s+/,$line);

		foreach my $number (@line){
			
			$number = &trim($number);
			
			if ($number =~ $np){
				
				push (@$tmp, $number * 1);
			} else {
			
				return 0;
			}
		}
		push (@$matrix, $tmp);
	}

	return $matrix;
}
sub check_matrix{
	
	my $matrix = shift;
	my $sz = scalar(@{$matrix}) - 1;
	
	for my $i (1..$sz){
		
		if (scalar(@{$matrix->[$i - 1]}) != scalar(@{$matrix->[$i]})){
			
			return 0;
		}
	}
	
	return 1;
}
sub turn_matrix_into_hash{
	
	my $mtrx = shift;
	
	my $res = {
		x => scalar(@{$mtrx->[0]}),
		y => scalar(@$mtrx),
		matrix => $mtrx,
	};
}
sub matrix_multiplication{

	my ($m1, $m2) = @_;
	
	if ($m1->{'x'} == $m2->{'y'}){
	
		my $result = [];
		
		for my $y (0..($m1->{'y'} - 1)){
		
			for my $x (0..($m2->{'x'} - 1)){	 					

				for my $i (0..($m1->{'x'} - 1)){
					
					$result->[$y][$x] += $m1->{'matrix'}->[$y][$i] * $m2->{'matrix'}->[$i][$x];
				}	
			}
		}
		
		return $result;
		
	} else {
	
		return 0;
	}
}
sub print_result{
	
	my $res = shift;
	
	foreach my $y (@$res){
			
		print STDOUT "@$y\n";
	}
}
#----------------------------------------------------------------------------------------------