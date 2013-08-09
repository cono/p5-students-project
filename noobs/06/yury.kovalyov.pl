#!/usr/bin/perl

########################################################
### shared functions, utils. ###########################
package Help;

use warnings;
use strict;
use Scalar::Util;

sub verify_numbers
{
	my $data_arr = $_[0];
	
	grep 
	{
		unless ( Scalar::Util::looks_like_number($_) )
		{
			die( "Incorrect number: '$_'." );
		}
	}
	@{ $data_arr };

	return;
}

1;

########################################################
package Matrix;
use warnings;
use strict;

sub new 
{
	my ( $class, @args ) = @_;
	my $self = [];
	return bless( $self, $class );
}

sub get_culumns_number
{
	my $self = $_[0];

	my $row_0_ref = $self->[0];

	my $columns_number = @{ $row_0_ref };

	return $columns_number;
}

sub get_rows_number
{
	my $self = $_[0];
	
	my $rows_number = @{ $self };
	
	return $rows_number;
}

sub verify
{
	my $self = $_[0];
	
	my $row_0_ref = $self->[0];
	if ( !defined( $row_0_ref ) )
	{
		die( "Uninitialized matrix - no first row (probably empty matrix)." );
	}

	# for sure only :
	my $rows_number = @{ $row_0_ref };
	if ( 0 == $rows_number )
	{
		die( "Uninitialized matrix - empty row." );
	}

	return 1;
}

sub print_to
{
	my $self = shift;
	my $output = shift;

	# "inner" data - array of arrays
	my @matrix = @{ $self };

	my $rows = @matrix;
	
	foreach ( 0 .. $rows-1 )
	{
		my $row_ref = $matrix[$_];
		print $output join( ' ', @{$row_ref} ) . "\n";
	}

	return;	
}

sub multiply
{
	my $self = shift;

	my $matrixA = shift;
	my $matrixB = shift;

	unless ( my $assert = ( $matrixA->get_culumns_number() == $matrixB->get_rows_number() ) )
	{
		die( "Can not multiply, as culumns number of first matrix mismatches rows number of the second one." );
	}
	
	# "inner" data - array of arrays
	my @A = @{$matrixA};
	my @B = @{$matrixB};

	my $rows = @A;
	my $cols = @{ $B[0] };
	my $n = @B - 1; # i.e. == B_rows_number == A_cols_number
	
	for ( my $y = 0 ; $y < $rows ; ++$y )
	{
		for ( my $x = 0 ; $x < $cols ; ++$x )
		{
			my $value = undef;

			foreach ( 0 .. $n )
			{
				$value += $A[$y][$_] * $B[$_][$x]
			}

			$$self[$y][$x] = $value;
		}
	}

	return $self;
}

1;

########################################################
package Matrix::Loader;
use warnings;
use strict;

sub verify_data
{
	my $data_arr = shift;
	my $count = scalar( @{$data_arr} );

	my $count_first = shift;
	if ( !defined( $$count_first ) )
	{
		$$count_first = $count;
	}

	if ( my $differentNumberOfElemnts = ( $$count_first != $count ) )
	{
		die( "Wrong number of elements. Check line $.." );
	}
	
	Help::verify_numbers( $data_arr );

}

sub fetch_impl
{
	my $file_ref = shift;
	my $matrix	 = shift;

	my $count_first = undef;
	
	while ( <$file_ref> )
	{
		chomp;

		if ( my $metEmptyLineDelimeter = ( /^\s*$/ ) )
		{
			last;
		}

		{
			my $data_array = [ split ];

			verify_data( $data_array, \$count_first );
		
			push @{$matrix}, $data_array;
		}

	}

	return;
}

sub fetch
{
	my $file_ref = shift;

	my $matrix = Matrix->new();
	fetch_impl( $file_ref, $matrix );
	$matrix->verify();
	
	return $matrix;
}

1;

########################################################
package main;
use warnings;
use strict;

sub printe
{
	my $message = shift;
	print STDOUT "ERROR\n";
	print STDERR $message;
	return;
}

#
# try/catch code is obtained from publuic domain
# http://www.perlmonks.org/?node_id=384038
#
sub try (&@) 
{
	my( $try, $catch ) = @_;
	eval { &$try };
	if ( $@ )
	{
	    local $_ = $@;
		&$catch;
	}
}

sub catch (&) 
{ 
	$_[0] 
}


( 0 == $#ARGV ) or die "Wrong number of arguments: pass test file name, please.";
my $test_file_name = $ARGV[0];

open ( my $test_file_handle, "<", $test_file_name ) or die "Can not open test file: $!";

my $matrixA = undef;
my $matrixB = undef;
my $matrixC = undef;

try 
{
	$matrixA = Matrix::Loader::fetch( *$test_file_handle );
	$matrixB = Matrix::Loader::fetch( *$test_file_handle );
}
catch
{
	chomp( $@, $! );
	printe "Loading error. $@ - $!";
	exit 2;
};

try 
{
	$matrixC = Matrix->new();
	$matrixC->multiply( $matrixA, $matrixB );
}
catch
{
	chomp( $@, $! );
	printe "Multipilcation error. $@ - $!";
	exit 3;
};

$matrixC->print_to( *STDOUT );
