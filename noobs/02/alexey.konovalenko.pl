#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path" ) or die "Can not open test file: $!";

$_ = <FH>;

if(!(defined($_)))
{
	print STDOUT "Error\n";
	die "Empty File Error!\n";
}

	my $marker = '*';

	if ( index($_, /[^\w\d\s]+/ ) ) 
	{
		print STDOUT "Error\n";
		die "Error in line\n";
	}
	else {

		my %hash = ();		
		my @temp_array = split( /\s+|\t+/, $_ );
		if ( scalar @temp_array == 0 ) {
			print STDOUT "Error\n";
			die "Error, sring is empty\n";
		}
		else
		{

			#hash init
			foreach my $keys (@temp_array) {
				if ( !( $keys eq '' ) ) {
					if ( exists( $hash{$keys} ) ) {
						$hash{$keys} .= $marker;
					}
					else {
						$hash{$keys} = $marker;
					}
				}
			}

			my @keys_array = sort ( keys %hash );
			foreach my $key (@keys_array) {
				{
					print STDOUT "$key $hash{$key}\n";
				}
			}
		}

	}



close(FH);
