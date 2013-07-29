#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

$_ = <FH>;

{       
        unless ($_) {
                printError("Error. Input file contains a empty line\n");
                last;
        }
        
        chomp;
        $_ =~ s/^\s+|\s+$//g; #delete left and right spaces
        
        if (/[^\w\s]/) {
                printError("Error. Incorrect symbol in input line\n");   
                last;
        }
        
        my @arr = split(/\s+/, $_);
        
        if (scalar(@arr) == 0) {
                printError("Error. Input string contains only spaces symbols\n");   
                last;
        }
        
        my %freq;

        foreach my $val(@arr){
                if (exists $freq{$val}) {
                      $freq{$val}++;
                }
                else{
                       $freq{$val} = 1; 
                }   
        }
        
        foreach my $key(sort keys %freq){
                print STDOUT "$key ";
                print STDOUT "*" x ($freq{$key});
                print STDOUT "\n";
        }
}
close ( FH );


sub printError
{
        print STDOUT "error\n";
        print STDERR $_[0];            
}
