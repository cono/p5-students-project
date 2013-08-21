#!/usr/bin/perl -w 
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or print "ERROR\n" and warn "Can not open test file: $!" and exit 1;
my (@matrix1, @matrix2);
my $match = 0;
my $elements = 0;
my $iter = 0;
while (<FH>) {
    chomp;
    if (/^\s*$/ && $iter == 0) {
        next;
    } elsif ($iter == 0) {
        $iter++;
        my @arrcount = split(/ /, $_);
        $elements = scalar(@arrcount);
    }
    if (/^\s*$/) {
        $match++;
        $iter = 0;
        next;
    }

    my @temp = split(/ /, $_);
	foreach my $temp(@temp){
		if ($temp!~/^([+-])?\d*(\.\d*)?([Ee]([+-]\d+))?$/){
			print "ERROR\n" and warn "No valid matrix element(s)" and exit 2;
			}
		}

    if ($elements != scalar(@temp)) {
        print "ERROR\n" and warn "No valid matrix(s) \n" and exit 3;
    }
    
    if ($match == 0) {
        push(@matrix1, \@temp);
    } elsif ($match == 1) {
        push(@matrix2, \@temp);
    } else {
        print "ERROR\n" and warn "More than 2 matrixs in test file\n" and exit 4;
		}
}
close (FH);
print "ERROR\n" and warn "Matrix(s) are not valid for multiplication\n" and exit 5 if (scalar(@{$matrix1[0]}) != scalar(@matrix2));
my @matrix3;
for (my $i = 0; $i < scalar(@matrix1); $i++) {
    my @mat3;
    for (my $j = 0; $j < scalar(@{$matrix2[0]}); $j++) {
        push(@mat3, 0);
		}
    push(@matrix3, \@mat3);
	}
for (my $i = 0; $i < scalar(@matrix1); $i++) {
    for (my $j = 0; $j < scalar(@{$matrix2[0]}); $j++) {
        my $skalar_sum = 0;
        for (my $k2 = 0, my $k1 = 0; $k2 < scalar(@matrix2) && $k1 < scalar(@{$matrix1[0]}); $k2++, $k1++) {
            $skalar_sum += $matrix1[$i]->[$k1] * $matrix2[$k2]->[$j];
        }
        $matrix3[$i]->[$j] = $skalar_sum;
        }
	}
foreach my $item(@matrix3) {
    for (my $i = 0; $i < scalar(@$item); $i++) {
        print $item->[$i];
        if ($i+1 < scalar(@$item)) {
            print " ";
        }
    }
    print "\n";
}

exit 0;