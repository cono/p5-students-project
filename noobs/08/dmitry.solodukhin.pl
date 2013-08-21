#!/usr/bin/perl -w 
use strict;

package Date;

sub new {
  my $class   = shift;
  my $getdate = shift; 
  my ($year, $month, $day);
  if(ref($getdate) eq "ARRAY"){
    $year  = $getdate->[0];
    $month = $getdate->[1];
    $day   = $getdate->[2];
  }elsif(ref($getdate) eq "HASH"){
    $year  = $getdate->{year};
    $month = $getdate->{month};
    $day   = $getdate->{day};
  }else{
  ($year, $month, $day) = (localtime)[5, 4, 3];
  $year = $year + 1900;
  $month++;
  }
  return if((!$day || !$year || !$month));
  return if($day =~ /[^\d]/g || $year =~/[^\d]/g || $month =~ /[^\d]/g);
  return if(31 < $day || $day <= 0 || 12 < $month || $month <=0);
  my $self = {year=>$year, month=>$month, day=>$day};

  return bless $self, $class;
}

sub year {
  my $self = shift;
  if (@_) {
        my $d = shift;
    if($d=~/^\d+$/){
      $self-> {year} = $d;
    }
  }
  return $self->{year};
}

sub month {
  my $self = shift;
  if (@_) {
        my $d = shift;
    if($d=~/^\d+$/){
      $self-> {month} = $d;
    }
  }
  return $self->{month};
}

sub day {
  my $self = shift;
  if (@_) {
    my $d = shift;
    if($d=~/^\d+$/){
      $self-> {day} = $d;
    }
  }
  return $self->{day};
}

sub get_struct {
  my $self = shift;
  return $self->{year}."/".$self->{month}."/".$self->{day};
}

package Calendar;

our @ISA=qw(Date);

sub add_years {
  my $self = shift;
  $self->{year} += shift;
  return $self;
}

sub add_months {
  my $self = shift;
  my $d    = shift;
  if($d){
    my $month    = $self->{month} + $d;
    $self->{month} = $month % 12;
    if(($month/12)>0){
      $self->add_years(int($month/12));
    }
  }
  return $self;
}

sub add_days {
  my $self = shift;
  my $d    = shift;
  if($d){
    my $day      = $self->{day} + $d;
    $self->{day} = $day % 30;
    if(($day/30) > 0){
      $self->add_months(int($day/30));
    }
  }
  return $self;
}

package main;
eval{
  my $test_file_path = $ARGV[0];
  open( FH, "<", "$test_file_path") or die "нет такого файла\n";  
  my $data;
  while(<FH>){ 
    $data .= $_;
  }
  eval($data);
  close(FH);
};
if($@){
  print STDERR "$@";
}