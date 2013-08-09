#!/usr/bin/perl -w
use strict;
use Scalar::Util;

my %mark = ();
my $tcount = 0;

sub marked
{
  return exists($mark{$_[0]});
}

sub active
{
  if ( marked($_[0]) ) { return }
  $mark{$_[0]} = 1;
  return;
}

sub control
{
  my $name = shift;
  my $inf = shift;
  my $type = ref($inf);
  
  my %subhash = ("" => *scalar_sub, 'SCALAR' => *scalar_sub, 'ARRAY' => *array_sub, 'HASH' => *hash_sub,
	           'CODE' => *code_sub, 'REF' => *ref_sub, 'Regexp' => *regexp_sub);

  if(!exists($subhash{$type}))
  {
	if(Scalar::Util::blessed($inf)) { return bless_sub($name, $inf) }
	return "";
  }

  my $sub = $subhash{$type};

  my $result = &$sub($name, $inf);
  return $result;
}

sub bless_sub
{
  my $name = shift;
  my $data = shift;

  my $result = "";	

  $result = $result . printTabs() . "$name => " . $data->get_struct();

  return $result;
}

sub scalar_sub
{
  my $name = shift;
  my $val = shift;

  my $result = "";	

  if ($name ne "") { $result = $result . printTabs() . "$name => " }

  $result =$result . "$val";

  return $result;
}

sub array_sub
{
  my $name = shift;
  my $child = shift;

  my $result = "";

  if ($name ne "") { $result = $result . printTabs() . "$name => "; }

  if (marked($child))	{ $result = $result . "ARRAY"; return $result; }
  active( $child );

  $result = $result.  "[\n";
  $result = $result . join( ",\n", map {$tcount++; my $result = printTabs() . control( "", $_ ); $tcount--; $result; } @{ $child } );
  $result = $result. "\n";
  $result = $result . printTabs() . "]";

  return $result;
}

sub hash_sub
{
  my $name = shift;
  my $refhas = shift;
  my %h = %{$refhas};

  my $result = "";
	
  if ($name ne "") { $result =  $result . printTabs() . "$name => "; }

  if (marked($refhas)) { $result = $result . "HASH"; return $result; }
  active( $refhas );

  $result = $result . "{\n";

  $result = $result . join( ",\n", map {$tcount++; my $result = control( $_, $h{$_} ); $tcount--; $result; } sort keys( %h ) );
  $result = $result .  "\n";
  $result = $result .  printTabs() . "}";
	
  return $result;
}

sub code_sub
{
  my $name = shift;
  my $result = "";

  if($name ne "") { $result = $result . printTabs() . "$name => "; }
  $result = $result . "CODE";
  return $result;
}

sub undefmark
{
  my $param = shift;
  my $n = 0;
	
  while ( "REF" eq ref($param) ){
    $n++;
    $param = $$param;
  }

  return ($n, $param ); 
}

sub ref_sub
{
  my $name = shift;
  my $val = shift;
	
  my $result = "";

  if($name ne "") { $result .= printTabs() . "$name => "; }

  my ( $number, $reference ) = undefmark( $val );
  $result = $result . "REF:" x $number;

  if ( my $fixScalarCase = (ref($reference) eq "SCALAR")) { $reference = $$reference; }

  $result = $result .  control("", $reference );

  return $result;
}

sub regexp_sub
{
  my $name = shift;
  my $result = "";

  if ($name ne ""){ $result = $result . printTabs() . "$name => "; }
  $result = $result . "Regexp";
	
  return $result;
}

sub printError
{
  print STDOUT "ERROR\n";
  print STDERR "$_[0]\n";            
}

sub printTabs()
{
  return "\t" x $tcount;
}

sub delSpace($)
{
  my $var = shift; 
  $var =~ s/^\s+//g;
  $var =~ s/\s+$//g;
  return $var;
}

my $top = 'my $$VAR = undef;';

my $bottom = <<'EOT';
{
  my $result = "";
  $result .= control( "", $$VAR );
  $result .= "\n";
	
  print $result;
  # exit 0; #
}
EOT

sub form
{
  my $param = shift;
  my $name_sub = shift;
  my $linetop = $top;
  my $linebottom = $bottom;
  
  $linetop =~ s/\$VAR/$param/g;
  $linebottom =~ s/\$VAR/$param/g;

  my $code = $linetop . $name_sub . $linebottom;

  return $code;
}

($#ARGV == 0) or die "Missing file name";
my $test_file_name = $ARGV[0];

open ( FH, "<", $test_file_name ) or die "Can not open test file: $!";

my $var = delSpace(<FH>);
my $codeline = join('', <FH>);
my $code = form($var, $codeline);

my $resultult = eval( $code );
if ( !defined($resultult)) { printError ("$@"); exit 1; }
