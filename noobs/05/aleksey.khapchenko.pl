#!/usr/bin/perl -w
use strict;

package copy1 {
sub copy
{
    my ($from, $to) = (shift, shift);
    my $data;
    open (FROM, "<$from") or die "Could not open $from: $!";
    $data .= $_ while <FROM>;
    close FROM || return undef;
    
    open (TO, ">$to") or die "Could not create $to: $!";
    print TO $data;
    close TO || return undef;
    1;  
}
}
package del{
sub delete
{
    my $from = shift;
	unlink $from or die "Could not unlink $from: $!";
	1;  
}

}
package move{
sub move
{
    my ($from, $to) = (shift, shift);
    my $data;
    open (FROM, "<$from") or die "Could not open $from: $!";
    $data .= $_ while <FROM>;
	close FROM || return undef;
	unlink "$from" or die "Could not unlink $from: $!";
	open (TO, ">$to") or die "Could not create $to: $!";
    print TO $data;
    close TO || return undef;
    1;  
}
}

package mysh{
sub mysh {print "MySh::>";}
}

package printer{
sub print
 {
	my $fh = shift;
	open FILE, "<$fh" or die $!;
	while (<FILE>) { print; }
	close FILE || return undef;
	print "\n";
	1;
}
}
package search{
sub search
{
    my ($what, $where) = (shift, shift);
    my $data;
	my $count=0;
    open (WHERE, "<$where") or die "Could not open $where: $!\n";
    
	my @lines=<WHERE>;
	my $leng=@lines;
	for ($count=0;$count<$leng;$count++){
		#$lines[$count]=chomp ($lines[$count]);
		if ($lines[$count]=~/.*$what.*/){
			print STDOUT $lines[$count];
		}
	}
	close WHERE || return undef;
	1;
}
}
package sorter{
sub sort {
	my $from = shift;
	my $count=0;
	open LARGELIST, "<$from" or die $!;
	my @lines=<LARGELIST>;
	close LARGELIST || return undef;
	my @sorted = sort @lines;
	my $leng=@lines;
	open LARGELIST, ">$from" or die $!;
	for ($count=0;$count<$leng;$count++){
		#$lines[$count]=chomp ($lines[$count]);
		if ($sorted[$count]!~/\s$/){
			$sorted[$count]=$sorted[$count]."\n";
		}
		
		print LARGELIST $sorted[$count];
	#print STDOUT "$lines[$count]\n";
	}
	close LARGELIST || return undef;
	1;
}
sub man { 
	print STDOUT 'Rule is: sort example.txt'."\n";
}
}


my $a;		
my $temp=undef;
mysh::mysh();
$a=<STDIN>;
my $count =0;
	chomp $a;
do{
	
	my @tmp;
	my @array;
	@array = split(/ /,$a);
	if ($a=~s/ \|//) {
	@tmp = split(/ /,$a);
	@tmp = reverse @tmp;
	print @tmp;
	print "\n";
	
	$temp = $array[0];
	$array[0]=$tmp[$count];
	$count = $count+1;
	}

	if ($array[0]=~/copy/)
	{
		eval{
		copy1::copy("$array[1]", "$array[2]");
		}
		or do { print STDOUT "0\n"; 
        }
	}
	elsif ($array[0]=~/move/)
	{
		eval{
		move::move("$array[1]", "$array[2]");
		}
		or do { print STDOUT "0\n"; 
        }
	}
	elsif ($array[0]=~/delete/)
	{
		eval{
			del::delete("$array[1]");
		}
		or do { print STDOUT "0\n"; 
        }
	}
	elsif ($array[0]=~/sort/)
	{
		eval{
			sorter::sort($array[1]);
			}
		or do { print STDOUT "0\n"; 
        }
	}
	elsif ($array[0]=~/man sort/)
	{
		eval{
		sorter::man();
		}
		or do { print STDOUT "0\n"; 
        }
	}
	elsif ($array[0]=~/print/)
	{	
		eval{
		printer::print($array[1]);
		}
		or do { print STDOUT "0\n"; 
        }
	}
	elsif ($array[0]=~/search/)
	{
		eval{
		search::search($array[1], $array[2]);
		}
		or do { print STDOUT "0\n"; 
        }
	}
	
	elsif ($array[0]=~/exit/)
	{
		exit;
		
	}
	
	else {
		print STDOUT "0\n";
		print STDERR "$!";
		}
	if (defined $temp) {
	$array[0]=$temp;
	$temp=undef;
	
	}
	else {
	mysh::mysh();
	$a=<STDIN>;
	chomp $a;
	}
	
}while ($a ne "exit");


