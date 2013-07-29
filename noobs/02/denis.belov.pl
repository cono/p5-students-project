#!/usr/bin/perl -w

use strict;

sub print_error_message_and_exit {
	print STDOUT "error\n";
	print STDERR $_[0];
	exit 0;
}

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my $inputData = <FH>;

eval{
	die "Wrong input data" 
		if((!defined $inputData) || ($inputData =~ /[^A-Za-z0-9\s]/));		
};
if($@){
	&print_error_message_and_exit($@);
}
chomp $inputData;
$inputData =~ s/^\s+//;
$inputData =~ s/\s+/ /g;
eval{
	die "Input data is absent"
		if(!length $inputData);
};
if($@){
	&print_error_message_and_exit($@);
}

my @inputFromFile = split / /, $inputData;
my %array_of_frequencies;
for my $word(@inputFromFile){
	if(exists $array_of_frequencies{$word}){
		$array_of_frequencies{$word} .= "*";
	} else {
		$array_of_frequencies{$word} = "*";
	}
}
foreach my $word (sort keys %array_of_frequencies){
	print STDOUT "$word $array_of_frequencies{$word}\n";  
}

close ( FH );
