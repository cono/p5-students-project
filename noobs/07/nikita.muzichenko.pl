#!/usr/bin/perl -w
use strict;
my $count=0;
sub hash {
	my $hash = shift;
	my $cp   = shift;
my $cp=$cp." "x8;
	my @key = sort( keys %{$hash} );
	print "{\n";
	 for(my $s=0;$s < @key;$s++){if($s==@key-1){$count=1}
 
		print $cp, $key[$s], " => ";
		if ( $hash == $hash->{$key[$s]} ) { print "HASH,\n"; next }
		if ( &dumper( $hash->{$key[$s]},$cp) == 2 ) { next }
		print "\'", $hash->{$key[$s]}, "\'";if($s!=@key-1){print ","};print"\n";
	}
	$cp = "";$count=0;

}

sub regexp {
	my $reg = shift;
	print "Regexp";if($count!=1){print ","};print"\n";
}

sub array {
	my $array = shift;
		my $cp   = shift;
my $cp=$cp." "x8;
	print "[\n";
	for(my $s=0;$s < @$array;$s++) {
		print $cp, "\'", @$array[$s], "\'";if($s!=@$array-1){print ","};print"\n";
	}
	
	$cp = "";
}

sub obgect {
	my $obgect = shift;
	print $obgect->get_struct(); if($count!=1){print ","};print"\n";
}

sub scalar {
	my $scal = shift;
	print "\'", $$scal, "\'";if($count!=1){print ","};print"\n";
}

sub ref1 {
	my $ref = shift;
	my $cp  = shift;
	print "REF:";
	$ref = $$ref;
	if ( $ref ne "REF" ) { &dumper( $ref, $cp ) }

}

sub code {
	my $code = shift;
	print "CODE";if($count!=1){print ","};print"\n";
}
my $cp = "";

sub dumper {

	my $per = ref $_[0];
	my $cp  = $_[1];
	if ( $per eq "REF" ) { &ref1( $_[0], $cp ); return 2 }
	if ( $per eq "HASH" ) { &hash( $_[0], $cp );print $cp."}";if($cp){print","};print"\n"; return 2 }
	if ( $per eq "ARRAY" )  { &array( $_[0],$cp ); print $cp."]";if($cp){print","};print"\n"; return 2 }
	if ( $per eq "CODE" )   { &code( $_[0] );   return 2 }
	if ( $per eq "Regexp" ) { &regexp( $_[0] ); return 2 }
	if ( $per eq "SCALAR" ) { &scalar( $_[0] ); return 2 }
	if ( $per =~ /[\w]/g ) { &obgect( $_[0] ); return 2 }
	return "";
}

my $ref ;
my $hash;
my $array;
my $code;
my $regexp;
my $scalar;
my $key;
my @arr;
my $list;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path" ) or die "Can not open test file: $!";
@arr=(<FH>) ;
close(FH);
$key= uc$arr[0];chomp$key;
shift@arr;
foreach(@arr){$list=$list.$_};
eval $list;
my %lab=("HASH"=>$hash,"ARRAY"=>$array,"CODE"=>$code,"REGEXP"=>$regexp,"REF"=>$ref,"SCALAR"=>);
print STDOUT &dumper( $lab{$key}, $cp ),return "";
