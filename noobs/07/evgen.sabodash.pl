#!/usr/bin/perl -w
use strict;
use Data::Dumper;
sub func {
	my $tab = $_[0];
	my $r = $_[1];
	my $deep_ref = $_[2];
	if (ref($r) eq "SCALAR")
	{
		print "'$$r'";
	}
	elsif (ref($r) eq "HASH")
	{
		my @koh = sort( keys %$r);
		print "{\n";
		for  (my $i = 0; $i < scalar @koh; $i++){	#	foreach my $key (@koh){
			print "$tab\t$koh[$i] => ";
			if ($r->{$koh[$i]} == $r) { print "HASH";}
			else {	func( $tab."\t" ,\($r->{$koh[$i]}),0);}
			if ($i+1 != scalar @koh ) {print ",\n"};  #print ",\n";
		}
		print "\n$tab}";
	}
	elsif (ref($r) eq "REF")
	{
		if ($deep_ref > 0) {print "REF:"};
		func( $tab ,$$r, $deep_ref+1);
	}
	elsif (ref($r) eq "ARRAY")
	{
		print "[\n";
		for  (my $i = 0; $i < scalar @$r; $i++){
			print "$tab\t";
			func( $tab."\t" ,\($r->[$i]));
			if ($i+1 != scalar @$r ) {print ",\n"};
		}
		print "\n$tab]";
	}
	elsif (ref($r) eq "CODE" || ref($r) eq "Regexp" ) {	
		print ref($r)
	}
	else{
		print $r->get_struct();
	}
}
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $fileContent;
{
 local $/;
 $fileContent = <FH>;
}
close(FH);
$_ = $fileContent;
s/(.*)\n/my \$$1;\n/;
my $str = '$'.$1;
my $a;
$_ =  $_."\n\$a = ".$str.";\n" ;
eval $_;
func ("", $a, 0);
print "\n";