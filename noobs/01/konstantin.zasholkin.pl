#!/usr/bin/perl -w
use strict;
use Scalar::Util qw(looks_like_number);

my @digittable = ('0'...'9', 'A'...'Z');

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) {
        my @arr = split(/,/, $_);
                
        if(scalar(@arr) != 3){
            print STDOUT "Error\n";
            print STDERR "Error in line $. of file tests.dat. Incorrect number of parameters\n";
            next;
        }
        
        my $direction = $arr[0];
        my $number = $arr[1];
        my $radix = $arr[2];
        
        if (!looks_like_number($direction) or !looks_like_number($radix)){
            print STDOUT "Error\n";
            print STDERR "Error in line $. of file tests.dat. First or third parameter is not a number\n";
            next;
        }
        
        if (($direction != 1) and ($direction != 2)) {
           print STDOUT "Error\n";
           print STDERR "Error in line $. of file tests.dat. Invalid first parameter (the expected value of only 1 or 2)\n";
           next;
        }

        if ($radix < 2 or $radix > 36) {
           print STDOUT "Error\n";
           print STDERR "Error in line $. of file tests.dat. Incorrect radix (expected from 2 to 36)\n";
           next;
        } 
        
        my $digit = 0;
        my $curres = $number;
        my $result = "";
        
        my $sign = 0; #positiv sign
        
        #System radix10 -> System radixN
        if ($direction == 1) {
            if (!looks_like_number($number)){
            print STDOUT "Error\n";
            print STDERR "Error in line $. of file tests.dat. Second parameter is not a number\n";
            next;
            }
            
            if ($number < 0) {
               $sign = 1; #negativ sign
               $number = abs($number);
            }
                        
            if ($number < $radix) {
                $result = $digittable[$number];
            }
            else{
                do{
                $digit = $curres % $radix;
                $curres = int($curres / $radix);
            
                $result = $digittable[$digit].$result;     
                } while ($curres>=$radix);
            
                $result = $digittable[$curres].$result;
                }
            
            if ($sign == 1) {
                $result = "-".$result;
            }
            
            print STDOUT $result."\n";    
        }

        #System radixN -> System radi10
        else {
            $result = 0;
            $number =~ s/\s+//g;
            my @arrnumber = split(//, $number);
            
            if ($arrnumber[0] eq "-") {
                $sign = 1; #negativ sign
                shift @arrnumber;
            }
            
            my $incorrect = 0;
            
            foreach my $val(@arrnumber){
                my $numeq = symb2num($val);
                if (($numeq >= $radix) or ($numeq == -1)) {
                print STDOUT "Error\n";
                print STDERR "Error in line $. of file tests.dat. Parameter contains incorrect digits\n";
                $incorrect = 1;
                last
                }
            }
            
            if ($incorrect == 1) {
                    next;
                }
                            
            my $n = 1;
            for(my $i=@arrnumber-1; $i>=0; $i--){
                $result = $result + symb2num($arrnumber[$i]) * $n;
                $n = $n * $radix;
            }
            
            if ($sign == 1) {
                $result = "-".$result;
            }
            print STDOUT $result."\n";
        }
    }
close ( FH );

sub symb2num{
    my $arg = uc($_[0]);
    
    if ((ord($arg) >= 48) and (ord($arg) <= 57)) { 
        $arg
    }
    elsif ((ord($arg) >= 65) and (ord($arg) <= 90)) {
        ord($arg)-55;
    }
    else{
        -1 #incorrect
    }
}
