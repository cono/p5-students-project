#!/usr/bin/perl -w
use strict;

use DBI;
my $test_file_path = $ARGV[0];
my $source;
my $database;
my $hostname;
my $port;
my $user;
my $password;
my $dbh;
my $sth;
my $temp = 0;
my $rv;
my $count=0;
my $string="";
my $parem=undef;
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
while (<FH>) {
	chomp $_;
	if ($.==1){
		$hostname=$_;
		next;
	}
	elsif ($.==2){
		$port=$_;
		next;
	}
	elsif ($.==3){
		$database=$_;
		next;
	}
	elsif ($.==4){
		$user=$_;
		next;
	}
	elsif ($.==5){
		$password=$_;
		$dbh = DBI->connect("DBI:mysql:$database:$hostname:$port", $user, $password) or die "Can not connect database";
	next;
	}
	
	if ($_ eq '-- sql'){
	$temp = 1;
	next;
	}
	if ($_ eq '-- param'){
	$temp = 2;
	next;
	}
	if ($_ eq '-- end'){
	$temp = 3;
	}
	if ($_ eq ""){
	$temp=0;
	if ($_=~/\?/){
	$count++;
	}
	next;
	}
	if ($temp==1){
		chomp $_;
		$string="$string ".$_;
		}
	 if ($temp==2){	
		$parem=$_;
		# print "$parem\n";
		}
	if($temp==3){
	# print 123;
	 $sth = $dbh->prepare("$string");
	 
	# $sth = $dbh->prepare("$_");
	  # $sth->bind_param( $count,"$parem,");
	if (defined $parem) {
		if($parem=~/,/){
			my @temp = split (/,/,$parem);
			$sth->execute($temp[0],$temp[1]);
		} 
		else{
			$sth->execute($parem);
		}
	}
	if($parem=undef;){
	$sth->execute();
	}
	$string="";
	undef $parem;
	# print $rv;
	}
	
}
close ( FH );
print exit;
$dbh->disconnect or die "Can not disconnect database";