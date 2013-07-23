#!/usr/bin/perl -w
use strict;

# первоначальные присвоения
my $test_file_path = $ARGV[0];
my @array = ('0'..'9','A'..'Z');
my %hash;
for (my $i = 0; $i< scalar @array; $i++)
{
	$hash{"$array[$i]"} = $i;
}

# из 10 в любую другую
sub ToAnother{
	my $d = $_[0];	my $o = $_[1];
	my $t = "";
	while (abs($d)>$o)
	{
		$t = DigToCh(abs($d)%$o).$t;		
		$d = int($d/$o);
	}	
	$t = DigToCh(abs($d)).$t;
	if ($d<0)
	{
		$t="-".$t;
	}
	return $t;
}	# ToAnother()
 
 # из любой в 10
 sub To10 {
        my $d = $_[0];
        my $o = $_[1];
        my @d = split(//,$d);
        my $r = 0;
        for (my $i = 0; $i < scalar @d; $i++)
        {
                if ( ($i == (scalar @d) - 1) and $d[(scalar @d) - 1 - $i] eq "-" )
                {
                        $r = -$r;
                }
                else{
					if ( ChToDig($d[(scalar @d) - 1 - $i]) >= $o )
					{
						return "Error";
					}
					else
					{
                        $r+=ChToDig($d[(scalar @d) - 1 - $i])*$o**$i;
					}
                }

        }
        return $r;
 } # To10()

 # Digit to char
 sub DigToCh{
	my $d = $_[0];
	return $array[$d];
 } #DigToCh
 
 # Char to digit
 sub ChToDig{
	my $c = $_[0];
	return $hash{$c};
 }
 
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) {

	chomp;
	uc; 
	my $a = undef;
	my $d = undef;
	my $o = undef;
	($a, $d, $o) = split (/,/,$_);
	
	if ($o>=2 && $o<=36)
	{
		if ($a==1)
		{	
			print STDOUT ToAnother($d,$o)."\n";
		}
		elsif ($a==2)
		{
			print STDOUT To10($d,$o)."\n";
		}
		else
		{
			print STDOUT "Error\n";
			print STDERR "Первое значение не равно ни 1, ни 2, a = $a\n";
		}
	}
	else
	{
		print STDOUT "Error\n";
		print STDERR "Неправильное значение основания, основание = $o\n";
	}
}

close ( FH );