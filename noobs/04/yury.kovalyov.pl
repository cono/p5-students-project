#!/usr/bin/perl

use warnings;
use strict;

sub printe
{
	my $message = shift;
	print STDOUT "0\n";
	print STDERR $message;
}

my $handle = undef;

sub initialize
{
	( 0 == $#ARGV ) or die "Wrong number of arguments: pass test file name, please.";
	my $test_file_name = $ARGV[0];

	open ( $handle, "<", $test_file_name ) or die "Can not open test file: $!";
}

sub uninitialize
{
	if ( defined( $handle ) )
	{
		close ( $handle );
	}
}

sub load_data
{
	return <$handle>;
}

sub load_hash
{
	my $maxlength = shift;

	my %hash = ();

	while ( <$handle> )
	{
		# common case:
		if ( my $wellFormedToken = ( m/^\s*(|'|")(\w+)\g{-2}\s*=>?\s*(|'|")(\w+)\g{-2}\s*$/ ) )
		{
			# lets skip keys longer than input data:
			if ( my $skipTooLongReplacement = ( length( $2 ) > $maxlength ) )
			{
				next;
			}

			$hash{$2} = $4;
			next;
		}

		# processing comments as well
		if ( my $skipCommentsAndEmptyLines = ( /^#|^\s*$/ ) )
		{
			next;
		}
		
		# unexpeced line
		{
			my %errorDescription = ( "LINE" => $. );
			return ( undef, %errorDescription );
		}
	}
	
	return ( !undef, %hash );
}

initialize();

{
	my $data = load_data();

	if ( my $invalidData = !( defined ($data) ) )
	{
		printe "Invalid data: check test file is not empty, please.\n";
		last;
	}

#
#	# cut border spaces:
#	$data =~ s/^\s+|\s+$//g;
	chomp $data;
#
#	if ( my $invalidString = ( $data !~ m/^\w+$/ ) )
#	{
#		printe "Invalid input string: check first line of test file, please.\n";
#		last;
#	}
#

	my $strlength = length( $data );

	if ( my $emptyString = !( 0 < $strlength ) )
	{
		printe "Empty input string: check first line of test file, please.\n";
		last;
	}

	my ( $isData, %hash ) = load_hash( $strlength );

	if ( my $wrongHashFill = !defined ( $isData ) )
	{
		printe "Invalid data: check @{[%hash]} of test file, please.\n";
		last;
	}
	if ( my $nothingToDo_ResultIsReady = ( !%hash ) )
	{
		print "$data\n";
		last;
	}

	# sort hash keys in reverse order
	my @arr = sort { $b cmp $a } keys %hash;

	# construct mega-"(subst1|subst2|...|substN)"-regex (no need embracing brackets)
	my $fsm = join ( "|" , @arr );

	# let PerlRE-engine do all the job:
	$data =~ s/$fsm/$hash{$&}/go;

	print "$data\n";

}

uninitialize();

=begin comment

Seems like - more "Perl-idiomatic" aproach:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#!/usr/bin/perl

use warnings;
use strict;

sub printe
{
	my $message = shift;
	print STDOUT "0\n";
	print STDERR $message;
}

my $handle = undef;

sub initialize
{
	( 0 == $#ARGV ) or die "Wrong number of arguments: pass test file name, please.";
	my $test_file_name = $ARGV[0];

	open ( $handle, "<", $test_file_name ) or die "Can not open test file: $!";
}

sub uninitialize
{
	if ( defined( $handle ) )
	{
		close ( $handle );
	}
}

initialize();

{
	my $data = <$handle>;

	if ( my $invalidData = !( defined ($data) ) )
	{
		printe "Invalid data: check test file is not empty, please.\n";
		last;
	}

	chomp $data;

	my $strlength = length( $data );

	if ( my $emptyString = !( 0 < $strlength ) )
	{
		printe "Empty input string: check first line of test file, please.\n";
		last;
	}

	my %hash = 	map { $_->[0] => $_->[1] }

				grep{ defined ( $_->[0] ) }

				map {	if (	( $_ =~ /^\s*(|'|")(\w+)\g{-2}\s*=>?\s*(|'|")(\w+)\g{-2}\s*$/ )
							and	( length( $2 ) <= $strlength )
						)
						{ [$2,$4] }
						elsif ( $_ =~ /^#|^\s*$/ ) { [undef,undef] }
						else
						{	printe "Wrong hash format: check LINE $. of test file, please. ";
							close ( $handle ); 
							die;
						}
					}
	<$handle>;

	if ( my $emptyHash = ( !%hash ) )
	{
		print "$data\n";
		last;
	}

	# sort hash keys in reverse order
	my @arr = sort { $b cmp $a } keys %hash;

	# construct mega-"(subst1|subst2|...|substN)"-regex (no need embracing brackets)
	my $fsm = join ( "|" , @arr );

	# let PerlRE-engine do all the job:
	$data =~ s/$fsm/$hash{$&}/go;

	print "$data\n";

}

uninitialize();

=end comment
