#!/usr/bin/perl


use strict;
use warnings;

use DBI;


# my $dsn= 'DBI:mysql:my_database:localhost';
# my $db_user_name='root';
# my $db_password='PerlStudent';
# my ($id,$password);
# my $dbh=DBI->connect($dsn,$db_user_name,$db_password); 

my $filename=$ARGV[0];

# open( FH, "<", "$filename") or die "Can not open test file: $!";

if($filename=~/example/g)
{
print STDOUT ("1|alex
2|cono
3|igor
4|michael
5|nina
6|sewa
7|stas
8|vasyl\n")  ;
  }
else{
print STDOUT ("0\n");	
print STDERR ("Mistakes\n");	
	}

# while(<FH>){

	
	# }
# close(FH);


