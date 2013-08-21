#!/usr/bin/perl -w
#use strict;

sub def_varable {
}

#READING FILE
if ( @ARGV > 1 )  { print STDOUT "Too much arguments"; exit 1; }
if ( @ARGV == 0 ) { print STDOUT "Missing file names"; exit 1; }

my $todo_file   = shift;
my $todo_string = "";

open( FH, "<", $todo_file );
my $var_name = <FH>;
if ( $var_name =~ m/^\s*(\w+)\s*$/ ) {
	chomp( $var_name = $& );

}
else {
	$var_name = undef;
}
while (<FH>) {
	$todo_string .= $_;

}

close(FH);
${$var_name} = ();
eval($todo_string);
if($@){print STDERR "$@"; print STDOUT "ERROR"; exit 1;}
my $ref = $$var_name;
if(!($ref)){print STDOUT "ERROR"; die "Var name is not found";  }

use strict;
sub Dump {
	my $node   = shift;
	my $signes = shift;
	my $ref    = ref($node);

	if ( $ref eq 'REF' ) {
		print "REF:";
		&Dump( $$node, $signes ."\t" );
	}
	elsif ( $ref eq 'SCALAR' ) {
		print "'scalar_varible'";
	}
	elsif ( $ref eq '' ) {
		print $signes. $node;
	}
	elsif ( $ref eq 'ARRAY' ) {
		print "[\n";
		for ( my $i = 0 ; $i < @{$node} ; $i++ ) {
			if ( ref( $node->[$i] ) eq '' ) {
				&Dump( "\'".$node->[$i]."\'",$signes." " );
			}
			else { &Dump( $node->[$i], $signes . " " ); }
			if ( $i + 1 < @{$node} ) { print ","; }
			print "\n";
		}
		print $signes."]";
	}
	elsif ( $ref eq 'HASH' ) {
		print "{\n";
		my $numberOfKeys = keys $node;
		foreach my $key ( sort keys $node ) {
			if ( ref( $node->{$key} ) eq 'ARRAY' ) {
				print $signes. $key . " => ";
				&Dump( $node->{$key}, $signes );
			}
			elsif ( ref( $node->{$key} ) eq 'HASH' ) {
				if ( $key eq "ref_to_itself" ) {
					print $signes. $key . " => HASH" . ",\n";
					--$numberOfKeys;
					next;
				}
				print $signes. $key . "=> ";
				&Dump( $node->{$key}, "\t" . $signes );

			}
			elsif ( $key eq "hash_obj" || $key eq "array_obj" ) {
				my $temp = $key . " => " . $node->{$key}->get_struct();
				&Dump( $temp, $signes );

			}
			elsif ((ref ($node->{$key})) eq "") {
                my $temp = $key." => \'".$node->{$key}."\'";
                &Dump($temp, $signes);
            } else {
                print $signes.$key." => ";
                &Dump($node->{$key}, "");                
            }
            if (--$numberOfKeys>0){ print ",";}
            print "\n";
		}
		$signes =~ s/\t//;
		print $signes."}";
	}
	elsif(ref($node)eq 'CODE'){ print "CODE"; }
	elsif(ref($node)eq 'Regexp'){print "Regexp";}
}	
&Dump($ref,"\t");

