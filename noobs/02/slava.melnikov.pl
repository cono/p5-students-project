#! /usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $lines;


if ( -z "$test_file_path" ) {
   print STDOUT "error\n";
   print STDERR "File is empty\n";
   exit(1);
}

LINE: while (defined($_ = <ARGV>)) {
    $lines++;
}
if ($lines>1) {
   #print STDOUT "error\n";
   print STDERR "More than 1 line in file\n";
   #exit(1);
}



while (my @str = <FH> ) {
        
   my $match = 1;
   chomp($str[0]);
   if ($str[0] eq "") {
      ++$match;
   }         
   if (length $str[0] == 0) {
      ++$match;
   }        
   if ($str[0] =~ m/[^a-zA-Z_\s0-9]{1}/) {
      ++$match;
   }
        
        
   if ($match > 1) {
      print STDOUT "error\n";
      print STDERR "Invalid data format\n";
   }
   else {
      my %hash;
      $str[0] =~ s/^\s*//g;
      $str[0] =~ s/\s*$//g;            
            
      my @stroki = split(/\s+/,$str[0]);
            
      $hash{$_}++ for @stroki; 
    
      while (my ($key,$value) = each %hash) {
         $hash{$key} = "*"x"$value";       
      }
            
      foreach my $key(sort (keys(%hash))) {    
         print STDOUT"$key $hash{$key}\n";
         delete $hash{$key};
      }
   }
}
    
close ( FH );        



















