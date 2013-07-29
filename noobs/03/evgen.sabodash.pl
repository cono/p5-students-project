#!/usr/bin/perl -w
use strict;

sub Trim { 
	my $value = $_[0];
	$value =~ s/^\s+//;
	$value =~ s/\s+$//;
	return $value;
}

my $test_file_path = $ARGV[0];

open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my $first = <FH>;
chomp($first);

$first = Trim($first);

if ($first eq "")
{
	print STDOUT "error\n";
	print STDERR "First string is empty\n";
	exit;
}
elsif ($first =~ /\W+/)
{
	print STDOUT "error\n";
	print STDERR "First string has invalid characters\n";
	exit;
}

my $str = <FH>;
if (!defined($str))
{
	print STDOUT "error\n";
	print STDERR "File is empty\n";
	exit;
}
 
chomp($str);

if ( Trim($str) eq "")
{
	print STDOUT "error\n";
	print STDERR "Second string is empty\n";
	exit;
}

{
	my @array = split (/,/,$str);
	my %hash;
	foreach (@array){
		my $key = my $value = my $tail = undef;
		($key, $value, $tail) = split(/=>/,$_);
		if (defined($tail))
		{
				print STDOUT "error\n";
				print STDERR "Tail\n";
				exit;
		}
		if ( !defined($key) || !defined($value))
		{
				print STDOUT "error\n";
				print STDERR "Missing key or value\n";
				exit;
		}		
		$key = Trim($key);		
		$value = Trim($value);		
		
		if ( ($key =~ /\W/) || ($key =~ /\s+/) || ($key eq ""))
		{
			print STDOUT "error\n";
			print STDERR "Key has invalid characters\n";
			exit;
		}
		if ( ($value =~ /\W/) || ($value =~ /\s+/) || ($value eq "") )
		{
			print STDOUT "error\n";
			print STDERR "Value has invalid characters\n";
			exit;
		}
		
		$hash{"$key"} = $value;		 
	}
	
	my $current = $first;
	
	#if (!exists($hash{$current}))
	#{
	#	print STDOUT "error\n";
	#	print STDERR "Key doesn't exist\n";
	#	exit;
	#}
	
	print $current;
	while (exists($hash{$current})) {
		$current = $hash{$current};
		print "-$current";
		if ($current eq $first)
		{
			print "\nlooped";
			last;
		}
	}
	print "\n"; 
}

close ( FH );