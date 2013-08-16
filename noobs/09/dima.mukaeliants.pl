#!/usr/bin/perl -w
use strict;
use DBI;
#use Data::Dumper;
#use myDumper;

my $test_file_path;	
if(@ARGV){$test_file_path = $ARGV[0];}
else{print STDOUT "0\n"; die "No incoming parameters\n";}
unless( open( FH, "<", $test_file_path) ){print STDOUT "0\n"; die "Can not open file: $!";}

my @connectionParams = ();
for my $i (0..4){
	my $paramsString = <FH>;
	if($paramsString =~ /^\s+?$/){print STDOUT "0\n"; die "Empty parameters string [$i].";}
	elsif($paramsString !~ /^[\w\.]+?$/){print STDOUT "0\n"; die "Wrong symbols in parameters string [$i].";}
	else{ $paramsString =~ s/\n$//; push @connectionParams, $paramsString }
}
if(scalar @connectionParams != 5){print STDOUT "0\n"; die "Incorrect number of connection parameters.";}

my $blocksArray = [];
while ( defined(my $file_string = <FH>) ) {
	if($file_string =~ /\s*?--\s*?sql\s*?/){
		my $queryHash = {};
		my $array = [];
		#my $valueString = '';
		my $queryString = '';
		my $tumbler = '';
		my $numOfQuestMarks = 0;
		my $i=1;
		my $error = undef;
		while(defined($file_string = <FH>) && $file_string !~ /\s*?--\s*?end\s*?/){
			if($file_string =~ /\s*?--\s*?param\s*?/){ $numOfQuestMarks = split (/\?/, $queryString) - 1; $tumbler = 'true'; next; }
			if(!$tumbler){ $file_string =~ s/\n$/ /g; $queryString .= $file_string; }
			else{
				my @valuesArray = ();
				$file_string =~ s/\n$//g;
				#check alphanumeric
				
				
				if($file_string =~ /,/){@valuesArray = split(/,/, $file_string)}
				else{push @valuesArray, $file_string}
				#if(scalar(@valuesArray) == $numOfQuestMarks){push @{$array}, \@valuesArray}
				#else{$error .= "Wrong number of values for query [$queryString]."; last}
				push @{$array}, \@valuesArray;
			}
		}
		if($queryString){ $queryHash->{query} = $queryString } else {$error = "Empty query string."}
		if(@{$array}){$queryHash->{values} = $array}
		if($error){print STDOUT "0\n"; die $error."\n";} else {push @{$blocksArray}, $queryHash}
	}
}
unless( close ( FH ) ){print STDOUT "0\n"; die "Can not clouse file: $!";}

#myDumper::recursia($blocksArray,'qweqwe');


my($host, $port, $db, $user, $password) = @connectionParams;
my $dsn = "DBI:mysql:database=$db;host=$host;port=$port";
#$user = "root";
#$password = "PerlStudent";
my $dbh;
eval { $dbh = DBI->connect($dsn, $user, $password, { RaiseError => 1, PrintError => 0 } ) };
if($@){print STDOUT "0\n"; die "Unable to connect:\n$@"} #$DBI::errstr

#if ($dbh->ping) { print "Pinged successfuly\n" };

my $i = 0;
foreach my $block (@{$blocksArray}){
	$i++;
	eval {
		my $query = $block->{query};
		my $rows_affected;
		if($query !~ /^\s*?SELECT/i){
			#print "OK\n";
			if($block->{values}){
				my $paramsArr = $block->{values};
				foreach my $params (@$paramsArr){ $rows_affected = $dbh->do($query, undef, @$params); }#print "DO res1: ".$rows_affected."\n" };
			}
			else{ $rows_affected = $dbh->do($query,,); }#print "DO res2: ".$rows_affected."\n" };
		}
		else{
			my $sth = $dbh->prepare("$query");
			if($block->{values}){
				my $paramsArr = $block->{values};
				foreach my $params (@$paramsArr){ $sth->execute( @$params ) }
			}
			else{ $sth->execute() }
			#while (my $ans = $sth->fetchrow_hashref) {
			while (my $ans = $sth->fetchrow_arrayref) {
				#my @val = ();
				#foreach my $key (sort keys %{$ans}){ push @val, ${$ans}{$key}; }
				print STDOUT join('|', @$ans)."\n";
			}
			$sth->finish;
		}
		
		
		
		
	};
	if ($@) { print STDOUT "0\n"; die "[$i]Error happened: $@\n" };
}


$dbh->disconnect;
#srand 42;
#my@s=split//," gy\nslkaowaOalKa";
#print splice@s,rand@s,1 while@s;
#print "\n\n";




