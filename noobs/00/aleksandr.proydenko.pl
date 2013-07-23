#!/usr/bin/perl -w
use strict;

# online calculator:
# http://numsys.ru/


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) {

(my $a,my $b,my $c)=split(/,/,$_,3);

if(!defined($a)||!defined($b) || !defined($c) || $a==0){print "Error"}else{
my $x1;
my $x2;
my $n;
my $d=$b**2-4*$a*$c;
if ($d < 0){ print "0";} elsif($d==0)
{
	$x1=-$b/(2*$a);
	$n=1;
	print "$n (${x1})";
}else{
	$n=2;
	$x1=(-$b+($d**(1/2)))/(2*$a);
	$x2=(-$b-($d**(1/2)))/(2*$a);
	print "$n ($x1 ${x2})";
}
}	print STDOUT "\n";
	print STDERR "\n" if ( my $res eq 'Error' );
}
close ( FH );

