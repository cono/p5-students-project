#!/usr/bin/perl 

use strict;
use warnings;

use Data::Dumper;

sub usage {
	print STDERR "Usage: $0 <matrix_file_1> <matrix_file_2>\n";
	return 1;
}

sub file_exists {
	my $file = shift;

	if(  -f $file ){
		return 1;
	}else{
		return 0;
	}
}

sub read_matrix {
	my $file = shift;

	open(my $fh, '<' , $file ) || (print STDERR "Can't open file $file\n" &&   &usage && exit(1));

	my $a = [];
	my $b = [];
	my $switch = "";

	while(<$fh>){
		chomp;

		if(!$_){
			$switch = "on";
			next;
		}

		my @a = split;

		if(! $switch){
			push @$a, \@a;
		}else{
			push @$b, \@a;
		}

	}

	return ($a, $b);
}

sub check_matrix_size {
	my $matrix = shift;

	my $row_num = scalar(@$matrix);
	if($row_num == 0 ){
		return (0,0);
	}
	
	my $col_num = scalar(@{$matrix->[0]});
	
	if($col_num == 0){
		return(0,0);
	}

	#print Dumper($matrix) . "\n";

	foreach my $row (@$matrix){
		if(scalar(@$row) != $col_num){
			print STDERR "Not a matrix\n";
			&usage;
			exit(1);
		}

		foreach my $value (@$row){
			if($value !~ /[0-9]/){
				print STDERR "matrix contains not-numer values\n";
				&usage;
				exit(1);
			}
		}
	}

	#print "$row_num x $col_num\n";
	return ($row_num, $col_num);
}

sub validate_matrices {
	my $matrix1 = shift;
	my $matrix2 = shift;

	my ($matrix1_row_count, $matrix1_col_count) = &check_matrix_size($matrix1);
	my ($matrix2_row_count, $matrix2_col_count) = &check_matrix_size($matrix2);

	#print "$matrix1_row_count x $matrix1_col_count\n";
	#print "$matrix2_row_count x $matrix2_col_count\n";

	if($matrix1_col_count == $matrix2_row_count){
		return ($matrix1_row_count, $matrix2_col_count, $matrix1_col_count);
	}else{
		print STDERR "unable to multiple these $matrix1_col_count != $matrix2_row_count\n";
		&usage;
		exit(1);
	}
}

sub multiple_matrices {
	my $matrix1 = shift;
	my $matrix2 = shift;
	
	my ($res_rows, $res_cols, $n) = &validate_matrices($matrix1, $matrix2);

	my $matrix_mul = [];


	for(my $i = 0;  $i < $res_rows; $i++){
		for(my $j = 0; $j < $res_cols; $j++ ){
			my $s = 0;

			my $s_s = "mul[$i,$j]=";
			
			for(my $k = 0; $k < $n; $k++){
				$s += $matrix1->[$i]->[$k] * $matrix2->[$k]->[$j];

				$s_s .= "a[$i,$k] * b[$k,$j] + ";
			}

			$s_s =~ s/ \+ $//;
			#print "$s_s\n";

			$matrix_mul->[$i]->[$j] = $s;
		}
	}
	return $matrix_mul;
}

my $fl1 = $ARGV[0];

unless($fl1 ){
	print STDERR "Missing file names\n";
	&usage();
	exit(1);
}

&usage && exit(1) unless &file_exists($fl1); 
my ($matrix1, $matrix2) = &read_matrix($fl1);
my $matrix_mul = &multiple_matrices($matrix1, $matrix2);

foreach my $row (@$matrix_mul){
	print join(' ', @$row) . "\n";
}
