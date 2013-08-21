#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path" ) or die "Can not open test file: $!";

my $hash_path   = undef;
my $enter_point = undef;
my %hash;
my $is_looped = "";

$_ = <FH>;
#chomp($_);
if ( !( defined($_) ) ) {
	print STDOUT "Error\n";
	die "Data file Error!\n";
}
$enter_point = $_;
$_           = <FH>;
#chomp($_);
if ( !( defined($_) ) ) {
	print STDOUT "Error\n";
	die "Data file Error!\n";
}
$hash_path = $_;
if (   !defined($enter_point)
	|| !defined($hash_path)
	|| $enter_point eq ''
	|| $hash_path   eq '' )
{
	print STDOUT "Error\n";
	die "Bad data file";
}

$enter_point =~ s/\s+//g;
if ($enter_point=~ /[^\w+?\s*]/  ) {

	print STDOUT "Error\n";
	die "Wrong symbols error in first line, or enter point error\n";

}

$hash_path =~ s/\s+//g;
if($hash_path=~ m/[^\w+?\s+?\,+?\=>]/g) {

	print STDOUT "Error\n";
	die "Wrong Path string\n";

}

my @path = split( /,/, $hash_path );

#print "@path";

foreach (@path) {
	my @temp = split( /=>/, $_ );
	if ( exists $hash{ $temp[0] } ) {
		print STDOUT "Error/n";
		die "Error, key is not unique\n";
	}
	if (!defined($temp[1]))
	{
	 print STDOUT "Error\n";
	 die "Undefined hash value\n";
	}	
	%hash = ( %hash, @temp );

}



$" = '-';
my @list = ();
if ( exists $hash{$enter_point} )

 {
 	push( @list, $enter_point );
	for ( my $key = $enter_point ; exists $hash{$key} ; $key = $hash{$key} )
	 {

		my $counter = 0;
		push( @list, $hash{$key} );
		foreach my$key_in_array(@list)
		{
			$counter++ if($hash{$key} eq $key_in_array);						
		}
		if ($counter>1)
		{
			$is_looped = "looped";
			last;
		}
				

	}
	print STDOUT "@list","\n$is_looped\n";
	
	
}
else{
	print STDOUT "Error\n";
	die "Error! Described enter point doesnt exist in the path\n";
	
}


close(FH);

