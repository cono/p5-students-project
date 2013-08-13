#!/usr/bin/perl -w

use strict;
use DBI;
eval{
	my $test_file_path = $ARGV[0];
	open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

	my($host_name, $port, $database_name, $user_name, $password) = @{&get_connection_info};
	my $dsn = "DBI:mysql:database=$database_name;host=$host_name;port=$port";
	my $dbh = DBI->connect($dsn, $user_name, $password,
		{
			RaiseError => 1,
			PrintError => 0,
		}
	) or die $DBI::errstr;

	while((my $data_for_query = &get_sql_command)->[0] ne ""){
		$data_for_query->[0] =~ /\s*(\w+)/;
		my $sth;
		if($1 eq "select"){
			$sth = $dbh->prepare($data_for_query->[0]);
			if(defined @{$data_for_query->[1]}){
				for (@{$data_for_query->[1]}){
					my @par = split /,/;
					$sth->execute(@par) or die $sth->errstr;
					
					while (my $ans = $sth->fetchrow_arrayref) {
						print STDOUT join ("|",@{$ans}) . "\n";
					}
				}
			} else {
				$sth->execute() or die $sth->errstr;
				while (my $ans = $sth->fetchrow_arrayref) {
					print STDOUT join ("|",@{$ans}) . "\n";
				}
			}
		} 
		else {
			if(defined @{$data_for_query->[1]}){
			for (@{$data_for_query->[1]}){
				my @par = split /,/;
				$dbh->do($data_for_query->[0], undef, @par) or die $dbh->errstr;
			}
			} else {
				$dbh->do($data_for_query->[0]) or die $sth->errstr;
			}
		}
	}

close FH;

};
if($@){
	&print_error_message_and_exit($@);
}

sub print_error_message_and_exit {
	print STDOUT "0\n";
	print STDERR $_[0] . "\n";
	exit 1;
}

sub get_sql_command {
	while(my $not_begin_command = <FH>){
		$not_begin_command =~ s/\s*$//;
		if($not_begin_command eq "-- sql"){
			last;
		}
	}
	my @parameters;
	my $command = "";
	while(my $sql_command = <FH>){
		$sql_command =~ s/\s*$//;
		if($sql_command eq "-- end"){
			last;
		}
		
		if($sql_command eq "-- param"){
			while($sql_command = <FH>){
				$sql_command =~ s/\s*$//;
				if($sql_command eq "-- end"){
					last;
				}
				push @parameters, $sql_command;
			}
			last;
		}
		
		$command .= $sql_command;
	}
	[$command, \@parameters];
}

sub get_connection_info {
	my @data_con;
	my $some_data;
	while(($some_data = <FH>) ne "\n"){
		chomp $some_data;
		if($some_data ne ""){
			push @data_con, $some_data;
		}
	}
	\@data_con;
}