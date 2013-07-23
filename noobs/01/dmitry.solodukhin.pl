#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];

open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my @array = (0..35);
my %hash  = ();
my $sim = "A";

for(my $i = 0; $i <= 9; $i++){
	$hash{$i} = $i;
}

for(my $i = 10; $i <= 35; $i++){
	$hash{$sim}  = $i;
	$array[$i] = $sim++;
}
my $res = 0;
my $i   = 0;

while ( <FH> ) {
	
	$i++;
	my $result = "";
	my $error  = "";
	$res       = 0;
	my @a      = ();
	$_         =~ s/\s*//g;
	uc;
	if (!$_){
		$res   = 1; 
		$error = "Пустая строка - $i";
	}else{
		my @b = (0,0,0);
		my @a = split(',');
		push(@a, @b);
		for(my $j = 0; $j <= 2; $j++) {
			if($a[$j] eq ""){
				print STDERR "Error - нехватает данных в строке $i \n"; 
				$res   = 1;
				last;
			 }
			  
		}
		next if($res == 1);
		if($a[0] < 1 || $a[0] > 2 || $a[2] < 2  || $a[2] > 36){
			$res   = 1;
			$error = "Неизвестно в какую систему переводить число в $i строке";
		}else{
			if($a[0] == 1){
				if($a[1] =~ /[^0-9]/ || $a[2] =~ /[^0-9]/){
					print STDERR "Error - неверные данные в $i строке \n"; 
					next;
				}
				$result = out10th($a[1], $a[2]);
			}else{
				$result  = in10th($a[1], $a[2]);
				$result .= "\n";
				
				if($result eq "Error\n"){
					$res    = 1;
					$error  = "неверное число перевода в $i строке";
					$result = "";
				}
			}	
		}
	}

    print STDOUT $result;

    print STDERR "Error - ".$error." \n" if ( $res eq 1 );

}

sub in10th
{
	my $i      = length($_[0]);
	my $result = 0;
	my $j      = 0;
	while($i > 0){
		my $name = substr($_[0],$i-1,1);
		
		if(int($hash{$name}) > $_[1] || !(exists $hash{$name})){
			$result = "Error";
			last;
		}
		
		$result += int($hash{$name})*(int($_[1]**$j));
		$j++;

		$i--;
	}
	return $result;
}

sub out10th
{
	my $result = "";
	while($_[0] > $_[1]){
		$result = @array[($_[0] % $_[1])].$result;
		$_[0]   = $_[0]/$_[1];
	}
	$result = @array[$_[0]].$result."\n";
	return $result;
}