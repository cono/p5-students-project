#!/usr/bin/perl -w

use strict;

sub print_error_message_and_exit {
	print STDOUT "0\n";
	print STDERR $_[0];
	exit 0;
}

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my $replacement_string = <FH>;
my %hash;
eval{
	die "Replacement string is undefined"
		if(!defined $replacement_string);
	chomp $replacement_string;
	die "Replacement string is empty"
		if(!length $replacement_string);
	$replacement_string =~ s/^\s+//;
	$replacement_string =~ s/\s+$//;
	die "Replacement string conteins wrong characters"
		if($replacement_string =~ /\W/);
	my $key_value_string;
	while( <FH> ){
		chomp;
		$key_value_string = $_;
		if($key_value_string =~ /(^\s*#+.*|^$)/){
			next;
		}
		die "Key/value string conteins wrong characters or it does not correspond to given format"
			if($key_value_string !~ /^\s*(['|"]?)(\w+)\1\s*=>?\s*(['|"]?)(\w+)\3\s*(#.*)?/);
		$hash{$2} = $4;
	}
};
if($@){
	&print_error_message_and_exit($@);
}
if(!(keys %hash)){
	print STDOUT $replacement_string . "\n";
	exit 0;
}

my $value;
my $begin_string;
my $end_string;
for my $key(sort{$b cmp $a} keys %hash){
	$value = $hash{$key};
	while($replacement_string =~ /(?:\A\w*|>{1}|>{1}\w+)$key(?:\w*\Z|<{1}|\w+<{1})/){
		$begin_string = $`;
		$end_string = $';
		$replacement_string = $&;
		$replacement_string =~ s/$key/<$value>/;
		$replacement_string = $begin_string . $replacement_string . $end_string;
	}
}

$replacement_string = join('', split(/[>|<]/, $replacement_string));
print STDOUT $replacement_string . "\n";
close(FH);
