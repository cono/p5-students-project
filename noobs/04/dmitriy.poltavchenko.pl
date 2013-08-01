#!/usr/bin/perl -w
use strict;

# use first argument of script as file name whith data
my $test_file_path = $ARGV[0];
# open file and get file handler or die
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $first_key = "";
my $str = "";
# line counter
my $count = 0;
# future hash
my %values; # original key - value for replace
my %tmphash; # key [#####] - value for replace
my $sharp; # [#####] delimetr
while (<FH>) {
    my $tmp = $_; # remove \s when needet
    # Remove new line character
    $tmp =~ s/\n//g;

    if ($count == 0 && !($tmp =~ m/\W/g) && $tmp ne "") { # if first step
        $first_key = $tmp; # set key
        $count++;
        next;
    } elsif ($count == 0) {
        print "0\n";
        warn("Error. No valid data - $tmp\n");
        exit -1;
    }
    
    $tmp =~ s/^\s+//g;
    # Remove comments
    $tmp =~ s/\s*#.*//g;
    
    # Skip empty line and comments
    if ($tmp =~ m/^#/ || $tmp =~ m/^\s*$/) {
        next;
    }
    
    if ($tmp =~ m/(.+)(=>|=)(.+)/ ) {
        my ($k, $v) = ($1, $3);
        $k =~ s/\s+$//;
        $k =~ s/^\s+//g;
        $v =~ s/\s+$//;
        $v =~ s/^\s+//g;
        # Remove "|' pair for key
        if ($k =~ m/^'(.+)'$/) {
            $k =~ s/^'//;
            $k =~ s/'$//;
        } elsif ($k =~ m/^"(.+)"$/) {
            $k =~ s/^"//;
            $k =~ s/"$//;
        }
        # Remove "|' pair for value
        if ($v =~ m/^'(.+)'$/) {
            $v =~ s/^'//;
            $v =~ s/'$//;
        } elsif ($v =~ m/^"(.+)"$/) {
            $v =~ s/^"//;
            $v =~ s/"$//;
        }
        # Validate key and value
        if ($k=~/\W/||$v=~/\W/) {
            print "0\n";
            warn("Error. Key or value missmath - $k=>$v\n");
            exit -2;
        }
        # fill hashes
        $values{$k} = $v;
        $sharp .= "#";
        $tmphash{$v} = $sharp;
        #print "$k\t=>\t$v\n";
    } elsif (!($tmp =~ m/^(\s*?)$/ || $tmp =~ m/^\s*\#.*+/)) {
        print "0\n";
        warn("Error. Data missmath - $tmp\n");
        exit -3;
    } # else comment or empty line
    $count++;
}

#if (scalar(keys %tmphash) < 1) {
#    print "0\n";
#    warn("Error. No hash found\n");
#    exit -4;
#}

# Replace keys as [#]..[##]
for my $key (sort {$b cmp $a} keys %values) {
    $first_key =~ s/$key/\[$tmphash{$values{$key}}\]/g;
}
# Replace [#]..[##] as values
for my $key (keys %values) {
    $first_key =~ s/\[$tmphash{$values{$key}}\]/$values{$key}/g;
}

print $first_key."\n";

exit 0;
