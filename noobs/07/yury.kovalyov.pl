#!/usr/bin/perl
########################################################
package main;

# Note:
# I think it would be better to use Visitors, but we have no time.

use warnings;
use strict;

my %table = (
'' => *_scalar,
'SCALAR' => *_scalar,
'ARRAY'	 => *_array,
'HASH'	 => *_hash,
'CODE'	 => *_code,
'REF' 	 => *_ref,
'Regexp' => *_regexp,
);
=pod
'GLOB'
'LVALUE'
'FORMAT'
'IO'
'VSTRING'
=cut

my $tabs = 0;
my %visited = ();

sub is_visited
{
	my $reference = shift;
	return exists( $visited{$reference} );
}

sub visit
{
	my $reference = shift;

	if ( is_visited($reference) )
	{
		return;
	}

	$visited{$reference} = 1;
	return;
}

sub printt()
{
	return "\t" x $tabs;
}

sub dispatch_container
{
	my $name = shift;
	my $data = shift;
	my $type = ref( $data );
	# printd "$type\n";

	if ( my $unknownType = ( ! exists $table{$type} ) )
	{
		use Scalar::Util;
		if ( Scalar::Util::blessed($data) )
		{
			return _blessed($name,$data);
		}

		return "";
	}

	my $sub = $table{$type};

	my $res = &$sub( $name, $data );
	return $res;
}

sub _blessed
{
	my $name = shift;
	my $data = shift;

	my $res = "";	

	$res .= printt() . "$name => " . $data->get_struct();

	return $res;
}

sub _scalar
{
	my $name = shift;
	my $value = shift;

	my $res = "";	

	if ( "" ne $name )
	{
		$res .= printt() . "$name => ";
	}

	if ( defined $value )	
	{
		if ( my $fixBackSlashUndefCase = ( "SCALAR" eq ref ( $value ) ) )
		{
			$value = $$value;
		}
	}

	if ( !defined $value )
	{
		$value = "";
	}

	$res .= "'$value'";

	return $res;
}

sub _array
{
	my $name = shift;
	my $children = shift;

	my $res = "";

	if ( "" ne $name )
	{
		$res .= printt() . "$name => ";
	}

	if ( is_visited($children) )	
	{
		$res .= "ARRAY";
		return $res;
	}
	visit( $children );

	$res .= "[\n";

	{
		$res .= join( ",\n"
					  , map 
						{
							++$tabs;
							my $res = printt() . dispatch_container( "", $_ );
							--$tabs;
							$res;
						} @{ $children }
					);

		$res .= "\n";
	}

	$res .= printt() . "]";

	return $res;
}

sub _hash
{
	my $name = shift;
	my $ref_to_hash = shift;
	my %h = %{$ref_to_hash};

	my $res = "";
	
	if ( "" ne $name )
	{
		$res .= printt() . "$name => ";
	}

	if ( is_visited($ref_to_hash) )	
	{
		$res .= "HASH";
		return $res;
	}
	visit( $ref_to_hash );

	$res .= "{\n";
	{
		my @children = sort keys( %h );

		$res .= join( ",\n"
					  , map 
						{
							++$tabs; 
							my $res = dispatch_container( $_, $h{$_} );
							--$tabs;
							$res;
						} @children 
					);

		$res .= "\n";

	}
	$res .= printt() . "}";
	
	return $res;
}

sub _code
{
	my $name = shift;
	my $value = shift;

	my $res = "";

	if ( "" ne $name )
	{
		$res .= printt() . "$name => ";
	}

	$res .= "CODE";

	return $res;
}

sub un_reference
{
	my $reference = shift;
	my $number = 0;
	
	while ( "REF" eq ref($reference) )
	{
		++$number;
		$reference = $$reference;
	}

	return ( $number, $reference ); 
}

sub _ref
{
	my $name = shift;
	my $value = shift;
	
	my $res = "";

	if ( "" ne $name )
	{
		$res .= printt() . "$name => ";
	}

	my ( $number, $reference ) = un_reference( $value );
	$res .= "REF:" x $number;

	if ( my $fixScalarCase = ( "SCALAR" eq ref ( $reference ) ) )
	{
		$reference = $$reference;
	}

	$res .= dispatch_container( "", $reference );
#	print "\n";

	return $res;
}

sub _regexp
{
	my $name = shift;
	my $value = shift;

	my $res = "";

	if ( "" ne $name )
	{
		$res .= printt() . "$name => ";
	}
	$res .= "Regexp";
	
	return $res;
}

########################################################

sub printe
{
	my $message = shift;
	print STDOUT "ERROR\n";
	print STDERR $message;
	return;
}

sub cutspaces($)
{
	my $var = shift; 
	$var =~ s/^\s+//g;
	$var =~ s/\s+$//g;
	return $var;
}

my $header = <<'EOT';
my $$VAR = undef;


EOT

my $footer = <<'EOT';


{
	my $res = "";
	$res .= dispatch_container( "", $$VAR );
	$res .= "\n";
	
	print $res;
	# exit 0; #
}

EOT

sub build_code
{
	my $var_name = shift;
	my $driver_code = shift;

	my $code_header = $header;
	$code_header =~ s/\$VAR/$var_name/g;

	my $code_footer = $footer;
	$code_footer =~ s/\$VAR/$var_name/g;

	my $code = $code_header . $driver_code . $code_footer;

	return $code;
}

( 0 == $#ARGV ) or die "Wrong number of arguments: pass test file name, please.";
my $test_file_name = $ARGV[0];

open ( my $test_file_handle, "<", $test_file_name ) or die "Can not open test file: $!";

my $var = cutspaces( <$test_file_handle> );
my $driver_code = join( '', <$test_file_handle> );
my $code = build_code( $var, $driver_code );

my $result = eval( $code );
if ( $@ )
{
	chomp( $@ );
	chomp( $! );
	printe "$code\n\n$@ - $!\n\n";
	exit 2;	
}
