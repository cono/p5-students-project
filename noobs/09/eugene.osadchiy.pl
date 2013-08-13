#!/usr/bin/perl -w
use strict;
use DBI;

$"="|";

open (FH, "<", $ARGV[0]) or die "Can not open the test file $!";

my ($hostname, $port, $database, $username, $password);
$hostname = <FH>; $port = <FH>; $database = <FH>; $username = <FH>; $password = <FH>;

$hostname =~ s/\s+//g;
$port =~ s/\s+//g;
$database =~ s/\s+//g;
$username =~ s/\s+//g;
$password =~ s/\s+//g;

my $dsn = "dbi:mysql:database=$database;host=$hostname;port=$port";
my $dbh = DBI->connect($dsn, $username, $password) or (print "0\n" and die "SQL Error: $DBI::errstr\n");
my $sth;

my $request = undef;
my @params = ();
my $section = 0;

while(<FH>) {
	if(/--\s+sql/i)
	{
		$section == 0? $section = 1 : (print "0\n" and die "Query section already started\n");
		next;
	}
	if(/--\s+end/i)
	{
		process_query($request, @params);

		$request = undef;
		@params = ();
		$section ? $section = 0 : (print "0\n" and die "Query section already ended\n");
		next;
	}
	if($section == 1)
	{
		if(/--\s+param/i)
		{
			$section = 2;
			next;
		}
		$request .= $_;	
		next;
	}
	if($section == 2)
	{
		if(/--\s+param/i)
		{
			print "0\n";
			die "Query param section already started\n";
		}
		$_ =~ s/\s+//g;
		push @params, $_;
		next;
	}

}
close (FH);
$dbh->disconnect or warn $dbh->errstr;
exit 0;

sub process_query {
	my $sql = shift;
	my @params_row = @_;

	if(scalar(@params_row) > 0)
	{
		foreach my $params_row (@params_row) 
		{
			my @params_col = split /\s*\,\s*/, $params_row;
			if($sql =~ /^\s*select/i)
			{
				$sth = $dbh->prepare($sql);
				$sth->execute(@params_col) or (print "0\n" and die "SQL Error: $DBI::errstr\n");
				while (my @row = $sth->fetchrow_array) 
				{
					print "@row\n";
				}
			}
			else
			{
				$sth = $dbh->do($sql, {}, @params_col) or (print "0\n" and die "SQL Error: $DBI::errstr\n");
			}
		}
	}
	else
	{
		if($sql =~ /^\s*select/i)
		{
			$sth = $dbh->prepare($sql);
			$sth->execute() or (print "0\n" and die "SQL Error: $DBI::errstr\n");
			while (my @row = $sth->fetchrow_array) 
			{
				print "@row\n";
			}
		}
		else
		{
			$sth = $dbh->do($sql, {}) or (print "0\n" and die "SQL Error: $DBI::errstr\n");
		}
	}
}