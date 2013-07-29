#!/usr/bin/perl -w
use strict;

# use first argument of script as file name whith data
my $test_file_path = $ARGV[0];
# open file and get file handler or die
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $first_key = "";
my $str = "";
# line counter
my $count = 0;
while (<FH>) {
    if ($count++ < 2) { # if 1 or 2 line
        my $tmp = $_; # remove \s when needet
        $tmp =~ s/\s*,\s*/,/g;
        $tmp =~ s/^\s*//g;
        $tmp =~ s/\s*$//g;
        if ($count == 1) { # if first step
            $first_key = $tmp; # set key
        } else { # else set string whith hash
            $str = $tmp;
        }
    } else { # if file has more line
        warn("$test_file_path has more then 2 line data");
        last;
    }
}
# if read data empty
if ("" eq $first_key || "" eq $str) {
    print "error\n";
    warn("$test_file_path has less then 2 line data");
    exit -1;
}
# close file handler
close ( FH );

# future hash
my %values;
# split string as array 
my @array = split(/,/, $str);
# fill hash key-values from array 
foreach my $item(@array) {
    my $l_idx = index($item, "=>");
    if ($l_idx == -1) {
        print "error\n";
        warn("String separator not found - [$item]");
        exit -2;
    }

    $l_idx = index($item, "=>", $l_idx+1);
    if ( $l_idx != -1) {
        print "error\n";
        warn("String separator more then one");
        exit -3;
    }
    
    my ($i,$j)= split(/=>/, $item);
    if ($i eq "" || $j eq "") {
        print "error\n";
        warn("Empty key or value - [$i] => [$j]");
        exit -4;
    } else {
        my ($tmp_i, $tmp_j) = ($i, $j);
        $tmp_i =~ s/[a-zA-Z0-9]//g;
        $tmp_j =~ s/[a-zA-Z0-9]//g;
        if ($tmp_i ne "" || $tmp_j ne "") {
            print "error\n";
            warn("Unsupported symbols - [$tmp_i$tmp_j]");    
            exit -5;
        }
    }
    $values{$i} = $j;
}
# processing ...
print $first_key;
my $prev = $values{$first_key};
while (){
    if ( ! exists $values{$prev}) {
        print "-$prev";
        last;
    }
    print "-$prev";
    $prev = $values{$prev};
    if ($prev eq $first_key) {
        print "-$prev\nlooped";
        last;
    }
}
print "\n";
# exit 
exit 0;
