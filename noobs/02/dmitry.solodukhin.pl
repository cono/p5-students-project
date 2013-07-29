#!/usr/bin/perl -w
use strict;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
$_ = <FH>;
my %result;
eval {
  die "Error Bad data in test file \n" if(!$_);
  die "Error Bad data in test file \n" if((index($_, /[^A-Za-z0-9_\s]/)) || ($_ eq defined));
  $_ =~ s/\s{2,}/ /g;
  my @a = split(" ") or die "Error no valid data \n";
  die "Error no valid data\n" if(@a eq 0);
  $result{$_}++ for @a;
  die "Error no valid data\n" if(%result eq 0);
};
if ($@){
    print STDERR $@;
}else{
    print STDOUT "$_ "."*" x $result{$_}."\n" for sort keys %result;
};