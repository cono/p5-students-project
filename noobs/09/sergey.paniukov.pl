#!/usr/bin/perl

use warnings;
use DBI;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or print "0\n" and die "Can not open test file: $!";
my @config;
while (<FH>) {
    chomp;
    if (/^\s+$/||$_ eq ''){
		last;
		}
	else{
		push (@config, $_);
		}
}
my $cfg = 'DBI:mysql:'.$config[2].';host='.$config[0].':'.$config[1];
my $dbh = DBI->connect($cfg, $config[3], $config[4], { RaiseError => 0, PrintError => 0});
print "0\n" and die "Can`t connect to database $!" if (!defined $dbh);
my $sql = "";
my @requests;
my $req = "";
while (<FH>) {
    chomp;
    $req = $_ and next if (/^-- (.*)/);
    if ($req eq "-- sql") {
        $sql .= $_;
    } elsif ($req eq "-- param") {
        push(@requests, $_);
    } elsif ($req eq "-- end") {
        if ($sql =~/^(select|drop|create).*/i) {
            my $sth = $dbh->prepare(qq{$sql});
            $sth->execute();
            while (my @row = $sth->fetchrow_array()) {
                $" = '|';
                $tmp = "@row";
                print "$tmp\n";
            }
            $sth->finish();
        } else {
            foreach my $item(@requests) {
                $dbh->do(qq{$sql}, undef, split(/,/, $item));
            }
        }
        $sql = "";
        @requests = ();
        $req = "";
    } else {
        print "0\n" and die "Invalid request";
    } 
}
$dbh->disconnect();
close ( FH );
exit 0;