#!/usr/bin/perl -w

sub recursiveDumper {
    my $node = $_[0];
    my $split = $_[1];
    my $ref = ref($node);

    if ($ref eq "") {
        print $split.$node;
    } elsif ($ref eq "ARRAY") {
        print "[\n";
        my $size = scalar(@{$node});
        for (my $i = 0; $i < $size; $i++) {
            #print $split.$node->[$i];
            if (ref($node->[$i]) eq "") {
                recursiveDumper("\'".$node->[$i]."\'", $split."\t");
            } else {
                recursiveDumper($node->[$i], $split."\t");
            }
            print "," if ($i+1 < $size);
            print "\n";
        }
        print $split."]";
    } elsif ($ref eq "HASH") {
        print "{\n";
        my $count = keys( $node );
        foreach my $key (sort keys $node) {
            if (ref($node->{$key}) eq "ARRAY") {
                print $split.$key." => ";
                recursiveDumper($node->{$key}, $split);
                
            } elsif (ref($node->{$key}) eq "HASH") {
                if ($key eq "ref_to_itself") {
                    print $split.$key." => HASH".",\n";
                    --$count;
                    next;
                }
                print $split.$key." => ";
                recursiveDumper($node->{$key}, "\t".$split);
            } elsif ($key eq "hash_obj" || $key eq "array_obj") {
                my $buff = $key." => ".$node->{$key}->get_struct();
                recursiveDumper($buff, $split);
                #print ",\n"; 
            }
            elsif (ref($node->{$key}) eq "") {
                my $buff = $key." => \'".$node->{$key}."\'";
                recursiveDumper($buff, $split);
                #print ",\n"; 
            } else {
                print $split.$key." => ";
                recursiveDumper($node->{$key}, "");
            }
            print "," if (--$count > 0);
            print "\n"; 
        }
        $split =~ s/\t//;
        print $split."}";
    } elsif ($ref eq "CODE") {
        print "CODE";
    } elsif ($ref eq "REF") {
        print "REF:";
        recursiveDumper($$node, $split."\t");
        #print $split.ref ($node->{$key})."\n";
    } elsif ($ref eq "SCALAR") {
        print "'scalar_variable'";
    } elsif ($ref eq "Regexp") {
        print "Regexp"."";
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
#print Dumper $$ptrname;
recursiveDumper($$ptrname, "\t");
print "\n";

exit 0;
