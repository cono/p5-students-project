#!/usr/bin/perl -w
use strict;
use Data::Dumper;

sub mmult  {
  my ($m1,$m2) = @_;
  my ($m1rows, $m1cols) = matdim($m1 ) ;
  my ($m2rows, $m2cols) = matdim($m2);
  unless ($m1cols == $m2rows) {    # Инициировать исключение
  die "IndexError: matrices don't match: $m1cols colums != $m2rows rows";
  }
  my $result = [];
  my ($i, $j, $k);
  for $i (range($m1rows)) {
    for $j (range($m2cols)) {
		for $k (range($m1cols)) {
			 $result->[$i][$j] += $m1->[$i][$k] * $m2->[$k][$j];
		}
	}
	
  }
  return $result;
  print "\n";
}

sub range {0 .. ($_[0] - 1) }
sub veclen {
  my $ary_ref = $_[0];
  my $type = ref $ary_ref;
  if ($type ne "ARRAY") {die "$type is bad array ref for $ary_ref";
	}
  return scalar(@$ary_ref);
}

sub matdim {
  my $matrix = $_[0];
  my $rows = veclen($matrix);
  my $cols = veclen($matrix->[0]);
  return ($rows, $cols);
}

my $test_file_path = $ARGV[0];
my $coun=0;
my $cnt=0;
my $x;
my @x;
my $y;
my @y;
my $temp=0;
open( FH, "<", "$test_file_path") or die "Can not open file: $!\nUsage: ./multiply_matrix.pl <matrix_file_1>";
 
while ( <FH> ) {	
		unless ( $_ =~ /^$/ ) {
			if ($temp==0){
				if ($_=~/[\d, ]/){
					my @xx=split(/ /,$_);
					my $xx=\@xx;
					
					$x[$coun]=$xx;
					$coun++;
				}
				else{
				print STDOUT "ERROR";
				print STDERR "Not numeric";
				$_="";
				}
			}
			elsif ($temp==1){
				if ($_=~/[\d, ]/){
				my @yy=split(/ /,$_);
				my $yy=\@yy;
				
				$y[$cnt]=$yy;
				$cnt++;
				}
				else{
				print STDOUT "ERROR";
				print STDERR "Not numeric";
				
				}
			 # Строка не пустая
				} else {
			 # Строка пустая
					last;
				}
			}
			else {
			# Строка пустая 
				 $temp=1;
			 next;
			}
		}
close ( FH );
	$x=\@x;
	$y=\@y;
	
my $z = mmult($x, $y);
my @array=@{$z};
my $count;
my $leng=@array;

for ($count=0;$count<$leng;$count++){ # ВЫВОД результата
my $zz;
$zz=$array[$count];
print "@{$zz}\n"; # Вывести исходные данные
}