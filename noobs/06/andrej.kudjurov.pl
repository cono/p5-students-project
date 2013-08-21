#!/usr/bin/perl

my $test_file_path = $ARGV[0];

if (open (FH, "<", "$test_file_path"))
{
	my @first=();
	my @second=();
	my $sec=0;
	my $l1=0;
	my $l2=0;
	while (<FH>)
	{
		$re=$_;
		my @line=();
		if (($re eq "\n") and (scalar(@first)!=0)){$sec=1;}
		elsif ((($re eq "\n") or ($re eq "")) and ($sec==1)){print STDOUT "ERROR\n"; die "unsuspected empty line\n";}
		elsif (($re eq "\n") and (scalar(@first)==0)){print STDOUT "ERROR\n"; die "unsuspected empty line\n";}
		@line=split(/\s+/g, $re);
		if ($re=~/[^\d\se\.-]/g){print STDOUT "ERROR\n"; die "NaN\n";}
		if ($re=~/-[^\de]/g){print STDOUT "ERROR\n"; die "Minus without digit\n";}
		if ($sec==0){push @first, \@line;}
		elsif ($re!="\n"){push @second, \@line;}
	}
	$l1=scalar(@{$first[0]});
	for (my $i=1;$i<scalar(@first);$i++){if (scalar(@{$first[$i]})!=$l1){print STDOUT "ERROR\n"; die "Not a matrix\n";}}
	$l2=scalar(@{$second[0]});
	for (my $i=1;$i<scalar(@second);$i++){if (scalar(@{$second[$i]})!=$l2){print STDOUT "ERROR\n"; die "Not a matrix\n";}}
	if ($l1==scalar(@second))
	{
		for (my $i=0;$i<scalar(@first);$i++)
		{
			my @tmp=();
			for (my $i1=0; $i1 < $l2; $i1++)
			{
				my $sum=0;
				for (my $i2=0; $i2 < $l1; $i2++)
				{
					$sum+=$first[$i]->[$i2]*$second[$i2]->[$i1];
				}
				push @tmp, $sum;
			}
			print "@tmp\n";
		}
	}
	else {print STDOUT "ERROR\n"; die "can't do this";}
}
else {print STDOUT "ERROR\n"; die "no such file\n";}