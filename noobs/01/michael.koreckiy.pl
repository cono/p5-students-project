#!usr/bin/perl -w
use strict;


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") || die "Can not open test file: $!";
my $res = "\n";
my $codeA = ord('A');
my @charArray = (0,1,2,3,4,5,6,7,8,9,'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z');

while ( <FH> ) {
	chomp();
	$res = "\n";
	$_ =~ s/\s*//g;
	if ($_ =~ m/[0]*[12],[^_\W]+,\d+/)
	{	
		
		my ($direction, $number, $notation) = split(/,/, $_);
		if (($notation > 1) && ($notation < 37))
		{
			$number = uc($number);
			my @symb = split(//, $number);
			my $size = @symb;
			if ($direction == 1)   #из десятичной
			{
				for (my $i = 0; $i < $size; $i++)
				{
					unless ($symb[$i] le $charArray[9])
					{
						$res = "Error\n";
						print STDERR "Error! Wrong 2-nd parameter!\n";
						last;
					}
				}
				unless ($res =~ m/Error/)
				{
					my $result = "\n";
					while ($number >= $notation)
					{
						my $temp = $number % $notation;
						$number = int ($number / $notation);
						$result =  $charArray[$temp].$res;
						$res = $result;
					}
					$res = $charArray[$number].$result;
				}
			}
			else   # в десятичную
			{
				for (my $i = 0; $i < $size; $i++)
				{
					unless ($symb[$i] le $charArray[$notation - 1])
					{
						$res = "Error\n";
						print STDERR "Error! Wrong 2-nd parameter!";
						last;
					}					
				}
				unless ($res =~ m/Error/)
				{
					my $result = 0;
					for (my $j = $size - 1; $j >= 0; $j--)
					{
						if (ord($symb[$j]) >= $codeA)
						{
							$result += (ord($symb[$j]) - $codeA + 10)* ($notation**($size - 1 - $j));
						}
						else
						{
							$result += $symb[$j] * ($notation**($size - 1 - $j));
						}
					}
					$res = "$result\n";
				}

			}
		} else
		{
			$res = "Error\n";
			print STDERR "Error! Wrong 3-rd parameter!\n";
		}
	}
   	else
	{
		$res = "Error\n";
		print STDERR "Error! Wrong format of entry data! ($_).\n";
	}

	print STDOUT "$res";
      #print STDERR "...\n" if ( $res eq 'Error' );
}
close ( FH );