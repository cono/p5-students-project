#!/usr/bin/perl

#
# Math::BigFloat was not used for this task.
#

use warnings;
use strict;

use Scalar::Util;
*is_number = \&Scalar::Util::looks_like_number;


# Code is obtained from public domain e.g. "Perl Cook Book", etc.:
# http://doc.sumy.ua/prog/pb/cookbook/ch02_03.htm
# http://www.perlmonks.org/?node_id=293402
sub floatEqual
{
	my ( $A, $B, $dp ) = @_;

	if ( ( $A == $B ) or ( $A eq $B ) )
	{
		return 1;
	}

	return ( sprintf( "%.${dp}g", $A) eq sprintf( "%.${dp}g", $B) );
}

# Get some descriptions at:
# http://habrahabr.ru/post/171203/
# http://computer-programming-forum.com/53-perl/84374cdecb07fc34.htm
my %IEEE754 =
(
	 "1.#INF"	,	1
	,"-1.#INF"	,	1
	,"1.#SNAN"	,	1
	,"-1.#SNAN"	,	1
	,"1.#QNAN"	,	1
	,"-1.#QNAN"	,	1
	,"1.#IND"	,	1

	,"Inf"		,	1
	,"Infinity"	,	1
	,"NaN"		,	1
	,"0 but true",	1
	
);

sub isKindOfNaN
{
	my $str = shift;
	return ( defined $IEEE754{$str} );
}

sub printe
{
	my $message = shift;
	print STDOUT "Error\n";
	print STDERR $message;
}

( 0 == $#ARGV ) or die "Wrong number of arguments: pass test file name, please.";
my $test_file_name = $ARGV[0];

open ( FH, "<", $test_file_name ) or die "Can not open test file: $!";
while ( <FH> )
{
	# remove all whitespace symbols e.g.: $_ =~ s/\s+//g; 
#	s/\s+//g;
	# - commented as in few exceptional cases may get wrong evaluation order

	# but atleast chomp to get nice single line error messages
	chomp;

	# expect "number,number,numer" pattern:
	my @arr = split( /,/, $_ );
	if ( 3 != scalar(@arr) )
	{
		printe "Error: Invalid data format - expected 'number,number,number'; please check file:$test_file_name, line:$..\n";
		next;
	}

	my ($a,$b,$c) = @arr;
	if ( !is_number($a) or !is_number($b) or !is_number($c) )
	{
		printe "Error: Data within '$_' was not recognized as a number; please check file:$test_file_name, line:$..\n";
		next;
	}
	if ( isKindOfNaN( $a ) or floatEqual ( 0, $a, 15 ) )
	{
		printe "Error: First number was recognized as 0 - not a quadratic equation; please check file:$test_file_name, line:$..\n";
		next;                  	
	}
	
	# calcualate
	my $d = ( $b * $b ) - ( 4 * $a * $c );
	if ( isKindOfNaN( $d ) )
	{
		printe "Error: IEEE 754 issue detected - can not evaluate discriminant of quadratic equation; please check file:$test_file_name, line:$..\n";
		next;                  	
	}
	
	if ( 0 > $d )
	{
		print STDOUT "0\n";
		next;
	}

	if ( 0 < $d )
	{
		my $minus_b = -$b;
		my $d_sqrt = sqrt( $d );
		my $a_2 = $a * 2;

		if ( isKindOfNaN( $minus_b ) or isKindOfNaN( $a_2 ) or isKindOfNaN( $d_sqrt ) or floatEqual ( 0, $a_2, 15 ) )
		{
			printe "Error: IEEE 754 issue detected - can not evaluate roots of quadratic equation; please check file:$test_file_name, line:$..\n";
			next;                  	
		}
		
		my $x1 = ($minus_b + $d_sqrt) / $a_2;
		my $x2 = ($minus_b - $d_sqrt) / $a_2;
		print STDOUT "2 ($x1 $x2)\n";
		next;
	}
	
	{
		my $minus_b = -$b;
		my $a_2 = $a * 2;
		
		if ( isKindOfNaN( $minus_b ) or isKindOfNaN( $a_2 ) or floatEqual ( 0, $a_2, 15 ) )
		{
			printe "Error: IEEE 754 issue detected - can not evaluate root of quadratic equation; please check file:$test_file_name, line:$..\n";
			next;                  	
		}
    
		my $x = $minus_b / $a_2;
		print STDOUT "1 ($x)\n";
	}

}

close ( FH );
