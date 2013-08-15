#! /usr/bin/perl

push (@INC, 'G:\WebServers\usr\local\perl\lib\DBD');

use warnings;
use strict;
use Data::Dumper;
use DBI;

my $file = $ARGV[0];
my $queries = "";

open (my $fh, "<", $file) or &ERROR("No file!");

my $hostname	=	<$fh>;	$hostname	=~ s/^\s+|\s+$//g;
my $port		=	<$fh>;	$port		=~ s/^\s+|\s+$//g;
my $db_name		=	<$fh>;	$db_name	=~ s/^\s+|\s+$//g;
my $user_name	=	<$fh>;	$user_name	=~ s/^\s+|\s+$//g;
my $password	=	<$fh>;	$password	=~ s/^\s+|\s+$//g;

$queries    .=	$_	while(<$fh>);

close ($fh);

my $path = 'DBI:mysql:' . $db_name . ':' . $hostname . ':' . $port;


my $dbh = DBI->connect($path, $user_name, $password, {
	RaiseError => 0,
	PrintError => 0,
	AutoCommit => 0,
}) or &ERROR("No connection!");

my $records = [];

while ($queries =~ m /(?:-- sql)(.*?)(?:-- end)/gs){
	
	my $query = {};
	my $text = $1;
	chomp($text);
	
	if ($text =~ m/-- param/){
				
		$text =~ m /^(.*?)(?:-- param)(.*?)$/gs;
		my $q = $1;
		my $p = $2;
		
		$q =~ s/^\s+|\s+$//g;
		$p =~ s/^\s+|\s+$//g;
				
		my $ar = [];
		my @pl = split(/\n/, $p);
		
		foreach (@pl){
			my @a = split(/,/,$_);
			push (@$ar, \@a);
		}
		
		foreach (@$ar){
			foreach(@$_){
				$_ =~ s/^\s+|\s+$//g;
			}
		}
		
		$query->{'params'} = $ar;
		$query->{'query'} = $q;
		
	} else {
		
		
		$text =~ s/^\s+|\s+$//g;
		$query->{'query'} = $text;
		$query->{'params'} = [];
	}
	
	push (@$records, $query);
}

&ERROR("no data!") if not scalar(@$records);

foreach my $record (@$records){

	my $query = $record->{'query'};
	my $params = $record->{'params'};
	
	my $sth = $dbh->prepare($query) or &ERROR("Couldn't prepare statement!");

	if (scalar(@$params)){
	
		foreach my $param (@$params){
			
			$sth->execute(@$param) or &ERROR("Couldn't execute statement!");

			
			if ($sth->err){
				
				&ERROR($sth->errstr());
			} elsif ($query =~ m/select/i) {
				
				while(my @ans = $sth->fetchrow_array()){
					
					print STDOUT join('|',@ans)."\n";
				}
			}
			$sth->finish();
		}
	} else {
		
		$sth->execute() or &ERROR("Couldn't execute statement!");

		if ($sth->err){
			
			&ERROR($sth->errstr());
		} elsif ($query =~ m/select/i) {
				
			while(my @ans = $sth->fetchrow_array()){
				
				print STDOUT join('|',@ans)."\n";
			}				
		}
		$sth->finish();
	}
}

$dbh->disconnect();

sub ERROR{
	
	my $msg = shift();

	print STDOUT "0\n";
	print STDERR $msg."\n";
	exit 1;	
}

