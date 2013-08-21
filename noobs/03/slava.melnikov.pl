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
if ($lines>2) {
   #print STDOUT "error\n";
   print STDERR "More than 2 lines in file\n";
   #exit(1);
}

while (my @str = <FH> ) {
   my $match=1;
   chomp($str[0]);
   chomp($str[1]);
   if ( $str[0] =~ m/[^a-zA-Z_0-9\s]{1}/ ) {
      ++$match;
   }
   if ($str[0] eq "") {
      ++$match;
   }     
   if (length $str[0] == 0) {
      ++$match;
   }
      
   if ($str[1] =~ m/[^a-zA-Z_0-9\s=>,]{1}/ ) {
      ++$match;
   }
   if ($str[1] eq "") {
      ++$match;
   }
   if (length $str[1] == 0) {
      ++$match;
   }
      
   if ($match > 1) { 
      print STDOUT "error\n";
      print STDERR "invalid data format\n";
      exit(1);
   }
   else {      
      
      my $enter_point;
      my $err_razd = 1;
      $str[0] =~ s/^\s*//g;
      $str[0] =~ s/\s*$//g;
      $enter_point = $str[0];
      
      $str[1] =~ s/\s*,\s*/,/g;
      $str[1] =~ s/\s*\=\>\s*/\=>/g;      
      $str[1] =~ s/^\s*//g;
      $str[1] =~ s/\s*$//g;    
      
      
      my $testing;
      while ($str[1] =~ m/[\w\d]+(\=\>){1}[\w\d]+\,?/g) {
         $testing = $testing.$&;
      }
      
      if (length($testing)!=length($str[1])) {
         print STDOUT "error\n";
         print STDERR "invalid hash string formating\n";
         exit(1);
         
      }
      
      
      if ( $str[1] =~ m/\,$/ ) {
         print STDOUT "error\n";
         print STDERR "no values after ,\n";
         exit(1);
      }
     
      $str[1] =~ s/\=>/\=/g;     
      my %hash = split(/[=,]/,$str[1]);        
      
      while (my ($key,$value) = each %hash) {
         if ($key eq "" || $value eq "") {
            print STDOUT "error\n";
            print STDERR "Key or value is empty\n";
            exit(1);
            }              
      }
            
      my $k = "";
      $k = $enter_point;
      my $bool = 1;
      my $temp;
      my $res = "";      
      my @keys = keys %hash;
      my @values = values %hash;
            
      my @passed;
      
      unless ($k ~~ @keys) {
         print STDOUT "error\n";
         print STDERR "no entry point in hash\n";
         exit(1);
      }
         
      for (my $i = 0; $i<keys %hash;$i++) {
         if ($k ~~ @keys) {
            $temp = $k;
            $res = $res.$temp."-";
            $k = $hash{$temp};
            push (@passed,$temp);
         }
         else {
            print STDOUT $res.$k;            
            print STDERR "There's no such key\n";
            exit(1);
         }
         if ($k ~~ @passed) {                 
            $bool=2;
            last;
         }  
      }
        
      if ($bool == 1) {
         print STDOUT $res.$k;
      }
      else {
         $res=$res.$k;
         print STDOUT "$res\n"."looped\n";         
      }   
   }      
}

close ( FH );  








































