#!/usr/bin/perl -w
use strict;




my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my ($setdirect, $numeric, $notation, $newnum);
my $n_line = 0; #номер строки данных с ошибкой
my @alphabet =("0", "1", "2", "3", "4", "5", "6", "7", "8", 
				"9", "A", "B", "C", "D", "E", "F", "G", "H",
				"I", "J", "K", "L", "M", "N", "O", "P", "Q", 
				"R", "S", "T", "V", "U", "W", "X", "Y", "Z");



while ( <FH> ) {

	
	$_ =~ s/\s//g;
	$n_line++;
	($setdirect,$numeric,$notation) = split(/,/,$_,3);
	
	unless (defined $setdirect and defined $numeric and defined $notation and !($setdirect eq "") 
				and !($numeric eq "") and !($notation eq "") and ($setdirect <=2) and ($notation<=36) and ($notation>1)) #крайняя система исчесления - 37ая
	{
		print "Error\n";
		print STDERR "Line $n_line data file contains invalid data\n";

	}
	else
	{
		if ($setdirect == 1)
		{
			$newnum = "";
			while ($numeric > 0)
			{
				use integer;

				$newnum = $alphabet [($numeric%$notation)].$newnum;
				$numeric = $numeric/$notation;
			}
			
			print $newnum, "\n";
		}
		else
		{
			my $againsd = 1;
			$newnum = 0;
			while (length $numeric > 0)
			{
				my $l_num = chop $numeric;
				for (my $i = 0; $i < $notation; $i++)
				{
					if (uc $l_num eq $alphabet [$i])
					{
						$newnum = $newnum + $i * $againsd;
					}					
				}
				$againsd = $againsd * $notation;
			}
			print $newnum, "\n" ;
			
		}
	}

}
close ( FH );



