#!/usr/bin/perl -w

use strict;
use feature "state";

sub round {
	my $key = shift;
	my %inner_hash = %{shift()};
	state $result .= $key . ":";
	my $value = $inner_hash{$key};
	if(!defined $value){
		return "n";
	}
	if(index($result, $value.":") != -1){
		return "$value-l";
	}
	$result = $value . "-" . round($value, \%inner_hash);
}

sub print_error_message_and_exit {
	print STDOUT "error\n";
	print STDERR $_[0];
	exit 0;
}

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my $start_point = <FH>;
my $string_contains_hash = <FH>;
my @key_val;
my %hash;
eval{
	die "Some input data is absent"
		if (!defined $start_point || !defined $string_contains_hash);
	chomp $start_point;
	chomp $string_contains_hash;
	$start_point =~ s/^\s+//;
	$start_point =~ s/\s+$//;
	die "Start point contains wrong data"
		if($start_point =~ /\W/);
	$string_contains_hash =~ s/^\s+//;
	$string_contains_hash =~ s/\s+$//;
	die "Empty data"
		if((!length $start_point) || (!length $string_contains_hash));
	die "Commas at the end of input data"
		if($string_contains_hash =~ /,+$/);	
	die "Wrong input data"
		if($string_contains_hash =~ /\w\s+\w/);
	@key_val = split /,\s*/, $string_contains_hash;

	for my $hash_pair(@key_val){
		if($hash_pair =~ /(\S+)=>(\S+)/){
			die "Key or value contains wrong data"
				if(($1 =~ /\W/) || ($2 =~ /\W/));
		} else{
			die "Key/value separator is not '=>' or some of they are empty";
		}
		$hash{$1} = $2;
	}
};
if($@){
	&print_error_message_and_exit($@);
}

my $pre_result_string = &round($start_point, \%hash);
my $r_index = rindex $pre_result_string, "-";
my $result_string = substr $pre_result_string, 0, $r_index, "";

if(!length $result_string){
	&print_error_message_and_exit("Path doesn't exist\n");
}
print STDOUT "$start_point-$result_string\n";
print STDOUT "looped\n" if $pre_result_string eq "-l";

close ( FH );
