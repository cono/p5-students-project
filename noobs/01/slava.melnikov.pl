#!/usr/bin/perl -w
use strict;
 
my @symbols = ('0'..'9','A'..'Z');

sub base_check{	
        my $number = $_[0];
        my $base = $_[1];
        return undef if $base > 36;
	my $res = 1;        
        
        my @res;	
	foreach (split("",$number)) {
	    push @res, $_;
	}
        
        for(my $i = 0; $i < $#symbols+1; $i++) {
            for(my $j = 0; $j < $#res+1; $j++) {
		    if($res[$j] eq $symbols[$i]) {
			    if($i >= $base) {
				$res = undef;
                                last;
			    }
		    }
	    }
	}	
	return $res;
}

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

if ( -z "$test_file_path" ) {
   print STDOUT "Error\n";
}
else {
    while ( my $str = <FH> ) {    
        $str =~ s/\s*,\s*/,/g;
        $str =~ s/^\s*//g;
        $str =~ s/\s*$//g;
        $str = uc($str);
     
        my ($a, $b, $c) = split(",", $str);
        if (defined $a && defined $b && defined $c && $a ne "" && $b ne "" && $c ne "") {
            if ($a == 1) { 
                my $base_check = base_check($b,10);
                if ( $base_check == 1 ) {                
                            
                    my $num = $b;
                    my $base = $c;               
                                   
                    my $res1 = "";                        
                
                    do {
                        $res1 = $symbols[$num % $base] . $res1;
                        $num = int($num / $base);
                    } while ($num); 
                    print STDOUT "$res1\n"; 
                } else {
                    print STDOUT "Error\n"; 
                    print STDERR "Base's value error\n";
                }
            }
            elsif ($a == 2) {
                my $check_base = base_check($b,$c);
                if ( $check_base == 1 ) {
                    my $num  = $b;
                    my $base = $c;
                    my $res2 = 0;    
                    my %symbols = map { $symbols[$_] => $_ } 0..$#symbols;
                    for( split //, $num ){
                    $res2 *= $base;
                    $res2 += $symbols{$_};
                    }
                    print STDOUT "$res2\n";
                }
                else {
                    print STDOUT "Error\n";
                    print STDERR "Base's value error\n"; 
                }
            }
            else {
                print STDOUT "Error\n";
                print STDERR "Incorrect operation choosed\n";   
            }
            
        } else {
            print STDOUT "Error\n";
            print STDERR "There're undefined values\n";
        }
    }

    close ( FH );    
}


 
