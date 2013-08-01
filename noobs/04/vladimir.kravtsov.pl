#!/usr/bin/perl -w
use strict;
use diagnostics;




my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my ($elem, $str1, $key);
my  $lnum = 0;
my %hash;
my @array;

if ( $elem = <FH>)
{
	chomp ($elem);
	if ($elem eq ""){print "0\n"; die "Line data contain error\n"; };
	
	while ( <FH> ) 
	{
		$lnum ++;
		$str1 = $_;
		next if( $str1 eq "\n" or $str1 =~/^\s*#/);
		$str1 =~ s/#.*//;
		#die "\n$str1\n" if ( $str1 =~/^\s*\s|'|"([a-zA-Z0-9]+)"|'|\s*([a-zA-Z0-9]+)$/);
		$str1 =~ s/"([a-zA-Z0-9]+)"/$1/g;
		$str1 =~ s/'([a-zA-Z0-9]+)'/$1/g;
		$str1 =~ s/([a-zA-Z0-9]+)/ $1 /g;
		$str1 =~ s/\s+/ /g;
		$str1 =~ s/ = /,/g;
		$str1 =~ s/ => /,/g;
		$str1 =~ s/(^ )//;
		chop $str1;
		
		if( $str1 =~/^([a-zA-Z0-9]+),([a-zA-Z0-9]+)$/)
		{
			push (@array, split /,/,$str1);
		}
		else
		{
			print "0\n"; die "Line $lnum contain error\n"; 
		}
	}

	
}
else
{
	print "0\n"; die "File is empty\n";
}
%hash = @array;
@array = ();

foreach $key( sort keys %hash)
{
        push (@array, $key);
}



while (@array)
{
	$key = pop @array;
	$lnum = (join "_", split(//,$hash{$key}))."_";
	$elem =~ s/$key(?=[a-z0-9A-Z])/$lnum/g;
}

$elem =~s/_//g;

print "$elem\n";
close ( FH );



