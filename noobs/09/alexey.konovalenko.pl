#!usr/bin/perl
use strict;
use warnings;
use DBI;

my $query_file = $ARGV[0];
open( FH, "<", $query_file )
  or print STDOUT "0\n"
  and die "Can't open file: $query_file\n";
my @file_strings = readline FH;
close(FH);
chomp(@file_strings);

chomp( my $host     = shift(@file_strings) );
chomp( my $port     = shift(@file_strings) );
chomp( my $DbName   = shift(@file_strings) );
chomp( my $UsrName  = shift(@file_strings) );
chomp( my $password = shift(@file_strings) );

my $status        = "";
my $currentQuery  = "";
my @currentParams = ();

my $dbh = DBI->connect(
	"DBI:mysql:$DbName:$host:$port",
	$UsrName,
	$password,
	{
		RaiseError => 1,
		PrintError => 0,
		AutoCommit => 0
	}

) or print STDOUT "0\n" and die "$!\n";

foreach my $line (@file_strings) {
	if ( $line =~ /^\s*-- sql\s*$/ ) {
		if ( $status eq "building command" ) {
			print STDOUT "0\n";
			print STDERR "--sql used twise";
			next;
		}
		$status        = "building command";
		$currentQuery  = "";
		@currentParams = ();
		next;
	}
	elsif ( $line =~ /^\s*-- end\s*$/ ) {

		#preparing & execute;
		if ( $status eq "executed" ) {
			print STDOUT "0\n";
			print STDERR "--end used twise";
			next;
		}
		$status = "executed";
		if ( !($currentQuery) ) {
			print STDOUT "0\n";
			print STDERR "Empty query";
			next;
		}
		eval {
			if ( $currentQuery =~ m/^\s*(select)\s+/i )
			{

				my $sth = $dbh->prepare($currentQuery);
				$" = ",";
				$sth->execute(@currentParams);
				while ( my @res_table = $sth->fetchrow_array() ) {
					$" = "|";
					print STDOUT "@res_table\n";

				}
				$sth->finish();

			}
			else {
				if ( @currentParams > 0 ) {
					
					foreach my $param (@currentParams) {
						my@temp_params  = split(/\,/,$param);
						my $rows_affected =  $dbh->do( $currentQuery, {}, @temp_params );
					}
				}
				else { $dbh->do( $currentQuery);}
			}
		};
		if ($@) { print STDOUT "0\n"; print STDERR "Error: $@"; }

		#print "Execute command $currentQuery (params - @currentParams)\n";

		$status        = '';
		$currentQuery  = '';
		@currentParams = ();
		next;
	}
	elsif ( $line =~ /^\s*-- param\s*$/ ) {
		$status = "collecting params";
		next;
	}
	if ( $status eq "building command" ) {
		$currentQuery .= " " . $line;
		next;
	}
	if ( $status eq "collecting params" ) {
		push( @currentParams, $line );
	}

}
$dbh->disconnect();
