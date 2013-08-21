#!/usr/bin/perl -w
use strict;

# use first argument of script as file name whith data
my $test_file_path = $ARGV[0];
# open file and get file handler or die
open( FH, "<", "$test_file_path") or die "Missing file names";

my @arr1;
my @arr2;
my $flag = 0;
my $linecnt = 0;
my $first = 0;
while (<FH>) {
    chomp;

    if ($_ =~ m/^\s*$/ && $first == 0) {
        next;
    } elsif ($first == 0) {
        $first++;
        my @arrcount = split(/ /, $_);
        $linecnt = scalar(@arrcount);
    }
    
    if ($_ =~ m/^\s*$/) {
        $flag++;
        $first = 0;
        next;
    }

    my @tmparr = split(/ /, $_);

    if ($linecnt != scalar(@tmparr)) {
        print "ERROR\n";
        warn("Array width dissmatch\n");
        exit 1;
    }
    
    if ($flag == 0) {
        push(@arr1, \@tmparr);
    } elsif ($flag == 1) {
        push(@arr2, \@tmparr);
    } else {
        print "ERROR\n";
        warn("Array count > 2\n");
        exit 2;
    }
}

close ( FH );

# Check array ratio
if (scalar(@{$arr1[0]}) != scalar(@arr2)) {
    print "ERROR\n";
    warn("Arrays different\n");
    exit 3;
}

# Create empty array
my @res;
for (my $i = 0; $i < scalar(@arr1); $i++) {
    my @tmp;
    for (my $j = 0; $j < scalar(@{$arr2[0]}); $j++) {
        push(@tmp, 0);
    }
    push(@res, \@tmp);
}

# Multiplication matrix
for (my $i = 0; $i < scalar(@arr1); $i++) {
    for (my $j = 0; $j < scalar(@{$arr2[0]}); $j++) {
        my $sum = 0;
        for (my $k2 = 0, my $k1 = 0; $k2 < scalar(@arr2) 
            && $k1 < scalar(@{$arr1[0]}); $k2++, $k1++) {
            if ($arr1[$i]->[$k1] !~ /^([+-])?\d*(\.\d*)?([Ee]([+-]\d+))?$/
                || $arr2[$k2]->[$j] !~ /^([+-])?\d*(\.\d*)?([Ee]([+-]\d+))?$/) {
                print "ERROR\n";
                warn("Not a number in array: \'$arr1[$i]->[$k1]\' - \'$arr2[$k2]->[$j]\'\n");
                exit 4;
            }
            $sum += $arr1[$i]->[$k1] * $arr2[$k2]->[$j];
        }
        $res[$i]->[$j] = $sum;
        #print $sum ."\n";
    }
}

# Print array
foreach my $tmp(@res) {
    for (my $i = 0; $i < scalar(@$tmp); $i++) {
        print $tmp->[$i];
        if ($i + 1 < scalar(@$tmp)) {
            print " ";
        }
    }
    print "\n";
}

exit 0;
