#!/usr/bin/perl -w
use strict;
use Scalar::Util qw(looks_like_number);

($#ARGV == 0) or die "Missing file name";
my $test_file_path = $ARGV[0];

open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my $line;
my $width_matrixA;
my $height_matrixA;
my $width_matrixB;
my $height_matrixB;
my $n = 0;

my @matrixA;
my @matrixB;
my @matrixC;

while ($line = <FH>) {
        
        if ($line =~ /^\s*$/) { last }
        
        my @arr = split(/\s+/, $line);
        
        if($n == 0) { $width_matrixA = scalar(@arr) };
        $n++;
        
        if ($width_matrixA != scalar(@arr)) { printError("In the rows of a different number of elements"); exit 1 }
               
        foreach my $val(@arr) {
                if( !looks_like_number($val) ) { printError("Not number detected in matrix A"); exit 1; }
        }
        
        push(@matrixA, \@arr);
}
$height_matrixA = $n;


$n = 0;

while ($line = <FH>) {
        
        if ($line =~ /^\s*$/) { last }
        
        my @arr = split(/\s+/, $line);
        
        if($n == 0) { $width_matrixB = scalar(@arr) };
        $n++;
        
        if ($width_matrixB != scalar(@arr)) { printError("In the rows of a different number of elements"); exit 1 }
               
        foreach my $val(@arr) {
                if( !looks_like_number($val) ) { printError("Not number detected in matrix B"); exit 1; }
        }
        
        push(@matrixB, \@arr);
}
close(FH);

$height_matrixB = $n;
  
if ($width_matrixA != $height_matrixB) { printError("Matrices can not be multiplied"); exit 1 }

my $result = 0;

for my $i(0..$height_matrixA-1){
        my @res_arr;
        for my $j(0..$width_matrixB-1){
                for my $k(0..$width_matrixA-1){
                       $result = $result + $matrixA[$i][$k] * $matrixB[$k][$j];
                }
                push(@res_arr, $result);    
                $result = 0;
        }
        push(@matrixC, \@res_arr);
}

for my $i(0..$height_matrixA-1){
        print STDOUT "@{$matrixC[$i]}\n";
}

exit 0;


sub printError
{
        print STDOUT "ERROR\n";
        print STDERR "$_[0]\n";            
}
