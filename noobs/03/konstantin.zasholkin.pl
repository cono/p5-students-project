#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

{
  my $line1 = <FH>;
  if (defined($line1)) {
        chomp($line1);
  }
  else{
        printError("Input file contains a empty line 1");
        last;
  }

  my $line2 = <FH>;
  if (defined($line2)) {
        chomp($line2);
  }
  else{
        printError("Input file contains a empty line 2");
        last;
  }

  #check line1
  $line1 =~ s/^\s+|\s+$//g; #delete left and right spaces
  if ($line1 =~ /[^\w]/) {
        printError("Incorrect symbol in line 1");
        last;
  }
  
  #check line2
  if ($line2 !~ /^\s*\w+\s*\=\>\s*\w+\s*(\,\s*\w+\s*\=\>\s*\w+\s*)*$/) {
        printError("Incorrect format of line 2");
        last;
  }
  
  my @arr = split(/\s*\,\s*/, $line2);
  
  if (scalar(@arr) == 0) {
        printError("Input file contains a empty line 2");
  }
  
  my %pathHash;
  
  foreach my $val(@arr){
        (my $t1, my $t2) = split(/\s*\=\>\s*/, $val);
        $t1 =~ s/^\s+|\s+$//g; #delete left and right spaces
        $t2 =~ s/^\s+|\s+$//g;
        
        $pathHash{$t1} = $t2;
  }
        
        findpath($line1, %pathHash);
}
close ( FH );


sub findpath
{
  my ($start,%path)  = @_;

  my @elempath;

  if (!defined($path{$start})){
        print STDOUT $start;
        return;
  }
  
  print STDOUT "$start-";
  push(@elempath, $start);
  
  my $v = $path{$start};
  
  while (defined($path{$v})){
        if (keys(%path) != 1) {
                
                print STDOUT "$v-";
        }
        
        push(@elempath, $v);
        $v = $path{$v};
        
        if (grep( /^$v/, @elempath)) {
                print STDOUT "$v\n";
                print STDOUT "looped\n";
                return;
        }       
  }
  print STDOUT "$v\n";
}

sub printError
{
        print STDOUT "error\n";
        print STDERR $_[0];            
}
