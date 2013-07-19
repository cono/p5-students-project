#!/usr/bin/perl 

use strict;
use warnings;

my $file = shift;

die "Missed file name" unless ($file);
open(FH, '<', $file) or die "Can't open file: $!";

my $first = <FH>;
chomp($first);

my $line = <FH>;
chomp($line);

close(FH);

my %hash = split(/\s*(?:=>|,)\s*/, $line);

while (my ($key, $value) = each %hash) { 
  if (!defined($key) || !defined($value)) {
    print "error\n";
    die "Odd number of elements in hash";
  }
  elsif ($key !~ /\w*,\d*/ || $value !~ /\w*,\d*/) {
    print "error\n";
    die "Invalid key or value";
  }
}

my %cycle = ($first => 1);

my $current = $first;
print "$current";

while (exists $hash{$current}) {
  print "-$hash{$current}";
  $cycle{$current} = 1;
  $current = delete $hash{$current};
}

print "\n";
print "looped\n" if exists $cycle{$current};

1;