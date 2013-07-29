#!/usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $file_string = <FH>;
my @arr = split(/\s+/, $file_string);

my $res = "";
my $errType = undef;
my %hash;
my @outputArr;

foreach my $i (@arr){
	if($i !~ /^[a-zA-Z0-9]+$/){
		$res = 'error';
		$errType = "Symbols array haw non-alphanumeric element(s). Element = $i \n";
	}
}
if(!$errType){
	for (my $i=0; $i<(scalar(@arr)); $i++){
		#можно c циклом
		my $tmpHashVal = '';
		for (my $elmCount=0; $elmCount<scalar(@arr); $elmCount++){
			if($arr[$i] eq $arr[$elmCount]){
				$tmpHashVal .= '*';
			}
		}
		$hash{$arr[$i]} = $tmpHashVal;
		#а можно и без него
		#бить строку с элементами по текущему элементу
		my $tmp = '# '.join(' # ',@arr).' #';
		my @tmp = split(' '.$arr[$i].' ', $tmp);
		my $tmpSumm = scalar(@tmp) - 1;
		$hash{$arr[$i]} = scalar("*"x$tmpSumm);		
	}


	my $i = 0;
	while ( my ($key, $value) = each(%hash) ) {
		$outputArr[$i] = "$key $value";
		$i++
	}
	my @new_array = sort @outputArr;
	for ($i=0; $i<scalar(@new_array); $i++){
		print $new_array[$i]."\n";
	}
};

print STDOUT "$res\n";
print STDERR "ERROR: $test_file_path : $errType \n\n" if ( index(lc($res),'error') >= 0 );	

close ( FH );