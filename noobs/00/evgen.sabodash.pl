#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open(FH, "<", "$test_file_path");
my $c = 0;
my $dis = 0;
my $x1 = 0;
my $x2 = 0;

while (<FH>) {
        chomp;
        $a=undef; $b=undef; $c=undef;
        ($a,$b,$c) = split(/,/,$_);
        
        if ( ($a =~ /^[+-]?\d+$/ ) && ($b =~ /^[+-]?\d+$/ ) && ($c =~ /^[+-]?\d+$/ )  )
        {
			if ($a!=0)
			{
				$dis = $b*$b-4*$a*$c;
                if ($dis>0)
                {
                        $x1 = (-$b+sqrt($dis))/(2*$a);
                        $x2 = (-$b-sqrt($dis))/(2*$a);
                        print STDOUT "2 ($x1 $x2)\n";
                }
                elsif($dis==0)
                {
                        $x1 = (-$b)/(2*$a);
                        print STDOUT "1 ($x1)\n";
                }
                else
                {
                        print STDOUT "0\n";
                }
			}
			else
			{
				print STDOUT "Error\n";
			}
		}
        else
        {
            print STDOUT "Error\n";
        }
}
close(FH);