#!/usr/bin/perl -w
use strict;

my @matrix1 = ();
my @matrix2 = ();
my @matrix3 = ();

my $m1 = undef;
my $m2 = undef;

my $empty_line_count = 0;

my $test_file_path = $ARGV[0];
open (FH, "<", "$test_file_path") or die "Can not open test file: $!";

while (<FH>) {
	if(scalar @matrix1 == 0 && /^\s*$/) #если первая строка пустая или уже была одна пустая строка
	{
		print "ERROR\n";
		die ("First line is empty.\n");
	}
	if(/^\s*$/) #если есть пустая строка, то инкрементируем счетчик допустимыъ пропущенных строк
	{
		$empty_line_count++;
		if($empty_line_count>1)
		{
			last;
		}
		next;
	}
	$_ .=" ";
	if($_ !~ /^(\s*[-+]?(([0-9]*\.?[0-9]+)|([0-9]+\.))([eE][-+]?[0-9]+)?\s+)+$/)
	{
		print "ERROR\n";
		die ("Line has invalid symbols.\n");
	}
	if($empty_line_count == 0)
	{
		my $i = scalar@matrix1;
		push @matrix1, [split /\s+/, $_];
		if(${$matrix1[$i]}[0] eq '')
		{
			shift @{$matrix1[$i]};
		}
		if(!defined($m1))
		{
			$m1 = scalar @{$matrix1[$i]};
		}
		if($m1 != scalar @{$matrix1[$i]})
		{
			print "ERROR\n";
			die ("Lines have differend length.\n");
		}
	}
	else
	{
		my $i = scalar@matrix2;
		push @matrix2, [split /\s+/, $_];
		if(${$matrix2[$i]}[0] eq '')
		{
			shift @{$matrix2[$i]};
		}
		if(!defined($m2))
		{
			$m2 = scalar @{$matrix2[$i]};
		}
		if($m2 != scalar @{$matrix2[$i]})
		{
			print "ERROR\n";
			die ("Lines have differend length.\n");
		}
	}
}

close (FH);

if(scalar@matrix1 == 0 || scalar@matrix2 == 0)
{
	print "ERROR\n";
	die ("File is empty.\n");
}

if($m1 != scalar@matrix2)
{
	print "ERROR\n";
	die ("Matrix have invalid dimensions.\n");
}

#обработка
for(my $i = 0; $i<scalar @matrix1; $i++) {
	for (my $j = 0; $j < $m2; $j++) {
		for (my $r = 0; $r < $m1; $r++) {
			${$matrix3[$i]}[$j] += ${$matrix1[$i]}[$r] * ${$matrix2[$r]}[$j];
		}
	}
}

#результат
foreach (@matrix3)
{
	print "@{$_}\n";
}