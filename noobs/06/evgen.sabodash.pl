#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open (FH, "<", "$test_file_path") or die "Can not open test file: $!";

sub Trim { 
	$_[0] =~ s/^\s+//;
	$_[0] =~ s/\s+$//;
	return $_[0];
}
sub Err {
	my $Err = shift;
	print STDOUT "ERROR\n";
	print STDERR "$Err\n";
}

my @A;
my @B;
my $r = \@A;
my $fl_file_begin = 1;
while (<FH>){
	$_ = Trim($_);
	if ($_ eq ""){
		if ($fl_file_begin){
			$fl_file_begin = 0;
			$r = \@B;
			next;
		}
		else{
			last;
		}
	}
	my @t = split(/\s+/,$_);
	my @t1 = grep {$_=~/^[+-]?\d+[\.e]?\d*$/} @t; #проверка на число
	if ( scalar @t1!= scalar @t){
		Err("Not valid number");
		exit 1;
	}
	else{
		push(@{$r}, \@t1);
	}
}
if ( (scalar @A == 0) || (scalar @B == 0)){
	Err("Matrix is empty");
	exit 1;
}
my $t = scalar @{$A[0]};
foreach my $elem (@A){
	if ($t != scalar @{$elem}){
		Err("Not matrix");
		exit 1;
	}
}
$t = scalar @{$B[0]};
foreach my $elem (@B){
	if ($t != scalar @{$elem}){
		Err("Not matrix");
		exit 1;
	}
}

if (scalar @{$A[0]} != scalar @B){
	Err("Matrix multiplication is impossible");
	exit 1;
}

for (my $row = 0; $row < scalar @A; $row++){
	for (my $column = 0; $column < scalar @{$B[0]}; $column++){	
		$t = 0;
		for (my $i = 0; $i < scalar @B; $i++){
			$t += ($A[$row]->[$i]) * ($B[$i]->[$column]);
		}
		
		if ($column== (scalar @{$B[0]}) - 1){
			print "$t\n";
		}
		else{
			print "$t ";
		}
	}
}
exit 0;