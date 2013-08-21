#!/usr/bin/perl -w 
use strict;
use DBI;

package BASEDO;

  sub new{
    my $class   = shift;
    my $dsn = "DBI:mysql:database=".$_[2].";host=".$_[0].";port=".$_[1];
    my $dbh = DBI->connect($dsn, $_[3], $_[4],
    {
        RaiseError => 0,
        PrintError => 0,
    }
    ) || die "невозможно подключиться\n";
    my $param = 'false';
    my $znach = '';
    my $sqlst = '';
    my $self  = {dbh=>$dbh, param=>$param, znach=>$znach, sqlst=>$sqlst};
    return bless $self, $class;
  }
  #проверка на вшивость
  sub whot {
    my $self = shift;
    if (@_) {
      $self->{param} = shift;
    }
    return $self->{param};
  }
  #запись строки комнды SQL
  sub writesql {
    my $self = shift;
    if (@_) {
      $self->{sqlst} .= shift;
    }
    return $self->{sqlst};
  }
  #запись параметров
  sub writeparam {
    my $self = shift;
    if (@_) {
      $self->{znach} = shift;
      $self->does();
      $self->{znach} = ''
    }
    return $self->{znach};
  }
  #определение запуска команд
  sub does {
    my $self = shift;
    if($self->{sqlst} =~ m/(select)|(update)|(insert)/i){
      $self->prepar;
    }else{
      $self->dosql;
    }
  }
  # очистка данных
  sub clears {
    my $self = shift;
    $self->{znach} = '';
    $self->{sqlst} = '';
  }
  #отработка с параметрами
  sub prepar {
    my $self = shift;
    my $sth  = $self->{dbh}->prepare($self->{sqlst});
    my @date = split(",", $self->{znach});
    $sth->execute(@date) || die "bad command\n";
    $" = "|";
    while (my @ans = $sth->fetchrow_array) {
      print "@ans\n";
    }
  }
  #отработка без параметров
  sub dosql {
    my $self = shift;
    my $sth  = $self->{dbh}->do($self->{sqlst}) || die "bad command\n";
  }
  
  sub disconnetct {
    my $self = shift;
    $self->dbh->disconnect;
  }
  
package main;
eval{
  my $test_file_path = $ARGV[0];
  open( FH, "<", "$test_file_path") or die "нет такого файла\n"; 
  my $host     = <FH>;
  my $port     = <FH>;
  my $base     = <FH>;
  my $user     = <FH>;
  my $password = <FH>;
  $host     =~ s/\s*//g;
  $port     =~ s/\s*//g;
  $base     =~ s/\s*//g;
  $user     =~ s/\s*//g;
  $password =~ s/\s*//g;
  if(($user eq '') || ($password eq '') || ($base eq '') || ($host eq '') || ($port eq '')){
    die "неопределенны данные $user $password $base $host $port\n";
  };  
     $password = '';
  my $db = BASEDO->new($host, $port, $base, $user, $password);
  my $i = 0;
  while (<FH>){
  #проверяем, команды
    if($_ =~ '-- sql'){
      $db->whot('false');
      next;
    }elsif($_ =~ '-- param'){
      $db->whot('true');
      $i = 1;
      next;
    }elsif($_ =~ '-- end'){
      $db->whot('false');
      if($i == 1){
	$i = 0;
      }else{
	$db->does;
      }
      	$db->clears;
	next;
    }else{
    #проверка на запись в параметры или строку sqlst
      if($db->whot eq 'true'){
	$_ =~ s/\n//g;
	$db->writeparam($_);  
      }elsif($db->whot eq 'false'){
	$db->writesql($_);        
      };     
    }
  }
};
if($@){
  print "0";
  print STDERR "$@";
}
  __END__