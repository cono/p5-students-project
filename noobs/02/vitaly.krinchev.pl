#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
my ($i,$n,$pr,$z,$e,$res,$x)='';
my @mass = ();
my %hash = ();
my $flag=0;
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) {
$n=$_;
$_=~s/\s*//g;
if ($_ eq '') {print STDOUT "error";print STDERR "Пустая строка";exit;}
	
	 $_=~/^(\w+)/;
	if ($1 ne $_) {print STDOUT "error";print STDERR "В строке содержатся символы не удовлетворяющие условию задачи";exit}
	$n=~s/\r//g; $n=~s/\n//g; 
	$_=$n; 

	do{ # Замена разделительных символов на один пробел
		$n=$_; $_=~s/  / /; $_=~s/\t/ /;}
	while ($n ne $_);

	@mass=split/ /,$_; $pr=' ';
	while (($pr ne '') || (@mass > 0)){
		$pr=shift @mass;
		$e=1;
		for ($z=0;$z<=@mass;$z++){
			if (($pr eq $mass[$z]) && ($pr ne '')) {$e++;$mass[$z]=''; }
		}
		%hash = (%hash,$pr,"*" x $e) if ($pr ne '');
	}
	$z=0;
	foreach $z(sort keys %hash){
		print "$z $hash{$z}\n"; #отсортирует в алфавитном порядке по значениям ключа
	}
		print STDERR "" if ( $res eq 'error' );
		$flag=1;
exit if ( <FH>  ne '') ; 
}
if ($flag == 0) {print STDOUT "error";print STDERR "Пустая строка";}
close ( FH );
