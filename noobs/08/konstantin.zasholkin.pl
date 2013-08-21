#!/usr/bin/perl -w
use strict;

package Date;
use Date::Calc qw(check_date);
sub new{
  
  my $class = shift;
  my $self = { };
  
  if (@_) {
    my $param = shift;
    
    if (ref($param) eq "HASH") {
      if ( !exists($param->{year}) or !exists($param->{month}) or !exists($param->{day}) ) { return undef }
      elsif( !check_date($param->{year}, $param->{month}, $param->{day}) ) { return undef }
      $self = $param;
    }
    elsif(ref($param) eq "ARRAY") {
      if ( !defined($param->[0]) or !defined($param->[1]) or !defined($param->[2])) { return undef }
      elsif( !check_date($param->[0], $param->[1], $param->[2]) ) { return undef }
      $self->{year}= $param->[0];
      $self->{month}= $param->[1];
      $self->{day}= $param->[2];
    };
  }
  else {
    my ($mday, $month, $years) = (localtime(time))[3,4,5];
    $self->{year} = $years + 1900;
    $self->{month} = $month + 1;
    $self->{day} = $mday; 
  }

  bless($self, $class);
  return $self
}

sub year{
  my $self = shift;
  
  if(scalar(@_) == 0){ return $self->{year}; }
  else{
    my $temp_year = shift;
    if ( check_date($temp_year, $self->{month}, $self->{day}) ) { $self->{year} = $temp_year }
  }
}

sub month{
  my $self = shift;
  
  if(scalar(@_) == 0){ return $self->{month}; }
  else {
    my $temp_month = shift;
    if ( check_date($self->{year}, $temp_month, $self->{day}) ) { $self->{month} = $temp_month }
  }
}

sub day{
  my $self = shift;
  
  if(scalar(@_) == 0){ return $self->{day}; }
  else{
    my $temp_day = shift;
    if ( check_date($self->{year}, $self->{month}, $temp_day) ) { $self->{day} = $temp_day }
  }
}

sub get_struct{
  my $self = shift;
  return "$self->{year}/$self->{month}/$self->{day}";
}



package Calendar;
use Date::Calc qw(Add_Delta_YM);
use Date::Calc qw(Add_Delta_Days);
use Date::Calc qw(check_date);

our @ISA = qw/Date/;

sub add_months{
  my $self = shift;
  my $delta_months = shift;
  
  ($self->{year}, $self->{month}, $self->{day}) = Add_Delta_YM($self->{year}, $self->{month}, $self->{day}, 0, $delta_months);

  return $self;
}

sub add_years{
  my $self = shift;
  my $delta_years = shift;
   
  ($self->{year}, $self->{month}, $self->{day}) = Add_Delta_YM($self->{year}, $self->{month}, $self->{day}, $delta_years, 0);
  
  return $self;
}

sub add_days{
  my $self = shift;
  my $delta_days = shift;
  
  ($self->{year}, $self->{month}, $self->{day}) = Add_Delta_Days($self->{year}, $self->{month}, $self->{day}, $delta_days);
   
  return $self;
}



($#ARGV == 0) or die "Missing file name";
my $test_file_path = $ARGV[0];

open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

local $/;
my $file = <FH>;

close(FH);

my $res = eval($file);
if (!defined($res)) { printError("$@"); exit 1 }


sub printError
{
  print STDOUT "ERROR\n";
  print STDERR "$_[0]\n";            
}
