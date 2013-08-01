#!/usr/bin/perl -w
use strict;

sub sortirovka() {
	my %hash;
	my $start = $_[0];
	my @start = $_[0];
	shift @_;
	my @arr = @_;
	if ( $start !~ /^(\s+)?(\w+)(\s+)?(\#[\d\D]+)?$/g ) {
		$! = "Substitution string empty";
		return "0";
	}
	foreach (@arr) {
		if ( $_ =~
/^((\s+)?("(?<key>\w+)"|(?<key>\w+)|\'(?<key>\w+)\')(\s+)?(=>|=)(\s+)?("(?<value>\w+)"|(?<value>\w+)|\'(?<value>\w+)\')(\s+)?(\#[\d\D]+)?)+$/
		  )
		{
			$hash{ $+{key} } = $+{value};
		}
		elsif ( $_ =~ /^(\s+)?(\#[\d\D]+)?(\s+)?$/g ) { next }
		else { $! = "incorrect input hesh"; return "0" }
	}
	
	my @sortkey = reverse( sort keys %hash );
	foreach my $el (@sortkey) {
		if ( $start[0] =~ /[\>\<]/g ) { @start = split( /[<> ]/, $start ) }
		foreach my $el1 (@start) {
			if ( $el1 !~ /\=/g ) {
				$el1 =~ s/$el/<=$hash{$el}=>/g;
			}
		}
		$start = "@start";
	}
	$start =~ s/[=>< ]//g;
	return $start;
}
my $test_file_path = $ARGV[0];
my @arr;
open( FH, "<", "$test_file_path" ) or die "Can not open test file: $!";
while (<FH>) {
	$_ =~ s/[\r\n]+$//s;
	@arr = ( @arr, $_ );
}
my $rez = &sortirovka(@arr);
print STDOUT "$rez\n";
print STDERR "$!\n" if ( $rez eq '0' );
close(FH);
