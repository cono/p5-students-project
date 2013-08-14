#!/usr/bin/perl -w

sub recursiveDumper {
    my $node = $_[0];
    my $split = $_[1];
    my $used = $_[2];
    my $ref = ref($node);

    if (defined $node) {    
        for (my $i=0; $i < scalar(@{$used}); $i++) {
            if (@{$used}[$i] eq $node) {
                print $ref;
                return;
            }
        }
        push(@{$used}, $node);
    }
    
    if (not defined $node) {
        print "''";
    } elsif ($ref eq "") {
        print "'".$node."'";
    } elsif ($node =~ m/(.*)=(.*)/) {
        print $node->get_struct();
    } elsif ($ref eq "ARRAY") {
        print "[\n";
        my $size = scalar(@{$node});
        for (my $i = 0; $i < $size; $i++) {
            if (ref($node->[$i]) eq "") {
                print $split;
                recursiveDumper($node->[$i], $split, $used);
            } else {
                print $split;
                recursiveDumper($node->[$i], $split."\t", $used);
            }
            print "," if ($i+1 < $size);
            print "\n";
        }
        $split =~ s/\t//;
        print $split."]";
    } elsif ($ref eq "HASH") {
        print "{\n";
        my $count = keys( $node );
        foreach my $key (sort keys $node) {
            if (ref($node->{$key}) eq "") {
                my $buff = $split.$key." => \'".$node->{$key}."\'";
                print $buff;
            } else {
                print $split.$key." => ";
                recursiveDumper($node->{$key}, $split."\t", $used);
            }
            print "," if (--$count > 0);
            print "\n"; 
        }
        $split =~ s/\t//;
        print $split."}";
    } elsif ($ref eq "SCALAR") {
        print "'$$node'";
    } elsif ($ref eq "REF") {
        print "REF:";
        recursiveDumper($$node, $split, $used);
    } else { # CODE, Regexp, GLOB, LVALUE, FORMAT, IO, VSTRING
        print $ref;
    }
}

# use first argument of script as file name whith data
my $test_file_path = $ARGV[0];
# open file and get file handler or die
open( FH, "<", "$test_file_path") or die "Missing file names";
my $ptrname;
my $code;
my $first = 0;
while (<FH>) {
    if ($first == 0) {
        $first++;
        chomp;
        $ptrname = $_;
        next;
    } 
    $code .= $_;
}
eval($code);
if ($@) {
    print "ERROR\n";
    warn("$@");
    exit 1;
}

#recursiveDumper([1,undef,3,{1 => 2, 3 => 3},5,6], "\t", []);
recursiveDumper($$ptrname, "\t", []);
print "\n";

exit 0;
