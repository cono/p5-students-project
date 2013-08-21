#!/usr/bin/perl -w
use strict;
use DBI;
sub Trim {
	$_[0] =~ s/^\s+//;
	$_[0] =~ s/\s+$//;
	return $_[0];
}
sub Err {
	my $error = shift;
	print STDOUT "0\n";
	print STDERR "$error\n";
}

my $file = $ARGV[0];
open (FH, '<', $file) or die "Can not open test file: $!";
my $counter = 0;
my $host;	my $port; 	my $database; 	my $user; 	my $password;
while (<FH>){
	chomp($_);
	$_ = Trim($_);
	if ($_ eq ""){
		last;
	}
	$counter++;
	if ($counter == 1){
		$host = $_;
	}
	elsif($counter == 2){
		$port = $_;
	}
	elsif($counter == 3){
		$database = $_; 
	}
	elsif($counter == 4){
		$user = $_; 
	}
	elsif($counter == 5){
		$password = $_;
	}
	elsif($counter == 6){
		Err("The empty string must be at 6th row!");
		exit;
	}
}
if ($counter < 5 ) {
	Err("Not enough parameters\n");
	exit;
} 
my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port",$user, $password, {RaiseError => 0});
if (!defined($dbh)){
	Err("Can't connect to database!");
	exit;
}
my $query = "";
my @param;

my $sql = 0; my $param = 0; my $end = 1;
while (<FH>){
	my $sth;
	chomp;	$_ = Trim ($_);
	if ( $_ =~ /^--\s*sql/){
		unless ($end){
			Err ("No query!");
			exit;
		}
		$sql = 1; $end = 0; $param = 0;
	}
	elsif (/^--\s*param/){							#добавить проверку на последовательность sql - param - end
		unless ($sql) {
			Err ("No query!");
			exit;
		}
		$sql = 0; $end = 0; $param = 1;
	}
	elsif (/^--\s*end/){
		if ($sql){									#параметров не было, нужно выполнить запрос			
			if ($query =~ /^\s*select/i){
				$sth = $dbh->prepare($query);
				if ( defined( $sth->execute() ) ){
					while (my @ans = $sth->fetchrow_array){
						local $, = "|";
						print @ans;
						print "\n";
					}
				} else {
					Err("Invalid query!");
					exit;
				}
			}
			else {
				if ( !defined( $dbh->do($query) )) {
					Err("Invalid query!");
					exit;
				}
			}
			
		}
		$sql = 0; $end = 1; $param = 0;
		$query = "";
	}
	else{
		if($sql){
			$query .= $_."  ";
		}
		if ($param){
			@param = split (/,/, $_);			
			$sth = $dbh->prepare($query);			
			if (defined ($sth->execute(@param))){
				if ( defined($sth->{NUM_OF_FIELDS})) {
					while (my @ans = $sth->fetchrow_array){
						local $, = "|";
						print @ans;
						print "\n";
					}
				}
			} else {
				Err("Invalid query!");
				exit;
			}
		}
		if ($end){
			#print $_ 								#всякая лабуда  вне запроса
		}
	}
	
}
$dbh -> disconnect();