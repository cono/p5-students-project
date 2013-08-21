#!/usr/bin/perl -w
use strict;

package Functions;
my @file;

sub read_file
{
	my $file_name = shift;
	open (FH, "<", "$file_name") or (print "0\n" and warn "Read. $!\n" and return 1);
	while (<FH>)
	{
		push @file, $_;
	}
	close FH;
	return 0;
}

sub write_file {
	my $file_name = shift;
	open (FH, ">", "$file_name") or (print "0\n" and warn "Write. $!\n" and return 1);
	foreach (@file)
	{
		print FH $_;
	}
	close FH;
	@file = ();
	return 0;
}

sub delete_file
{
	if(scalar @_ == 1)
	{
		my $file_name = shift;
		unlink $file_name or (print "0\n" and warn "Delete. $!\n" and return 1);
		return 0;
	}
	else
	{
		(print "0\n" and warn "Delete. Not valid count of args\n" and return 1);
	}
}

sub move_file
{
	if(scalar @_ == 2)
	{
		my ($from, $to) = @_;
		rename $from, $to or (print "0\n" and warn "Move. $!\n" and return 1);
		return 0;
	}
	else
	{
		(print "0\n" and warn "Move. Not valid count of args\n" and return 1);
	}
}

sub copy_file
{
	@file = ();
	if(scalar @_ == 2)
	{
		my ($from, $to) = @_;
		if(read_file($from))
		{
			return 1;
		}
		write_file($to);
		return 0;
	}
	else
	{
		(print "0\n" and warn "Copy. Not valid count of args\n" and @file = () and return 1);
	}
	
}

sub print_file	#norm
{
	if(scalar @_== 1)
	{
		@file = ();
		if(read_file(shift))
		{
			return 1;
		}
	}
	else
	{
		(print "0\n" and warn "Print. Not valid count of args\n" and return 1);
	}
	return 0;
}

sub print_result {
	foreach (@file)
	{
		print $_;
	}
}

sub sort_file #norm
{
	if(scalar @_== 1)
	{
		@file = ();
		if(read_file(shift))
		{
			return 1;
		}
	}
	else
	{
		if(scalar @_ != 0 || scalar @file == 0)
		{
			(print "0\n" and warn "Sort. Not valid count of args\n" and return 1);
		}
	}
	@file = sort @file;
	return 0;
}

sub search_file {
	my $pattern;
	if (@_== 2) {
		@file = ();
		$pattern = shift;
		if(read_file(shift))
		{
			return 1;
		}
	}	
	else
	{
		if(scalar @_ != 1 || scalar @file == 0)
		{
			(print "0\n" and warn "Search. Not valid count of args\n" and return 1);
		}
		$pattern = shift;
	}
	@file = grep {/$pattern/} @file;
	return 0;
}

sub exit_file
{
	@_ == 0 ? exit 0 : (print "0\n" and warn "Exit. Not valid count of args\n" and  return 1);
}


package main;
my $test_file_path = $ARGV[0];
open (FH, "<", "$test_file_path") or die "Can not open test file: $!";

my %command_list = (
	"copy" => \&Functions::copy_file,
	"move" => \&Functions::move_file,
	"delete" => \&Functions::delete_file,
	"print" => \&Functions::print_file,
	"sort" => \&Functions::sort_file,
	"search" => \&Functions::search_file,
	"exit" => \&Functions::exit_file
	);

while (<FH>) {
	@file = ();
	print "MySh::>$_";
	if(/^\s*$/)
	{
		next;
	}
	if(/\|\s*$/ || s/>/>/g > 1)	
	{
		print "0\n" and warn "Error. Pipe in the end of the string or count of '>' more than one.\n"; 
		next;
	}
	else
	{
		chomp;
		my @comands = split /\s*\|\s*/, $_;
		for (my $i = 0; $i < scalar @comands; $i++) {
			if($comands[$i]=~/>/ && $i==(scalar(@comands) - 1) && $comands[$i]=~/\s*>\s*[\w\.]+\s*$/)
			{
				my @output = split /\s*>\s*/, $comands[$i];
				my @items = split /\s+/, $output[0];
				if($items[0] eq '')
				{
					shift @items;
				}
				if(exists $command_list{$items[0]})
				{
					my $operation = $items[0];
					if($operation eq 'copy' || $operation eq 'move' || $operation eq 'delete' || $operation eq 'exit')
					{
						print "0\n" and warn "Invalid operation.\n";
						@file = (); 			
						last;			
					}
					shift @items;
					$command_list{$operation}(@items);
				}
				else
				{
					print "0\n" and warn "Comand not in list.\n";
					@file = (); 			
					last;	
				}
				Functions::write_file($output[1]);
			}
			else
			{
				if($comands[$i]=~/>/)
				{
					print "0\n" and warn "Error. '>' have invalid position.\n"; 
					@file = (); 
					last;
				}
				else
				{
					my @items = split /\s+/, $comands[$i];
					if($items[0] eq '')
					{
						shift @items;
					}
					if(exists $command_list{$items[0]})
					{
						my $operation = $items[0];
						shift @items;
						my $out = $command_list{$operation}(@items);
						if($out == 1)
						{
							@file = ();
							last;
						}
					}
					else
					{
						print "0\n" and warn "Comand not in list.\n";
						@file = (); 			
						last;	
					}
				}	
			}
		}
		if(scalar @file != 0)
		{
			Functions::print_result;
		}
	}
}
print "MySh::>\n";
close FH;