#!/usr/bin/perl -w

use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my @sequence_commands;

my $command_name;

OWNER:
while( <FH> ){
	chomp;
	my $empty = $_;
	$empty =~ s/\s//g;
	if(!$empty eq ""){
		print STDOUT "MySh::>" . $_ . "\n";
	} else {
		print STDOUT "MySh::>\n";
	}

	my $index_out = index $_, ">";
	my $index_pipe = index $_, "|";
	if(($index_out >= 0) && ($index_out < $index_pipe)){
		print_error_message_and_exit("Character '>' in mid");
		next;
	}
	
	my @print_to_file = split /[>]/;

	$print_to_file[0] =~ s/^\s+//;
	$print_to_file[0] =~ s/\s+$//;
	$print_to_file[0] =~ s%\s*\|\s*%|%g;
	
	if($print_to_file[0] eq "exit"){
		exit 0;
	}
	
	@sequence_commands = split /[|]/, $print_to_file[0];
	for my $command(@sequence_commands){
		my @shell_command = split /\s/, $command;
		my @arg;
		$command_name = $shell_command[0];
		for my $i(1..$#shell_command){
			push @arg, $shell_command[$i];
		}
		eval{
			SimpleShell->$command_name(@arg);
		};
		if($@){
			&print_error_message_and_exit($@);
			next OWNER;
		}

	}
	if(defined $print_to_file[1]){
		if(($print_to_file[1] =~ /\s*(\w+\.{1}\w+)\s*/) || ($print_to_file[1] =~ /\s*(\w+)\s*/)){
			eval{
				SimpleShell::write_in_file(SimpleShell::getLastEval(), $1);
			};
			if($@){
				&print_error_message_and_exit($@);
				next;
			}
		} else {
			&print_error_message_and_exit("Wrong file format");
		}
	} elsif(($command_name eq "sort") ||
		   ($command_name eq "search") ||
		   ($command_name eq "print")
		   ){
		my $inner = SimpleShell::getLastEval();
		print @{$inner};
	}
}
print STDOUT "MySh::>\n";

close(FH);

##

sub print_error_message_and_exit {
	print STDOUT "0\n";
	print STDERR $_[0];
}

package SimpleShell;

	my @inner_buffer = undef;

	sub getLastEval {
		return \@inner_buffer;
	}

	sub read_from_file {
		die "Mismatch number of arguments"
			if(@_ != 1);
		my $source_file = shift;
		my @source_data;
		my $source_data_fh;
		open $source_data_fh, '<', $source_file or die "Can not open file: $!";
		while(<$source_data_fh>){
			push @source_data, $_;
		}
		close $source_data_fh;
		\@source_data;
	}
	#my @a = &read_from_file("a");
	##

	sub write_in_file {
		my $array_length = @_;
		die "Mismatch number of arguments"
			if(($array_length > 2) || ($array_length < 1));
		my $write_data = shift;
		my $where = shift;
		my $is_defined_where = defined $where;
		if($is_defined_where){
			open MY_OUT, '>', $where;
			select MY_OUT;
		}
		print @{$write_data};
		if ($is_defined_where) {
			close MY_OUT;
			select STDOUT;			
		}
	}
	#&write_in_file (\@a, "a1");
	##

	sub copy {
		shift;
		die "Mismatch number of arguments"
			if(@_ != 2);
		my $source = shift;
		my $destination = shift;
		my $source_data = &read_from_file($source);
		write_in_file($source_data, $destination);
	}
	#&copy("a", "b.txt");

	sub move {
		shift;
		die "Mismatch number of arguments"
			if(@_ != 2);
		my $source_name = shift;
		my $new_name = shift;
		die "Fail when try rename file"
			if(!rename $source_name, $new_name);
	}
	#&move("aaa", "a");

	sub delete {
		shift;
		die "Mismatch number of arguments"
			if(@_ != 1);
		my $delete_file = shift;
		die "Fail when try delete file"
			if(!unlink $delete_file);
	}
	#&delete("b");

	sub print { 
		shift;
		my $array_length = @_;
		die "Mismatch number of arguments"
			if(($array_length > 2) || ($array_length < 1));
		my ($file_name, $where) = @_;
		my $source_data = &read_from_file($file_name);
		@inner_buffer = @{$source_data};
	}
	#&print("a", "ccc.txt");

	sub sort {
		shift;
		my $length = @_;
		die "Mismatch number of arguments"
			if($length > 1);
		my $source_data = $length == 1 ? &read_from_file(shift) : \@inner_buffer;
		$source_data = [sort @{$source_data}];
		@inner_buffer = @{$source_data};
	}
	#&sort("a");

	sub search {
		shift;
		my $length = @_;
		die "Mismatch number of arguments"
			if(($length < 1) || ($length > 2));
		my($search_string, $file_name) = @_;
		my $source_data = (defined $file_name ? &read_from_file($file_name) : \@inner_buffer);
		my $found_data = [grep(/$search_string/, @{$source_data})];
		@inner_buffer = @{$found_data};
	}
	#&search("v", "ccc.txt");

1;










