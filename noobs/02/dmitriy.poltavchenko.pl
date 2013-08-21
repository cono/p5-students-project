#!/usr/bin/perl -w
use strict;

# use first argument of script as file name whith data
my $test_file_path = $ARGV[0];
# open file and get file handler or die
open(FH, "<", "$test_file_path") or die "Can not open test file: $!";
# read first line
my $str = <FH>;
# if empty line
if (! defined $str) {
    print "error\n";
    warn("empty line");
    exit -1;
} 
# if file has more lines
if (<FH>) { 
    warn("$test_file_path has more then 1 line data");
}
# replace spaces as one space character
$str =~ s/\s+/ /g;
# split string as array 
my @array = split(/[\s]/, $str);
# hash with resultat in future
my %values;
# write array in hash as keys and concat "*" symbol as count of word replays
$values{$_}.="*" foreach @array;
# temporaly buffer
my $buffer = "";
# prepare hash to output
foreach my $key ( sort keys %values ) { 
    # key validation
    my $tmp = $key;
    $tmp =~ s/[a-zA-Z0-9_\s]//g;
    # if key have unsupported symbols
    if ($tmp ne "") { # then inform
        print "error\n";
        warn("$key $values{$key} - unsupported symbols: \'$tmp\'");
        exit -2; # Broken file
    } else { # else show key and count of replays
        $buffer .= "$key $values{$key}\n";
    }
}
# flush buffer to STDOUT
print $buffer;
# close file handler
close ( FH );
# exit 
exit 0;
