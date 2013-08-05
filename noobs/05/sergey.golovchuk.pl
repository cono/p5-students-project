#! /usr/bin/perl

use warnings;
use strict;

my $file = $ARGV[0];

if (not -s $file){
	
	print STDOUT "0\n";
	exit 1;
}

open (my $fh, "<", $file) or die "Cannot open file $file: $!";

do {
	print STDOUT &engine::perform($_);
	print STDOUT "MySh::>";
} while (<$fh>);

close ($fh);

package parser;

sub get_commands(){
	
	my $line = shift;
	return if not defined $line;
	$line = &my_trim($line);
	my @result = split(/\|/, $line);
	
	return @result;
}

sub get_command(){

	my $line = shift;
	$line =~ s/>\s*/>/;
	$line = &my_trim($line);
	my @result = split(/\s+/, $line);
	
	return @result;
}

sub my_trim(){
	
	my $str = shift;
	$str =~ s/^\s+|\s+$//;
	return $str;
}
package fcommands;

sub my_copy(){

	my ($src, $dest) = @_;
	
	return 0 if !(defined($src) && defined($dest));
	return 0 if !(-e $src);
		
	open my $fh_src, "<", $src or return 0;
	open my $fh_dest, ">", $dest or return 0;
	
	print $fh_dest (<$fh_src>);
	
	close $fh_dest;
	close $fh_src;

	return 1;
}
sub my_move(){

	my ($src, $dest) = @_;

	return 0 unless (defined($src) or defined($dest));
	return 0 unless -e $src;
	return 0 if -e $dest;
	
	rename $src, $dest;
	
	return 1;
}
sub my_delete(){

	unlink shift @_;
}
sub my_print(){
	
	my ($source, $dest) = @_;
		
		return 0 unless defined($$source);
		return 0 unless -e $$source;	
		
		open my $fh_src, "<", $$source or return 0;

		my @file = (<$fh_src>);
		
		close $fh_src;
		
		if (ref($source) eq "SCALAR" and defined($$source) and not defined($dest)){
		
			return join("", @file);
		
		} elsif (ref($source) eq "SCALAR" and defined($$source) and ref($dest) eq "SCALAR" and defined($$dest)){
			
			if ($$dest =~ m/^>.*$/){
				$$dest =~ s/>\s*//;
				
				open my $fh, ">", $$dest or return 0;
				
				print $fh @file;
				
				close $fh;
			} else {
			
				return 0;
			}
		}
	}
package commands;

sub my_sort{
	
	my ($source, $dest) = @_;

	if (ref($source) eq "ARRAY" and scalar(@$source)){
		
		if (ref($dest) eq "SCALAR" and defined($$dest)){
		
			if ($$dest =~ m/^>.*$/){
				$$dest =~ s/>//;
				
				open my $fh, ">", $$dest or return 0;
				print $fh $_."\n" foreach (sort @$source);
				close $fh;
		
			}
		} else {
			
			return join("\n", sort @$source);
		}

	} elsif (ref($source) eq "SCALAR" and defined($$source)){
		
		return 0 unless -e $$source;	
		
		open my $fh_src, "<", $$source or return 0;
		my @file = (<$fh_src>);	
		close $fh_src;
		
		if (ref($dest) eq "SCALAR" and defined($$dest)){
		
			if ($$dest =~ m/^>.*$/){
				$$dest =~ s/>//;
				
				open my $fh, ">", $$dest or return 0;
				print $fh $_."\n" foreach (sort @file);
				close $fh;
		
			}
		} else {
			
			return join("", sort @file);
		}
	
	} else {
	
		return 0;
	}
}
sub my_search(){
	
	my ($substr, $source, $dest) = @_;
	
	if (ref($substr) eq "SCALAR" and defined($$substr)){
	
		if (ref($source) eq "ARRAY" and scalar(@$source)){
			
			if (ref($dest) eq "SCALAR" and defined($$dest)){
			
				if ($$dest =~ m/^>.*$/){
					$$dest =~ s/>//;
					
					open my $fh, ">", $$dest or return 0;
					foreach (@$source){
						
						print $fh $_ if /$$substr/;
					}
					close $fh;
			
				}
			} else {
			
				my @res = ();
		
				foreach (@$source){
				
					if (/$$substr/){
					
						push(@res, $_);
					}
				}
				
				return join("\n", @res);
				
			}

		} elsif (ref($source) eq "SCALAR" and defined($$source)){
			
			return 0 unless -e $$source;	
			
			open my $fh_src, "<", $$source or return 0;
			my @file = (<$fh_src>);	
			close $fh_src;
			
			if (ref($dest) eq "SCALAR" and defined($$dest)){
			
				if ($$dest =~ m/^>.*$/){
					$$dest =~ s/>//;
					
					open my $fh, ">", $$dest or return 0;
					foreach (@file){
						
						print $fh $_ if /$$substr/;
					}
					close $fh;
			
				}
			} else {
				
				my @res = ();
		
				foreach (@file){
				
					if (/$$substr/){
					
						push(@res, $_);
					}
				}
				
				return join("", @res);
				
			}
		
		} else {
		
			return 0;
		}
	} else {
	
		return 0;
	}
}	
sub my_exit(){

	exit 0;
}

package engine;

sub perform(){

	my $task = shift;
	return if not defined $task;
	my $result = "";
	
	my %hash = (
		'copy'		=>	\&fcommands::my_copy,
		'move'		=>	\&fcommands::my_move,
		'delete'	=>	\&fcommands::my_delete,
		'print'		=>	\&fcommands::my_print,
		'sort'		=>	\&commands::my_sort,
		'search'	=>	\&commands::my_search,
		'exit'		=>	\&commands::my_exit,
	);	

	print STDOUT "$task";
	
	my @commands = &parser::get_commands($task);
	
	while ($_ = shift @commands){
		
		my @command = &parser::get_command($_);
		my $command_name = lc shift(@command);
		my $args_n = scalar(@command);
		
		if (exists($hash{$command_name})){
			
			if (
				($command_name eq 'exit'	&&	$args_n == 0) ||
				($command_name eq 'delete'	&&	$args_n == 1) ||
				($command_name eq 'copy'	&&	$args_n == 2) ||
				($command_name eq 'move'	&&	$args_n == 2)
			){
			
				unless ($hash{$command_name}->(@command)){

					return "0\n";
				}
			} elsif ($command_name eq 'print'){
			
				if ($args_n == 1){
				
					my ($file) = @command;
					return "0\n" unless $result = $hash{$command_name}->(\$file);
				} elsif ($args_n == 2 && not scalar(@commands)){
					
					my ($file, $dest) = @command;
					return "0\n" unless $result = $hash{$command_name}->(\$file, \$dest);
				} else {
					
					return "0\n";
				}
			} elsif ($command_name eq 'sort'){
			
				if ($args_n == 0){
					
					if ($result eq ""){
						
						return "0\n";
					}
					my @data = split(/\n/, $result);
					return "0\n" unless $result = $hash{$command_name}->(\@data);
				} elsif ($args_n == 1){
				
					my ($file) = @command;
					
					if ($file =~ m/^>/ && not scalar(@commands)){
						
						my @data = split(/\n/, $result);
						return "0\n" unless $result = $hash{$command_name}->(\@data, \$file);
					} else {
					
						return "0\n" unless $result = $hash{$command_name}->(\$file);
					}
				} elsif ($args_n == 2 && not scalar(@commands)){
					
					my ($file, $dest) = @command;
					return "0\n" unless $result = $hash{$command_name}->(\$file, \$dest);
				} else {
					
					return "0\n";
				}
			} elsif ($command_name eq 'search'){
			
				if ($args_n == 1){
				
					if ($result eq ""){
						
						return "0\n";
					}					
					my @data = split(/\n/, $result);
					my ($substr) = @command;
					return "0\n" unless $result = $hash{$command_name}->(\$substr, \@data);
				} elsif ($args_n == 2){
				
					my ($substr, $file) = @command;
					
					if ($file =~ m/^>/ && not scalar(@commands)){
						
						my @data = split(/\n/, $result);
						return "0\n" unless $result = $hash{$command_name}->(\$substr, \@data, \$file);
					} else {
					
						return "0\n" unless $result = $hash{$command_name}->(\$substr, \$file);
					}
					
				} elsif ($args_n == 3 && not scalar(@commands)){
					
					my ($substr, $file, $dest) = @command;
					return "0\n" unless $result = $hash{$command_name}->(\$substr, \$file, \$dest);
				} else {
					
					return "0\n";
				}
			} else {
			
				return "0\n";
			}
		} else {
		
			return "0\n";
		}
	}
	
	if ($result eq "" or $result eq "1"){
		
		$result = "";
		return $result;
	} else {
			
		chomp($result);
		return $result."\n";
	}
}
