#!/usr/bin/perl -w
use strict;
package MyShell;
sub Copy {
	system("cp $_[0] $_[1]"); 
}
sub Delete{
	return unlink $_[0];
}
sub Move{
	system("mv $_[0] $_[1]");
}

package main;
sub Trim { 
	$_[0] =~ s/^\s+//;
	$_[0] =~ s/\s+$//;
	return $_[0];
}

my $test_file_path = $ARGV[0];
open(FH, "<", "$test_file_path");

UpLoop: while (<FH>)
{
	chomp;
	my @stream = undef;
	print "MySh::>$_\n";
	$_ = Trim($_);
	my @row_com = split(/\|/, $_);
	foreach (@row_com){
	
		$_ = Trim($_);
		my @command = split (/\s+/,$_);		
		if (scalar @command >= 1){
			
			#delete
			if  ($command[0] eq "delete"){		
				if (scalar @command == 2){
					unless (MyShell::Delete($command[1])){
						print "0\n";
						print STDERR "File hasn't deleted!\n";
						next UpLoop;
					}
				}
				else{
					print "0\n";
					print STDERR "Invalid parameters!\n";
					next UpLoop;
				}
			}
			#copy
			elsif ($command[0] eq "copy"){		
				if (scalar @command == 3){
					if (-f $command[1]){
						MyShell::Copy($command[1],$command[2]);				
					}
					else{
						print "0\n";
						print STDERR "File not found!\n";
						next UpLoop;
					}
				}
				else{
					print "0\n";
					print STDERR "Invalid parameters!\n";
					next UpLoop;
				}
			}
			#move
			elsif ($command[0] eq "move"){		
				if (scalar @command == 3){
					if (-f $command[1]){
						MyShell::Move($command[1],$command[2]);				
					}
					else{
						print "0\n";
						print STDERR "File not found!\n";
						next UpLoop;
					}
				}
				else{
					print "0\n";
					print STDERR "Invalid parameters!\n";
					next UpLoop;
				}
			}
			#exit
			elsif ($command[0] eq "exit"){
				exit;
			}
			#print
			elsif ($command[0] eq "print"){
				my $s = $_; 
				my $file_in = my $file_out = undef;
				if ($_=~/^print\s+\S+\s*>\s*\S+$/ ){
					s/^print\s+//;
					s/s*>\s*\S+$//;
					$file_in = $_;
					if (!(-f $file_in)){
						print "0\n";
						print STDERR "File not found!\n";
						next UpLoop;
					}
					$_ = $s;
					s/.*>\s*//;
					$file_out = $_;
					
					open(F, "<", "$file_in");
					@stream = <F>;
					close(F);
					open(F, ">", "$file_out");
					foreach (@stream){ print F $_;}
					close (F);
					@stream = undef;
				}
				elsif ($_=~/.*>\s*\S+$/){
					s/.*>\s*//;
					$file_out = $_;
					open(F, ">", "$file_out");
					if (defined($stream[0])){
						for (my $i = 0; $i< scalar @stream; $i++) { print F $stream[$i]};
					}
					close (F);
					@stream = undef;
				}
				elsif ($_=~/^print\s+\S+$/){
					s/^print\s+//;
					$file_in = $_;
					if (!(-f $file_in)){
						print "0\n";
						print STDERR "File not found!\n";
						next UpLoop;
					}
					open(F, "<", "$file_in");
					@stream = <F>;
					close(F);
				}
				
				elsif ($_=~/^print$/){
				}
				else{
					print "0\n";
					print STDERR "File not found!\n";
					next UpLoop;
				}
				
			}
			#sort
			elsif ($command[0] eq "sort"){
				my $s = $_; 
				my $file_in = my $file_out = undef;
				if ($_=~/^sort\s+\S+\s*>\s*\S+$/ ){
					s/^sort\s+//;
					s/\s*>\s*\S+$//;
					$file_in = $_;
					if (!(-f $file_in)){
						print "0\n";
						print STDERR "File not found!\n";
						next UpLoop;
					}
					$_ = $s;
					s/.*>\s*//;
					$file_out = $_;
					
					open(F, "<", "$file_in");
					@stream = <F>;
					@stream = sort @stream;
					close(F);
					open(F, ">", "$file_out");
					foreach (@stream){ print F $_;}
					close (F);
					@stream = undef;
				}
				elsif ($_=~/.*>\s*\S+$/){
					s/.*>\s*//;
					$file_out = $_;
					open(F, ">", "$file_out");
					if (defined($stream[0])){
						@stream = sort @stream;
						for (my $i = 0; $i< scalar @stream; $i++) { print F $stream[$i]};
					}
					close (F);
					@stream = undef;
				}
				elsif ($_=~/^sort\s+\S+$/){
					s/^sort\s+//;
					$file_in = $_;
					if (!(-f $file_in)){
						print "0\n";
						print STDERR "File not found!\n";
						next UpLoop;
					}
					open(F, "<", "$file_in");
					@stream = <F>;
					@stream = sort @stream;
					close(F);
				}				
				elsif ($_=~/^sort$/){
					@stream = sort @stream;										
				}
				else{
					print "0\n";
					print STDERR "File not found!\n";
					next UpLoop;
				}
				
			}
			#search
			elsif ($command[0] eq "search"){
				my $s = $_; 
				my $file_in = my $file_out = my $find = undef;
				if ($_=~/^search\s+\S+\s+\S+\s*>\s*\S+$/ ){
					s/^search\s+\S+\s+//;
					s/\s*>\s*\S+$//;
					$file_in = $_;
					if (!(-f $file_in)){
						print "0\n";
						print STDERR "File not found!\n";
						next UpLoop;
					}
					$_ = $s;
					s/.*>\s*//;
					$file_out = $_;
					$_ = $s;
					s/^search\s+//;
					s/\s+.*//;
					$find = $_;
					open(F, "<", "$file_in");
					@stream = <F>;
					@stream = grep{$_=~/$find/} @stream;
					close(F);
					open(F, ">", "$file_out");
					foreach (@stream){ print F $_;}
					close (F);
					@stream = undef;
				}
				elsif ($_=~/^search\s+\S+\s*>\s*\S+$/){
					s/.*>\s*//;
					$file_out = $_;
					$_ = $s;
					s/^search\s+//;
					s/\s+.*//;
					$find = $_;
					open(F, ">", "$file_out");
					if (defined($stream[0])){
						@stream = grep{$_=~/$find/} @stream;
						for (my $i = 0; $i< scalar @stream; $i++) { print F $stream[$i]};
					}
					close (F);
					@stream = undef;
				}
				elsif ($_=~/^search\s+\S+\s+\S+$/){
					s/^search\s+\S+\s+//;
					$file_in = $_;
					$_ = $s;
					s/^search\s+//;
					s/\s+.*//;
					$find = $_;
					if (!(-f $file_in)){
						print "0\n";
						print STDERR "File not found!\n";
						next UpLoop;
					}
					open(F, "<", "$file_in");
					@stream = <F>;
					@stream = grep{$_=~/$find/} @stream;
					close(F);
				}				
				elsif ($_=~/^search\s+\S+$/)
				{
					s/^search\s+//;
					s/\s+.*//;
					$find = $_;
					@stream = grep {$_=~/$find/} @stream;
					
				}
				else{
					print "0\n";
					print STDERR "File not found!\n";
					next UpLoop;
				}
				
			}
			
		}
		else {
			print "0\n";
			print STDERR "File not found!\n";
			next UpLoop;
			next;
		}
	}
	if (defined($stream[0])){
		for (my $i = 0; $i< scalar @stream; $i++) { print $stream[$i]};
	}
}
close(FH);
print "MySh::>\n";
