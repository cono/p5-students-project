#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my %replace_hash;

my $replace_str = <FH>;
#check replace string
{
  if (defined($replace_str)) {
    chomp($replace_str);
  }
  else{
    printError("Input file is empty");
    finalise();
  }
  
  if ($replace_str =~ /^\s*$/) {
    printError("Replace string is empty");
    finalise();
  }

  if ($replace_str =~ /\W/) {
    printError("Incorrect symbol in replace string");
    finalise();
  }
}

#read and check replace hash
while (my $hash_str = <FH>) {
  #check empty line
  if ($hash_str =~ /^\s*$/) {
    next;
  }
  
  #check comment line
  if ($hash_str =~ /^\s*\#/) {
    next;
  }

  if ($hash_str !~ /^\s*(|"|')(\w+)\g{-2}\s*=>?\s*(|"|')(\w+)\g{-2}\s*$/) {
    printError("Incorrect hash-string format");
    finalise();
  }
  else{   
    $replace_hash{$2} = $4; #add replace strig to hash
  }
}

if(scalar (keys %replace_hash) == 0){
  print STDOUT "$replace_str\n";
  finalise();
}

my @array_key = sort {$b cmp $a} keys %replace_hash;

my $replace_source = join("|", @array_key);

$replace_str =~ s/$replace_source/$replace_hash{$&}/go;

print STDOUT "$replace_str\n";

finalise();


sub printError
{
  print STDOUT "0\n";
  print STDERR "$_[0]\n";            
}

sub finalise
{
  close(FH);
  exit;
}