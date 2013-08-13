#!/usr/bin/perl

use warnings;
use DBI;

# use first argument of script as file name whith data
my $test_file_path = $ARGV[0];
# open file and get file handler or die
open( FH, "<", "$test_file_path") or die ("Can not open test file: $!");

my @param_name = ("host", "port", "dbname", "username", "password");
my %hash;
my $sql = "";
my @params;
my $trigger = "";
# Load config values
while (<FH>) {
    chomp;
    $hash{$param_name[$.-1]} = $_ if ($param_name[$.-1]);
    last if (!defined $param_name[$.-1]);
}
# Connect to MySQL Sever DBI:mysql:databasename;host=db.example.com'
my $cfg = 'DBI:mysql:'.$hash{"dbname"}.';host='.$hash{"host"};
my $dbh = DBI->connect($cfg, $hash{"username"}, $hash{"password"}, { RaiseError => 0, PrintError => 0 });
if (!defined $dbh) {
    print "0\n";
    warn("Cannot connect to database $!");
    exit 2;
}
# Progress ...
while (<FH>) {
    chomp;
    $trigger = $_ and next if ($_ =~ m/^-- (.*)/);
    if ($trigger eq "-- sql") {
        $sql .= $_." ";
    } elsif ($trigger eq "-- param") {
        push(@params, $_);
    } elsif ($trigger eq "-- end") {
        # Execute SQL
        if ($sql =~ m/^(select|drop|create).*/i) {
            my $sth = $dbh->prepare(qq{$sql});
            $sth->execute();
            while (my @row = $sth->fetchrow_array()) {
                $" = '|';
                $tmp = "@row";
                print "$tmp\n";
            }
            $sth->finish();
        } else {
            foreach my $values(@params) {
                $dbh->do(qq{$sql}, undef, split(/,/, $values));
            }
        }
        # Clean values
        $sql = "";
        @params = split(/,/, "");
        $trigger = "";
    } else {
        print "0\n";
        warn("Unknow values");
        exit 3;
    } 
}

$dbh->disconnect();
close(FH);

exit 0;

