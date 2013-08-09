#!/usr/bin/perl -w

sub Dump {
    my $node = $_[0];
    my $split = $_[1];
    my $reference = ref($node);

    if ($reference eq "") {
        print $split.$node;
    } elsif ($reference eq "ARRAY") {
        print "[\n";
        my $size = scalar(@{$node});
        for (my $i = 0; $i < $size; $i++) {
            if (ref($node->[$i]) eq "") {
                Dump("\'".$node->[$i]."\'", $split."\t");
				}
				else {
                Dump($node->[$i], $split."\t");
				}
				print "," if ($i+1 < $size);
				print "\n";
			}
			print $split."]";
    } elsif ($reference eq "HASH") {
        print "{\n";
        my $count = keys( $node );
        foreach my $key (sort keys $node) {
            if (ref($node->{$key}) eq "ARRAY") {
                print $split.$key." => ";
                Dump($node->{$key}, $split);
                
            } elsif (ref($node->{$key}) eq "HASH") {
                if ($key eq "ref_to_itself") {
                    print $split.$key." => HASH".",\n";
                    --$count;
                    next;
                }
                print $split.$key." => ";
                Dump($node->{$key}, "\t".$split);
            } elsif ($key eq "hash_obj" || $key eq "array_obj") {
                my $buff = $key." => ".$node->{$key}->get_struct();
                Dump($buff, $split);
            }
            elsif (ref($node->{$key}) eq "") {
                my $buff = $key." => \'".$node->{$key}."\'";
                Dump($buff, $split);
                #print ",\n"; 
            } else {
                print $split.$key." => ";
                Dump($node->{$key}, "");
            }
            print "," if (--$count > 0);
            print "\n"; 
        }
        $split =~ s/\t//;
        print $split."}";
    } elsif ($reference eq "CODE") {
        print "CODE";
    } elsif ($reference eq "REF") {
        print "REF:";
        Dump($$node, $split."\t");
    } elsif ($reference eq "SCALAR") {
        print "'scalar_variable'";
    } elsif ($reference eq "Regexp") {
        print "Regexp"."";
    }
}
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or print "ERROR\n" and die "Can`t open test file!";
my $patern_name;
my $test_code;
my $first = 0;
while (<FH>) {
    if ($first == 0) {
        $first++;
        chomp;
        $patern_name = $_;
        next;
    } 
    $test_code .= $_;
}
eval($test_code);
if ($@) {
    print "ERROR\n" and warn "$@" and exit 1;
}
Dump($$patern_name, "\t");
print "\n";

exit 0;