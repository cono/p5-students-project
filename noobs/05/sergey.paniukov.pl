#!/usr/bin/perl -w
use strict;
package MySh;
sub reading {
    my $fileContent;
    open(my $F, '<', "$_[0]") or warn "Can`t open $_[0] for reading\n" and next;
    binmode($F);
    {
        local $/;
        $fileContent = <$F>;
    }
    close($F);
    return $fileContent;
}
sub writing {
    my $fileContent;
    open(my $F, '>', "$_[0]") or warn "Can`t open $_[0] for writing\n" and next;
    binmode($F);
    print $F $_[1];
    close($F);
    return $fileContent;
}
sub print {
    if (scalar(@{$_[0]}) == 1) {
        print "0\n"or warn "No print parameter\n" and next;
    }
    my $count = 0;
    foreach my $file(@{$_[0]}) {
        next if ($count++ == 0);
        if (($file eq ">") && ($_[0]->[1] ne ">") && $count == scalar(@{$_[0]})-1) {
            my $buff = join "", @{$_[1]};
            writing($_[0]->[$count], $buff);
            undef @{$_[1]};
            last;
        } elsif ($file eq ">") {
            print "0\n";
            print "0\n"or warn "Not valid use of '>'\n" and next;
        }
        open (INPUT,"<",$file) or warn "Unable to open $file: $!\n" and next;
        while (<INPUT>) {
            push (@{$_[1]}, $_);
        }
        close(INPUT);
    }
}
sub delete {
    my $iter = 0;
	undef @{$_[1]};
	my @arr=@{$_[0]};
	unlink $arr[1] and next or print STDOUT "0\n" and warn "Can`t delete file: $!" and next;
}
sub move {
    undef @{$_[1]};
    if (scalar(@{$_[0]}) == 3) {
        if (! rename ("$_[0]->[1]", "$_[0]->[2]")) {
            print "0\n"or warn "Can`t move file: $!" and next;       
        }        
    } else {
        print "0\n"or warn "Not valid parameter(s) for move" and next;
    }
}
sub copy {
    undef @{$_[1]};
    if (scalar(@{$_[0]}) == 3) {
        my $tmp = reading($_[0]->[1]);
        writing($_[0]->[2], $tmp);
    } else {
        print "0\n" and warn "Not valid parameters for copy\n" and next;
    }
}
sub sort {
		my @arr = @{$_[0]};
		if (scalar(@{$_[0]}) == 1 && scalar(@{$_[1]}) != 0){
			@{$_[1]} = sort { $a cmp $b }@{$_[1]};
		}
		elsif (scalar(@{$_[0]}) == 2){
			undef @{$_[1]};
			my $file = $_[0]->[1];
			open (INPUT,"<",$file) or warn "Can`t open $file: $!" and next;
			while (<INPUT>) {
			push (@{$_[1]}, $_);
			}
			close(INPUT);
			@{$_[1]} = sort { $a cmp $b }@{$_[1]};
		} 
		elsif (scalar(@{$_[0]}) == 4 && ($_[0]->[2] eq ">")) {
			undef @{$_[1]};
			my $file = $_[0]->[1];
			open (INPUT,"<",$file) or warn "Can`t open $file: $!" and next;
			while (<INPUT>) {
            push (@{$_[1]}, $_);
        }
			close(INPUT);
			@{$_[1]} = sort { $a cmp $b }@{$_[1]};
			my $buff = join "", @{$_[1]};
			writing($_[0]->[3], $buff);
			undef @{$_[1]};
		}
		else{		
		print "0\n" and  warn "Not valid parameter(s) for sort\n" and next;
		}
	}
sub search {
    if (scalar(@{$_[0]}) == 2 && scalar(@{$_[1]}) != 0) {
        @{$_[1]} = grep(/$_[0]->[1]/, @{$_[1]});
    } elsif (scalar(@{$_[0]}) == 3) {
        undef @{$_[1]};
        my $file = $_[0]->[2];
        open (INPUT,"<",$file) or warn "Can`t open $file: $!\n" and next;
        while (<INPUT>) {
            push (@{$_[1]}, $_);
        }
        close(INPUT);
        @{$_[1]} = grep(/$_[0]->[1]/, @{$_[1]});
    } elsif (scalar(@{$_[0]}) == 5 && ($_[0]->[3] eq ">")) {
        undef @{$_[1]};
        my $file = $_[0]->[2];
        open (INPUT,"<",$file) or warn "Can`t open $file: $!\n" and next;
        while (<INPUT>) {
            push (@{$_[1]}, $_);
        }
        close(INPUT);
        @{$_[1]} = grep(/$_[0]->[1]/, @{$_[1]});
        my $buff = join "", @{$_[1]};
        writing($_[0]->[4], $buff);     
        undef @{$_[1]};
    } else {
        print "0\n" or warn "Not valid parameter(s) of search\n" and next;
    }
}
package main;
my %cmd = (
    "print" => \&MySh::print,
    "exit" => sub {exit 0},
    "delete" => \&MySh::delete,
    "move" => \&MySh::move,
    "copy" => \&MySh::copy,
    "sort" => \&MySh::sort,
    "search" => \&MySh::search,
);
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
while (<FH>) {
    chomp;
	if ($_ eq ''||/^\s+$/){
	next;
	}
    print "MySh::>$_\n";
    $_ =~ s/\s+([>]+)/ $1 /;
    $_ =~ s/(^\s+)|(\s+\$)|([\s]{2,})/ /g;    
    my @array = split(/\s+\|\s+/, $_);
    my $counter = 0;
    my @tmp;
    foreach my $item(@array) {
        my @buff = split(/ /, $item);
        $_ = $item;
        my $streamcnt += s/ >//g;
        if ($streamcnt > 1) {
            print "0\n" and warn "Not valid use of '>'\n" and next;
        }
        if ($cmd{$buff[0]}) {
            $cmd{$buff[0]}->(\@buff, \@tmp);
        } else {
            print "0\n" and warn "No comand" and next;            
        }
        if (++$counter == scalar(@array)) {
            print @tmp;
        }
    }
}

print "MySh::>\n" and warn "Not valid comand file or last comand\n" and exit 0;
