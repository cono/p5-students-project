#!/usr/bin/perl 

use strict;
use warnings;

my $file = shift;

die "Missed file name" unless ($file);
open(FH, '<', $file) or die "Can't open file: $!";

my @array = split(' ', <FH>);
my %hash = ();
my $stars = '';

foreach my $word (@array) {
  $hash{$word}++; 
}
 
foreach my $word (keys %hash) {
  $stars = '*' x $hash{$word};
  print qq($word $stars \n);
}

1;