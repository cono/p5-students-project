#!/usr/bin/perl -w
use strict;
my %hash;
my @ar_of_keys;
sub rep {
	my $level = $_[0];
	my $str = $_[1];
	my $r = "";	
	
	if ($level==( -(scalar @ar_of_keys) )){
		$r = $str;
		$r =~ s/$ar_of_keys[$level]/$hash{$ar_of_keys[$level]}/g;			
	}
	else
	{
		my @ar_str = split(/$ar_of_keys[$level]/,$str);
		foreach (@ar_str){
			$r = $r.rep($level - 1, $_).$hash{$ar_of_keys[$level]};
		}
		if ( !($str=~/$ar_of_keys[$level]$/)){
		
			$r =~ s/$hash{$ar_of_keys[$level]}$//g;
		}
	}
		print $r."\n";
	return $r;	
}

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

$first =~ s/#.*//;
$first = Trim($first);
if ( ($first eq "") || ($first=~/\W+/) || ($first=~/_/) )	{
	print STDOUT "0\n";
	print STDERR "First string is invalid\n";
	exit;
}


while (<FH>){
	chomp;
	$_ =~ s/#.*//;
	$_ = Trim($_);
	if ($_ eq "") {
		next;
	}
	my $key = my $value = my $tail = undef;
	($key, $value, $tail) = split(/=[>]?/, $_);
	if ( defined($tail)) {
		print STDOUT "0\n";
		print STDERR "Tail\n";
		exit;
	}
	if ( !defined($value) ) {
		print STDOUT "0\n";
		print STDERR "Problem with $_\n";
		exit;
	}	
	$key = Trim($key);
	$value = Trim($value);
	
	if ($key =~ /^".*"$/) {
		$key =~ s/^"//;		
		$key =~ s/"$//;		
	}
	elsif ($key =~ /^'.*'$/) 
	{
		$key =~ s/^'//;		
		$key =~ s/'$//;		
	}
	if ( ($key =~ /\W+/) || ($key =~ /\_/) || ($key eq "") )
	{
		print STDOUT "0\n";
		print STDERR "Problem with key $key\n";
		exit;
	}
	
	if ($value =~ /^".*"$/) {
		$value =~ s/^"//;		
		$value =~ s/"$//;		
	}
	elsif ($value =~ /^'.*'$/) 
	{
		$value =~ s/^'//;		
		$value =~ s/'$//;		
	}
	if ( ($value =~ /\W+/) || ($value =~ /\_/) || ($value eq "") )
	{
		print STDOUT "0\n";
		print STDERR "Problem with value $value\n";
		exit;
	}
	
	
	$hash{"$key"} = $value;
}

@ar_of_keys = keys %hash;
if ( !( scalar @ar_of_keys == 0 ))
{
	@ar_of_keys = sort @ar_of_keys;
	my $out_str = rep(-1,$first);
	print $out_str."\n";
}
else
{
	print $first."\n";
	print STDERR "Hash is empty\n";
}