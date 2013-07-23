#!/usr/bin/perl -w
use strict;


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";



while ( <FH> )
{
	my($chose,$value,$base,$rest);
	my $result = undef;
	my @str = qw/0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z/;	
	chomp($_);
	($chose,$value,$base) = split(/,/,$_);
	
	if((!defined($chose))||(!defined($value))||(!defined($base))||($base>36)||($base < 2))
	{
		$result='Error';
	}
	else
	{
		$chose = int($chose);
		if($chose>2||$chose<1)
		{
			$result ='Error';
		}
		elsif($chose == 1)
		{

		#convert from 10 to N
			if($value>=0)
			{
				$rest = int($value%$base);
				$result ="";
				do
				{	
					$result=$str[$rest].$result;
					$value = int($value/$base);
					$rest = $value%$base;		
				}
				while($value >= $base);

				if($rest>0)
				{
					$result=$str[$rest].$result;
				}
			}
			else
			{
				$result='Error';
			}
		}
		elsif($chose==2)
		{	#convert from N to 10;
    		my @values = split(//,$value);
    		my @indexes;
    		my $symbol = undef;    	    	
    		for (my $ind = 0; $ind < scalar @values; $ind++) 
    		{    		    	
    			for (my $var = 0; $var < scalar @str; $var++) 
    			{
    				if($values[$ind] eq $str[$var])
    				{
    					$symbol = $var;
    				}    				
    			}
    			if(!(defined($symbol)))
    			{
    				$result ='Error';
    				@indexes = ();
    				last;
    			}
    			push(@indexes,$symbol);
    			$symbol = undef;
    		}   	
    		while(scalar @indexes>0)
    		{   my $valid = shift(@indexes);
    			if($valid>$base)
    			{
    				$result ='Error';
    				last;
    			}
    			$result += $valid*($base**(scalar @indexes));
    		}    	
		}
	}
	print STDOUT "$result\n";
	print STDERR "$result\n" if ($result eq 'Error');
}
close(FH);