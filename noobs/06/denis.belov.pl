#!/usr/bin/perl -w

use strict;
use Scalar::Util 'looks_like_number';

eval{
	my $test_file_path = $ARGV[0];
	open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

	my $first_array = &read_matrix();
	my $second_array = &read_matrix();
	my $number_of_columns_first_matrix = @{@{$first_array}[0]};
	my $number_of_columns_last_matrix = @{@{$second_array}[0]};
	my $number_of_row_last_matrix = @{$second_array};

	&print_error_message_and_exit("Wrong input data") 
		if(!&check_matrix($first_array, $number_of_columns_first_matrix));
	&print_error_message_and_exit("Wrong input data") 
		if(!&check_matrix($second_array, $number_of_columns_last_matrix));
	&print_error_message_and_exit("Wrong input data") 
		if($number_of_columns_first_matrix != $number_of_row_last_matrix);
	&multiply_matrix($first_array, $second_array, $number_of_columns_first_matrix - 1, $number_of_columns_last_matrix - 1);

	close(FH);
};
if($@){
	print_error_message_and_exit($@);
}

sub print_error_message_and_exit {
	print STDOUT "ERROR\n";
	print STDERR $_[0] . "\n";
	exit 1;
}

sub read_matrix {
	my @buffer_array;
	while(my $line = <FH>){
		chomp $line;
		return \@buffer_array if($line eq "");
		push @buffer_array, [split(/\s/, $line)];
	}
	\@buffer_array;
}

sub check_matrix {
	my $fine;
	my $buffer_array = shift;
	my $number_of_columns = shift;
	for my $ref(@{$buffer_array}){
		$fine = grep{looks_like_number $_} @{$ref};
		return 0 if(($fine != $number_of_columns) || @{$ref} != $number_of_columns);
	}
	1;
}

sub multiply_matrix {
	my $first_matrix = shift;
	my $second_matrix = shift;
	my $length_first_matrix = shift;
	my $length_second_matrix = shift;
	for my $ref_on_first(@{$first_matrix}){
		my @buffer_array;
		for my $i(0..$length_second_matrix){
			my $sum = 0;
			for my $j(0..$length_first_matrix){
				$sum += $ref_on_first->[$j] * $second_matrix->[$j]->[$i];
			}
			push @buffer_array, $sum;
		}
		print STDOUT "@buffer_array\n";
	}
}
