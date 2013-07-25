#!/usr/bin/perl 

use strict;
use warnings;

my $file = shift;

die "Missed file name" unless ($file);

my @array = do {
    open(my $fh, '<', $file) or die "Can't open file: $!";
    split(/\s+/, <$fh>);
};

unless (scalar @array) {
    print "error\n";
    die "No data";
}

my %hash = ();
my $stars = '';

foreach my $word (@array) {
    if ($word !~ /^[a-zA-Z_0-9]+$/) {
        print "error\n";
        die "Wrong symbols";
    }
    $hash{$word}++; 
}

foreach my $word (sort keys %hash) {
    $stars = '*' x $hash{$word};
    print qq($word $stars\n);
}

1;
