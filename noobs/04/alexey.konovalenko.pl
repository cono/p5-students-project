#!/usr/bin/perl -w
use strict;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path" ) or die "Can not open test file: $!";

my $str         = undef;
my @keys        = ();
my %hash        = ();

while (<FH>) {
		#loading strings
	if (/^\s*?((\w+?)\s*)+$/) {
		#line handling
		$str .= $&;
	}
	elsif (/^\s*\#(.)*?$/) {
		#commentary handling
		next;
	}
	elsif (/^\s*(['"]?)(?<key>\w+)\g{1}\s*=\s*>?\s*(['"]?)(?<value>\w+)\g{3}\s*$/i)
	{
		#hash handling
		%hash = ( %hash, $+{key} => $+{value} );
	}
	else {
		my $err_str = $_;
		$_ =~ s/\s*//g;		
		if ( ( !defined( chomp($_) ) ) || ( $_ eq "" ) ) {
			next;
		}
		print STDOUT "0\n";
		die "Error! Bad file data, line isn't correct\n $err_str";
	}
}
close(FH);

#Empty file check
if ( !defined($str) ) {
	print STDOUT "0\n";
	die "Error! File is empty or no replacement string";
}
##Empty hash check
#if ( scalar keys %hash == 0 ) {
#	print STDOUT "0\n";
#	die "Error! There is no combinations to replace";
#}
#reverse sorting hash keys
@keys = reverse( sort ( keys %hash ) );

#replacement
foreach my $key (@keys) {
	my $temp_str="";	
	my $chgKey = $key;
	my $changeVal = $hash{$key};
	while ( $str =~ /{\w+?}/g ) {
		my $changedWord    = $&;
		my $newStrToChange = $`;		
		$str = $';
		#changing $`
		$newStrToChange =~ s/$chgKey/{$changeVal}/g;
		$temp_str .= $newStrToChange . $changedWord;
	}
	$str =~ s/$chgKey/{$changeVal}/g;
	$str = $temp_str . $str;	
}
#printing
$str =~ s/[{}]//g;
print STDOUT "$str\n";