#!/usr/bin/perl

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my $strin=<FH>;
chop $strin;
my $flag=0;
if ($strin=~/^\w+$/)
{
	$flag=1;
}
else
{
	print STDOUT "0\n";
	die("string is not alphanumeric");
}
my $strold=$strin;
my $strout=$strin;
my %hash=();
while (<FH>)
{
	$str=$_;
	$str=~s/#.*$//;
	if ($str=~/^('|"|)(\w+)\1\s*(=|=>)\s*('|"|)(\w+)\4$/)
	{
		$hash{$2}=$5;
	}
	elsif (($str eq "\n") or ($str eq ""))
	{
		#nothing
	}
	else
	{
		print STDOUT "0\n";
		die("error in hash data");
	}
}
foreach $key(sort {$hash{$b} cmp $hash{$a}} keys %hash)
{
	if ($strold=~/$key/)
	{
		$strold=~s/$key//g;
		$strout=~s/$key/$hash{$key}/g;
	}
}
$res=$strout;
print STDOUT "$res\n";
close(FH);