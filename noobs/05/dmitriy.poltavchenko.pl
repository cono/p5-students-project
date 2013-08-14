#!/usr/bin/perl -w
use strict;
package MySh;
sub isReable {
    if (! -e $_[0]) {
        return -1;
    }
    if (! -r $_[0]) {
        return -1;
    }
    return 0;
}

sub isWritable {
    open(my $F, '>', "$_[0]") or return -1;
    close($F);
    if (! -w $_[0]) {
        return -1;
    }
    return 0;
}

sub readAll {
    my $fileContent;
    open(my $F, '<', "$_[0]") or die $!;
    binmode($F);
    {
        local $/;
        $fileContent = <$F>;
    }
    close($F);
    return $fileContent;
}

sub writeAll {
    my $fileContent;
    open(my $F, '>', "$_[0]") or die $!;
    binmode($F);
    print $F $_[1];
    close($F);
}

sub print {
    if (scalar(@{$_[0]}) == 1) {
        return -1;
    }
    
    my $count = 0;
    foreach my $file(@{$_[0]}) {
        next if ($count++ == 0);
        if (($file eq ">") && ($_[0]->[1] ne ">") &&
            $count == scalar(@{$_[0]})-1) {
            my $buff = join "", @{$_[1]};
            if (isWritable($_[0]->[$count]) ne "0") {
                return -1;
            }
            writeAll($_[0]->[$count], $buff);
            undef @{$_[1]};
            last;
        } elsif ($file eq ">") {
            return -2;
        }
        if (isReable($file) ne "0") {
            return -1;
        }
        open (INPUT,"<",$file) or return -1;
        while (<INPUT>) {
            push (@{$_[1]}, $_);
        }
        close(INPUT);
    }
    return 0;
}

sub delete {
    my $count = 0;
    undef @{$_[1]};
    if (scalar(@{$_[0]}) == 1) {
        return -2;
    }
    
    foreach my $file(@{$_[0]}) {
        next if ($count++ == 0);
        if (isWritable($file) ne "0") {
            return -1;
        }
        unlink $file or return -1;
    }    
    return 0;
}

sub move {
    undef @{$_[1]};    
    if (scalar(@{$_[0]}) == 3) {
        if (! rename ("$_[0]->[1]", "$_[0]->[2]")) {
            return -1;   
        }        
    } else {
        return -2;
    }
    return 0;
}

sub copy {
    undef @{$_[1]};
    if (scalar(@{$_[0]}) == 3) {
        if (isReable($_[0]->[1]) ne "0") {
            return -1;
        }
        my $tmp = readAll($_[0]->[1]);
        if (isWritable($_[0]->[2]) ne "0") {
            return -1;
        }
        writeAll($_[0]->[2], $tmp);
    } else {
        return -2;
    }
    return 0;
}

sub sort {
    if (scalar(@{$_[0]}) == 1 && scalar(@{$_[1]}) != 0) {
        @{$_[1]} = sort { $a cmp $b }@{$_[1]};
    } elsif (scalar(@{$_[0]}) == 2) {
        undef @{$_[1]};
        my $file = $_[0]->[1];
        if (isReable($file) ne "0") {
            return -1;
        }
        open (INPUT,"<",$file) or return -1;
        while (<INPUT>) {
            push (@{$_[1]}, $_);
        }
        close(INPUT);
        @{$_[1]} = sort { $a cmp $b }@{$_[1]};
    } elsif (scalar(@{$_[0]}) == 4 && ($_[0]->[2] eq ">")) {
        undef @{$_[1]};
        my $file = $_[0]->[1];
        if (isReable($file) ne "0") {
            return -1;
        }
        open (INPUT,"<",$file) or return -1;
        while (<INPUT>) {
            push (@{$_[1]}, $_);
        }
        close(INPUT);
        @{$_[1]} = sort { $b cmp $a }@{$_[1]};
        my $buff = join "", @{$_[1]};
        if (isWritable($_[0]->[3]) ne "0") {
            return -1;
        }
        writeAll($_[0]->[3], $buff);
        undef @{$_[1]};
    } else {
        return -2;
    }
    return 0;
}

sub search {
    if (scalar(@{$_[0]}) == 2 && scalar(@{$_[1]}) != 0) {
        @{$_[1]} = grep(/$_[0]->[1]/, @{$_[1]});
    } elsif (scalar(@{$_[0]}) == 3) {
        undef @{$_[1]};
        my $file = $_[0]->[2];
        if (isReable($file) ne "0") {
            return -1;
        }
        open (INPUT,"<",$file) or return -1;
        while (<INPUT>) {
            push (@{$_[1]}, $_);
        }
        close(INPUT);
        @{$_[1]} = grep(/$_[0]->[1]/, @{$_[1]});
    } elsif (scalar(@{$_[0]}) == 4 && ($_[0]->[2] eq ">")) {
        @{$_[1]} = grep(/$_[0]->[1]/, @{$_[1]});
        my $buff = join "", @{$_[1]};
        if (isWritable($_[0]->[3]) ne "0") {
            return -1;
        }
        writeAll($_[0]->[3], $buff);
        undef @{$_[1]};
    } elsif (scalar(@{$_[0]}) == 5 && ($_[0]->[3] eq ">")) {
        undef @{$_[1]};
        my $file = $_[0]->[2];
        if (isReable($file) ne "0") {
            return -1;
        }
        open (INPUT,"<",$file) or return -1;
        while (<INPUT>) {
            push (@{$_[1]}, $_);
        }
        close(INPUT);
        @{$_[1]} = grep(/$_[0]->[1]/, @{$_[1]});
        my $buff = join "", @{$_[1]};
        if (isWritable($_[0]->[4]) ne "0") {
            return -1;
        }
        writeAll($_[0]->[4], $buff);     
        undef @{$_[1]};
    } else {
        return -2;
    }
    return 0;
}

package main;

# function list
my %cmd = (
    "print" => \&MySh::print,
    "delete" => \&MySh::delete,
    "move" => \&MySh::move,
    "copy" => \&MySh::copy,
    "sort" => \&MySh::sort,
    "search" => \&MySh::search,
    "exit" => sub {exit 0},
);

# use first argument of script as file name whith data
my $test_file_path = $ARGV[0];
# open file and get file handler or die
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while (<FH>) {
    #$_ =~ s/\n//;
    chomp;
    print "MySh::>$_"."\n";
    $_ =~ s/\s+([>]+)/ $1 /;
    $_ =~ s/(^\s+)|(\s+\$)|([\s]{2,})/ /g;    
    my @array = split(/\s+\|\s+/, $_);
    my $counter = 0;
    my @tmp;
    foreach my $item(@array) {
        my @buff = split(/ /, $item);
        
        $_ = $item;
        
        if ($cmd{$buff[0]}) {
            my $status = $cmd{$buff[0]}->(\@buff, \@tmp);
            if ($status ne "0") {
                print "0\n";
                warn("Error code: $status in command: \'$item\'");
                last;
            } 
        } else {
            print "0\n";
            warn("Command not found");            
        }

        if (++$counter == scalar(@array)) {
            print @tmp;
        }
    }
}
print "MySh::>"."\n";

exit 0;
