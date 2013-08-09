#!/usr/bin/perl -w

use strict;

if(@ARGV==0){print STDERR "Missing file names\n"; print STDOUT "ERROR\n"; exit 1;}
if(@ARGV>1){print STDERR "Wrong script parameters\n"; print STDOUT "ERROR\n"; exit 1;}

my $test_file_path = $ARGV[0];

sub ReadMatrix {
	my $file_path = shift;
	open( FH, "<", "$file_path" ) or die "Can not open test file: $!\n" and print STDOUT "ERROR\n" and exit 1;
	my @lines       = ();
	my @matrix_list = ();
	while (<FH>) {
		my$test1 = $_;
		if ( !( $_ =~ /[^\s]/g ) ) {
			if ( @lines != 0 ) {
				push( @matrix_list, [ @{lines} ] );
			
			}
			@lines = ();	
			next;		
		}
		my$test =$_;
		if(!($_=~/\n/)){$_.="\n";}
		if ( !($_ =~m/^\s*((-?\d+(((\.|e))\d+)?)+\s)+\s*$/) ) {
			print STDERR "Incorrect file\n";
			print STDOUT "ERROR\n";
			exit 1;
		}
		my @current_line = split( /\s+/, $_ );
		if(scalar @lines>0){
		if ( @current_line != @{ $lines[0] } ) {
			print STDERR "Wrong lines lenght\n";
			print STDOUT "ERROR\n";
			exit 1;
		}
		}
		push( @lines, [@current_line] );
	}
	if ("@lines") {
		push( @matrix_list, [ @{lines} ] );
	}

	return @matrix_list;
}

my @myMatrixes = &ReadMatrix($test_file_path);

if ( @myMatrixes == 0 ) {
	print STDERR "Reading matrix is faild or file is empty\n";
	print STDOUT "ERROR\n";
	exit 1;
}
if ( @myMatrixes > 2 ) { print STDERR "More then 2 matrixes"; exit 1; }

#Multiplication
my $result               = 0;
my $row_count_matrix1    = scalar @{ $myMatrixes[0] };
my $row_count_matrix2    = scalar @{ $myMatrixes[1] };
my $column_count_matrix1 = scalar @{ $myMatrixes[0]->[0] };
my $column_count_matrix2 = scalar @{ $myMatrixes[1]->[0] };
my @newlines             = ();
my @newRows              = ();
if ( $column_count_matrix1 != $row_count_matrix2 ) {
	print STDERR "Columns and rows count doesn't match!\n";
	print STDOUT "ERROR\n";
	exit 1;
}

for ( my $i = 0 ; $i < $row_count_matrix1 ; $i++ ) {

	for ( my $j = 0 ; $j < $column_count_matrix2 ; $j++ ) {
		$result = 0;
		for ( my $row = 0 ; $row < $column_count_matrix1 ; $row++ ) {
			$result +=
			  $myMatrixes[0]->[$i]->[$row] * $myMatrixes[1]->[$row]->[$j];
		}
		print $result. " ";

	}
	print STDOUT "\n";
}

