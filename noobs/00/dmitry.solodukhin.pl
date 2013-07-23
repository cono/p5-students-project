#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];

open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) {
	
	my $res    = "";
	my $m      = "";
	my $result = "";
	my $d;
	$_ =~ s/\s*//g;
	
	if (!$_){
		$res = 1; 
	}else{
		my @b = (0, 0, 0);
		my @a = split(',');
		push(@a, @b);
		for(my $i = 0; $i <= 2; $i++) {
			if($a[$i] eq ""){
				$a[$i] = 0; 
			 }
			 $a[$i] = int($a[$i]);
		}
		$d = ($a[1] ** 2) - (4 * $a[0] * $a[2]);
		
		if($d < 0){
			$m = 0;
		}else{
			$m      = 1;
			$result = reshenie($a[1], $a[0], sqrt($d));
			if($d > 0){
				$m      = 2;
				$result = $result." ".reshenie($a[1], $a[0], 0 - sqrt($d));
			}
			$result = "(".$result.")";			
		}
		$result = $m." ".$result." \n";
	}

    print STDOUT $result;

    print STDERR "Error \n" if ( $res eq 1 );
}

sub reshenie
{
	return ((0 - $_[0]) + ($_[2])) / (2 * $_[1]);
}
