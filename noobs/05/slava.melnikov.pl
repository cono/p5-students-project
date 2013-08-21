#! /usr/bin/perl -w
use strict;
use File::Copy;

package ShellTask;
sub print {    
    if (defined $_[0] && $_[0] ne "") {
        my $file = $_[0];
        chomp($file);
        if (open( FH, "<", "$file")) {            
            my @res  = <FH>;        
            chomp($res[$#res]);
            close (FH);
            return "MySh::>print $file\n",@res,"\n";
        } else { print STDOUT "0\n"; print STDERR "Print operation failed. File $file does not exist\n"; return; }
    }
    else { print STDOUT "0\n"; print STDERR "Print func has no parameter\n"; return; }    
}

sub copy {
    if (defined $_[0] && defined $_[1] && $_[0] ne "" && $_[1] ne "") {
        my $from = $_[0]; my $to = $_[1];
        chomp($from); chomp($to);
        if (-e $from) {
            File::Copy::copy($from,$to);
            return;
        }
        else { print STDOUT "0\n"; print STDERR "Copy operation failed. File $from does not exist\n"; }
    }
    else { print STDOUT "0\n"; print STDERR "Not enough parameters for copy func\n";  }
}

sub move {    
    if (defined $_[0] && defined $_[1] && $_[0] ne "" && $_[1] ne "") {
        my $from = $_[0]; my $to = $_[1];
        chomp($from); chomp($to);
        if (-e $from) {
            File::Copy::move($from,$to);
            return;
        }
        else { print STDOUT "0\n"; print STDERR "Move operation failed. File $from does not exist\n"; }
    }
    else { print STDOUT "0\n"; print STDERR "Not enough parameters for move func\n"; }
}

sub delete {    
    if (defined $_[0] && $_[0] ne "") {
        my $file = $_[0]; chomp($file);
        if (-e $file) {
            unlink($file);
            return;
        }
        else { print STDOUT "0\n"; print STDERR "Delete operation failed. File $file does not exist\n"; }        
    }
    else { print STDOUT "0\n"; print STDERR "Delete func has no parameter\n"; }  
}

sub sort {    
    if (defined $_[0] and $_[0] ne "") {
        my $par1 = $_[0]; chomp($par1);
        my @new;        
        if (open( FH, "<", "$par1")) {            
            while (my $str = <FH>) {
                chomp($str);
                my @temp = split(//,$str);
                my @temp2 = sort {$a cmp $b} @temp;
                my $sorted = join ('',@temp2);
                push (@new,$sorted."\n");
            }
            chomp($new[$#new]);        
            close (FH);
            if (open( FH, ">", "$par1")) {                
                print FH @new;
                close (FH);        
                return "MySh::>sort $par1\n",@new,"\n";
            } else { print STDOUT "0\n"; print STDERR "Can not open $par1 file\n"; return; }
        } else { print STDOUT "0\n"; print STDERR "Can not open $par1 file\n"; return; }
    }
    elsif (undef $_[0]) {
        
    }
    else { print STDOUT "0\n"; print STDERR "Sort func has no parameter\n"; return; }
}

sub search { 
    if (defined $_[0] && defined $_[1] && $_[0] ne "" && $_[1] ne "") {
        my $text = $_[0]; my $file = $_[1];
        chomp($text); chomp($file);
        my @data; my @res;
        if (open( FH, "<", "$file")) {
            @data = <FH>;        
            my $ind = 0;
            foreach (@data) {
                if ($data[$ind] =~ m/$text/g) {
                    push(@res,$data[$ind]);
                }
                $ind++;       
            }
            close (FH);
            if (scalar(@res) == 0) {
                return "MySh::>search $text $file\n";
            }
            else {
                chomp($res[$#res]);
                return "MySh::>search $text $file\n",@res,"\n";
            }
        }
        else { print STDOUT "0\n"; print STDERR "Can not open $file file\n"; return; }
    }
    else { print STDOUT "0\n"; print STDERR "Search func has no or not enough params\n"; return; }
}




package main;

my $gg = $ARGV[0];
my $count = 0;
my $last_page;
open( FH, "<", "$gg") or die "Can not open test file: $!";
my @strings = <FH>;
for (@strings) {    
    if ($_=~/^\s*$/) {
        $count++;
    }    
}
close (FH);
if ($count == scalar(@strings)) {
    print "0\n";
    print STDERR "File is empty\n";
    exit(1);
}
$last_page = @strings;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while (my $str = <FH>) {
    chomp($str);
    my @commands;
    # почистить пробелы в начале и конце строки
    if ($str =~ /^(\s)*$/) {
        print "MySh::>\n";
        next;    
    }
    
    $str =~ s/^\s*//g;
    $str =~ s/\s*$//g;
    #$str =~ s/\s*/ /g;
    
    if ($str =~ m/((print|copy|delete|move|sort|search|exit)\s*([\d\w]*\.?[\d\w]*){0,2}\ ?\|?)*/) {    
    
    
    if ($str =~ /\|/) {
        $str =~ s/\s*\|\s*/\|/g;
        if ($str =~ m/\|$/g) {
            print "0\n";
            print STDERR "| in the end of command";
            next;
        }
        else {
            @commands = split(/\|/,$str); 
            #print ShellTask::pipe(\@commands);
        }
        
        
    }
    else {
    
        @commands = split(/ /,$str);
    
        if ($commands[0] eq "print") {
            print ShellTask::print($commands[1]);        
        }
        elsif ($commands[0] eq "delete"){
            ShellTask::delete($commands[1]);        
        }
        elsif ($commands[0] eq "move") {
            ShellTask::move($commands[1],$commands[2]);
        }
        elsif ($commands[0] eq "sort") {
            print ShellTask::sort($commands[1]);
        }
        elsif ($commands[0] eq "search") {
            print ShellTask::search($commands[1],$commands[2]);
        }
        elsif ($commands[0] eq "copy") {
            ShellTask::copy($commands[1],$commands[2]);
        }
        elsif ($commands[0] eq "exit") {
            print "MySh::>\n";
            exit(1);
        }
        else {
            print "0\n";
            print STDERR "Command $commands[0] is not supported\n";
        }
    }
    }
    else {
        print STDOUT "0\n";
        print STDERR "Incorrect data\n";
    }
}
if ($last_page && $last_page ne "exit") {
        print "MySh::>\n";
        exit(1);
    }
close (FH);
