#!/usr/bin/perl -w
use strict;


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";



while ( <FH> )
{
 my @bases;
 my $discr;
 my $result;
 my ($a,$b,$c);
 ($a, $b, $c) = split (/,/, $_);
 	if ((!defined($a))||(!defined($b))||(!defined($c)))
 	{
 		$result ='Error';
 	}

    elsif($a==0)
    {
        push(@bases,(-$b/$a));
    }
    else 
    {

	    $discr = $b**2-(4*$a*$c);
	    if($discr>=0)
	    {

			if($discr==0)
			{
				push(@bases,-$b/(2*$a));			
			}
			else
			{
				push(@bases,((-$b+sqrt($discr))/(2*$a)));
				push(@bases,(-$b-sqrt($discr))/(2*$a));
			}
			$result =scalar @bases." (@bases)";
		}
		else
		{
	     	$result ="0"; 
		}
 	} 	
 	
 	print STDOUT "$result\n";
 	print STDERR "$result\n" if ($result eq 'Error');
 
}

close(FH);