#!/usr/bin/perl -w
use strict;
use DBI;

($#ARGV == 0) or die "Missing file name";
my $test_file_path = $ARGV[0];

open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my $hostname = <FH>; chomp $hostname;
my $port = <FH>; chomp $port;
my $dbname = <FH>; chomp $dbname;
my $username = <FH>; chomp $username;
my $password = <FH>; chomp $password;

my $dsn = "DBI:mysql:database=$dbname;host=$hostname;port=$port";

my $dbh = DBI->connect($dsn, $username, $password,
                       {
                        RaiseError => 1,
                        PrintError => 0
                       }
                       );


my $block;

local $/;
my $data = <FH>;

my @arr_data = split(/^\s*--\s*end\s*$/m, $data);

foreach $block(@arr_data)
{

  my @arr = split(/^\s*--\s*sql\s*|^\s*--\s*param\s*|^\s*--\s*end\s*/m, $block);

  if ( scalar(@arr) == 2 ) { sql_exe($arr[1]) }
  elsif (scalar(@arr) == 3) { sql_param_exe($arr[1], $arr[2]) }
  else { printError("Error"); $dbh->disconnect; exit 1 }
}

$dbh->disconnect;



sub sql_exe
{
  my $sql = shift;
    
  $sql =~ s/\n/ /g;
  
  my $sth;
  my @rows;

  if ($sql =~ /select/i) {
    eval{
      $sth = $dbh->prepare("$sql");
      $sth->execute;
      
      while (@rows = $sth->fetchrow_array) {
        for my $i(0..scalar(@rows)-1) {
          if( !defined($rows[$i]) ) { $rows[$i] = "" }
        }
        print join("|", @rows)."\n";
      }
      
      $sth->finish;
    }
  }
  else{
    eval{
      $dbh->do("$sql");
    }
  }
     if ($@) { printError("Error: $@"); $dbh->disconnect; exit 1 }
}



sub sql_param_exe
{
  my $sql = shift;
  my $param = shift;
  
  $sql =~ s/\n/ /g;
  
  my $sth;
  my @rows;
  
  my @param_arr = split(/\n/, $param);
  
  @param_arr = grep(s/\s*//g,@param_arr);
  
  foreach my $param_string(@param_arr){
    chomp($param_string);
    my @par = split(/,/, $param_string);

    if ($sql =~ /select/i) {
      eval{
        $sth = $dbh->prepare("$sql");
        $sth->execute(@par);
      
        while (@rows = $sth->fetchrow_array) {
          for my $i(0..scalar(@rows)-1) {
            if( !defined($rows[$i]) ) { $rows[$i] = "" }
          }
          print join("|", @rows)."\n";
        }
      
        $sth->finish;
      }
    }
    else{
      eval{
        $dbh->do("$sql", {}, @par);
      }
    }
       if ($@) { printError("Error: $@"); $dbh->disconnect; exit 1 }
  }
}

sub printError
{
  print STDOUT "0\n";
  print STDERR "$_[0]\n";            
}

