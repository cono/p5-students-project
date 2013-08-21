#!/usr/bin/perl -w
#task_04
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", $ARGV[0]) or die "Can not open test file: $!";

my $EnterPoint='';
my $flagRepString=1;
my %myHash;
while ( <FH> ) {
s/\s//g;
if ($_ ne ""  && !m/^#/ && $flagRepString)
{
	$EnterPoint=$_;
	$flagRepString=0;
	#print '++'.$EnterPoint."-\n";

}
elsif (!$flagRepString)
{

my $currentHashKey=$_;
/("|')(.+)("|')(=|=>)("|')(.+)("|')/;	
if (defined($2))
{
	print STDOUT "0\n";
	die "Wrong type of argument\n";
}
else
{
$myHash{$2}=$6;
}

}
}


my @sorted_keys = (sort {$myHash{$b} cmp  $myHash{$a}} keys %myHash);

print "------\n";
foreach(@sorted_keys){
    my $ss=$_;
	$_=$EnterPoint;
	s/$ss/$myHash{$ss}/g;
	$EnterPoint=$_;	
}; 
print STDOUT  "$EnterPoint\n";
close ( FH );


