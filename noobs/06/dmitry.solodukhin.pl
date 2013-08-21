#!/usr/bin/perl -w 
use strict;
use warnings;
my $test_file_path = $ARGV[0];
eval{

sub range {0 .. ($_[0] - 1)}

#проверка данных
sub validate {
  my $ary_ref = $_[0];
  my $type = ref ($ary_ref);
  if ($type ne "ARRAY") {
    die "$type нам не подходит\n";
  }
  return scalar(@$ary_ref);
}

sub check {
  my $rows = validate($_[0]);
  my $i;
  my $cols = validate($_[0]->[0]);
  for $i(range($rows)){
    my $cols2 = validate($_[0]->[$i]);
    die "несовпадение типов матриц" if($cols != $cols2);
  }
  return ($rows, $cols);
}

sub calck {
  my ($rows1,$cols1) = check($_[0]);
  my ($rows2,$cols2) = check($_[1]);
  if ($cols1 != $rows2) { 
    die "несовпадение типов матриц $cols1 != $rows2\n";
  }
  my ($i, $j, $k);
  for $i (range($rows1)) { 
    for $j (range($cols2)) { 
    my $f = 0;
      for $k (range($cols1)) {
	$f += $_[0]->[$i][$k] * $_[1]->[$k][$j];
      }
    print "$f ";
    }
    print "\n";
  } 
}

  open( FH, "<", "$test_file_path") or die "нет такого файла\n";
  my $razdel = 0;
  my $m1 = [];
  my $m2 = [];
  while(<FH>){   
    die "is bad data from this script\n" if(/[^\+\d\s\n\.eE-]/g);
    die "ploho" if(/\d\-/g || /\.+\d\.+/g || /\d\+/g);
    if(/^\n$/){
      $razdel++;
      next;
    };
    my $arr = [];
    my @d = split(/\s+/);
    push(@$arr , @d); 
    if($razdel == 0){
      push(@$m1 , $arr); 
    }elsif($razdel == 1){
      push(@$m2 , $arr);
    }else{
      last;
    }
  }
  close(FH);
    calck($m1, $m2);   
};

if($@){
  print STDOUT "ERROR \n";
  print STDERR $@;
};