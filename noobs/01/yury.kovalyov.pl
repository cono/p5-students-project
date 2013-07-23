#!/usr/bin/perl

#
# Math::BigFloat was not used for this task.
#

use warnings;
use strict;

# Issue with compilation:
#use Scalar::Util::Numeric;
#*is_int = \&Scalar::Util::Numeric::isint;
# or even
#use Scalar::Util::Numeric qw(isint);

# Workaround:
# Code is obtained from publuc domain -
# http://rosettacode.org/wiki/Determine_if_a_string_is_numeric#Perl - Error!
# http://pound-perl.pm.org/faq/C3/Q3.html - Ok.
sub getnum 
{
	use POSIX;
	my $str = shift;
	$str =~ s/^\s+//;
	$str =~ s/\s+$//;
	$! = 0;
	my ( $num, $unparsed ) = strtod( $str );

	if ( ( '' eq $str ) || ( 0 != $unparsed ) || $! )
	{
		return undef;
	}

	return $num;
}
 
sub is_int { defined getnum($_[0]) }

sub isKindOfOperation
{
	my $op = shift;
	return ( ( 1 == $op ) or ( 2 == $op ) );
}

sub isKindOfRadix
{
	my $radix = shift;
	return ( ( 1 < $radix ) and ( 37 > $radix ) );
}

sub printe
{
	my $message = shift;
	print STDOUT "Error\n";
	print STDERR $message;
}

sub std_div
{
	my ($number,$denominator) = @_;
	my $quotient = int( $number / $denominator );
	my $reminder = int( $number % $denominator );
	return ($quotient,$reminder);
}

# How to put it as const?
my @digits = ( '0'..'9', 'A'..'Z' );

sub to_base_impl
{
	my ( $radix, $number ) = @_;

	if ( 0 == $number )
	{
		return "0";
	}

	my @result;
	while ( 0 < $number )
	{
		my ( $quotient, $reminder ) = std_div( $number, $radix );
		unshift ( @result, $digits[$reminder] );
		$number = $quotient;
	}
	
	# join the list: 
	# 	my $result = join( '', @result);
	# e.g.:
	my $result = sprintf '%s' x @result, @result;
	return $result;
}

sub to_base
{
	my ( $number, $radix ) = @_;
	
	# skip '-' and spaces only here (not in the middle):
	my $positive = ( 0 <= $number );
	if ( !$positive )
	{
		$number =~ s/^\-(\s)*//;
	}

	my $result = to_base_impl( $radix, $number );

	return ( $positive ? $result : "-$result" );
}

sub from_base_impl
{
	my ( $radix, @numbers ) = @_;

	my $result = 0;
	foreach my $ascii ( @numbers )
	{
		$result = $result * $radix + position( $ascii );
	}

	return $result;
}

sub from_base
{
	my ( $string, $radix ) = @_;

	my @numbers = unpack ( 'C' x length($string), $string );
	
	# skip '-/+' and spaces only here (not in the middle):
	my $sign = $numbers[0];
	if ( ( 45 == $sign ) or ( 43 == $sign ) )
	{
		shift @numbers;

		while ( 32 == $numbers[0] )
		{
			shift @numbers;
		}
	}
	my $positive = ( 45 != $sign );
	
	my $result = from_base_impl( $radix, @numbers );

	return ($positive? $result : "-$result");
}

# 32 = ord ' '
# 43 = ord '+'
# 45 = ord '-'

# 48 = ord '0'
# 57 = ord '9'
# 65 = ord 'A'
# 90 = ord 'Z'

sub position
{
	my $number = shift; # value from [0..9],['A'..'Z']

	if ( ( 48 <= $number ) && ( 57 >= $number ) )
	{
		return ( $number - 48 );
	}

	if ( ( 65 <= $number ) && ( 90 >= $number ) )
	{
		return ( $number - 65 + 10 );
	}
	
	return -1;
}

sub is_radix_based_impl
{
	my ( $radix, @numbers ) = @_;

	foreach my $ascii ( @numbers )
	{
		my $digit = position( $ascii );
		if ( -1 == $digit )
		{
			return 0;
		}
		if ( $digit >= $radix )
		{
			return 0;
		}
	}

	return 1;
}

sub is_radix_based
{
	my ( $string, $radix ) = @_;
	my @numbers = unpack ( 'C' x length($string), $string );

	# skip '-/+' and spaces only here (not in the middle):
	if ( ( 45 == $numbers[0] ) or ( 43 == $numbers[0] ) )
	{
		shift @numbers;

		while ( 32 == $numbers[0] )
		{
			shift @numbers;
		}
	}
	
	my $result = is_radix_based_impl( $radix, @numbers );
	return $result;
}

( 0 == $#ARGV ) or die "Wrong number of arguments: pass test file name, please.";
my $test_file_name = $ARGV[0];

open ( FH, "<", $test_file_name ) or die "Can not open test file: $!";
while ( <FH> )
{
	chomp;
	
	# expect "number,number,numer" pattern:
	my @arr = split( /,/, $_ );
	if ( 3 != scalar(@arr) )
	{
		printe "Error: Invalid data format - expected 'number,number,number'; please check file:$test_file_name, line:$..\n";
		next;
	}

	# remove *border* spaces for sure:
	s/^\s+|\s+$//g foreach(@arr);

	my ($operation,$number,$radix) = @arr;

	# to be on the safe side:
	$number = uc( $number );

	if ( !is_int($operation) or !is_int($radix) )
	{
		printe "Error: Data within '$_' was not recognized as a number; please check file:$test_file_name, line:$..\n";
		next;
	}
	if ( !isKindOfOperation($operation) )
	{
		printe "Error: First number have to be equal 1 or 2; please check file:$test_file_name, line:$..\n";
		next;                  	
	}
	if ( !isKindOfRadix($radix) )
	{
		printe "Error: Third number should belong to the range [2..36]; please check file:$test_file_name, line:$..\n";
		next;                  	
	}

	if ( 1 == $operation )
	{
		if ( !is_int($number) )
		{
			printe "Error: Second number has wrong decimal format; please check file:$test_file_name, line:$..\n";
			next;                  	
		}

		my $result = to_base( $number, $radix );
		print STDOUT "$result\n";
		next;
	}
	
	if ( !is_radix_based( $number, $radix ) )
	{
		printe "Error: Second number has wrong format for given radix; please check file:$test_file_name, line:$..\n";
		next;                  	
	}

	my $result = from_base( $number, $radix );
	print STDOUT "$result\n";
}

close ( FH );
