#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my %result;
my $point;
my $res;
eval{
  my $i = 0;

  while ( <FH> ) {
    
    $i++;
    if($i == 1) {
	die "Error bad symbols at start point - \"$_\" \n" if(!$_);
	die "Error bad symbols at start point - \"$_\" \n" if(index($_, /^[A-Za-z0-9_]$/) || $_ eq defined);
	$_ =~ s/\n*//g;
	$point = $_;
      }elsif($i == 2){
      die "Error bad data \n" if(!$_);
      
	$_ =~ s/\s//g;
	my $string = $_;
	%result = map{split "=>", $_}split(",", $string);
      }elsif($i>2){
	die "very big file";
      }

  };
  $res = $point;
  do{
    my $ky = $result{$point};
    die "Error bad data \n" if(!$ky);
    $point = $ky;
    die "$res-$point \n looped" if(!index($res, $point));
    $res  .= "-".$ky;
    
  }while(exists($result{$point}));
};
if( $@ ){
  print STDERR "$@";
}else{print $res."\n"};