#!/usr/bin/perl 

use strict;
use warnings;

my $file = shift;

die "Missed file name" unless ($file);

my @array = do {
    open(my $fh, '<', $file) or die "Can't open file: $!";
    split(/\s+/, <$fh>);
};
my %hash = ();
my $stars = '';

foreach my $word (@array) {
  $hash{$word}++; 
}
 
foreach my $word (sort keys %hash) {
  $stars = '*' x $hash{$word};
  print qq($word $stars\n);
}

1;
