#! /usr/bin/perl -w
use strict;

my $file = "";
my $entry = "";

my $out = "";
my $error = "";

my %hash = ();

open FIN, $ARGV[0] or die "Can not open file $file: $!";

$entry = <FIN>;
$file .= $_ while (<FIN>);

close FIN;

$entry =~ s/^\s+|\s+$//g if defined($entry);

if (!defined($entry) || $entry !~ m/^\w+$/){
	
	print STDOUT "error\n";
	print STDERR "There is no correct entry key!\n";
	exit 1;
}
	
if ($file =~ m/^\s*$/){
	print STDOUT "error\n";
	print STDERR "No hash!\n";
	exit 1;
}

chomp($file);
if (index($file, "\n") != -1){

	print STDOUT "error\n";
	print STDERR "More than 2 lines!\n";
	exit 1;
}

my @array = split(/,/,$file);
$_ =~ s/^\s+|\s+$//g foreach (@array);

foreach (@array){
	
	if (defined($_) && $_ =~ m/^(\w+)\s*=>\s*(\w+)$/){
		$hash{$1} = $2;
	} else {
		print STDOUT "error\n";
		print STDERR "Wrong pair/data or no data!\n";
		exit 1;
	}
}

$out = $entry;
my $it = $entry;
my %check = ($entry => 0);

while (1){
	
	$it = $hash{$it};
	
	if (defined($it) && exists($check{$it})){
		
		$out .= "-".$it."\nlooped";
		last;
	} elsif (defined($it)){

		$check{$it} = 0;
		$out .= "-".$it;
	} else {
		
		last;
	}
}

print STDOUT $out."\n";
print STDERR $error."\n" if ($out eq "error");
