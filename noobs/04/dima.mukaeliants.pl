#!/usr/bin/perl -w
use strict;

my $file_string;
my $res = "";
my $errType = undef;
my $mySubStr;
my $mySubValuesStr;
my @arr = ();
my %hash = ();
my $resSubStr = '';

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
if( defined($file_string = <FH>)){
	if($file_string=~/#/){
		#die "ERROR: Substitution String contain comments.\n	$!"} #Если комент разрешен в этой строке: $file_string = $`;
		$errType = "Substitution String contain comments";
	}
	elsif($file_string!~/\s*?[a-zA-Z0-9]+?\s*?/){
		#die "ERROR: Substitution String doesn't contain correct data.\n	$!"
		$errType = "Substitution String doesn't contain correct data";
	}
	else{
		$file_string=~s/\s*//g;
		$mySubStr = $file_string;
	}
}
else{
	#die "ERROR: Substitution String is missing.\n	$!"
	$errType = "Substitution String is missing";
}
if(!$errType){
	while ( defined($file_string = <FH>)) {
		if($file_string=~/#/){$file_string = $`;}
		#проверить строку на правильные символы. Если она состоит только из них, то не конкатенировать
		$mySubValuesStr .= $file_string;
	}
}
close ( FH );

if(!$errType){
	if($mySubValuesStr){
		my $tmp = $mySubValuesStr;
		$tmp =~ s/\s*//g;
		if($tmp eq ''){
			print STDOUT "$mySubStr\n";
			exit;
		}
	}
	else{
		print STDOUT "$mySubStr\n";
		exit;
	}
}

if(!$errType){
	my $tmpA = 0;
	my $tmpB = '';
	my $currentElement = '';
	#подумать о том, что значение может содержать одни пробелы или вообще не существовать - УРА! не нужно по ТЗ. =)
	while($mySubValuesStr=~/(['"\s]{0,1}\w+?['"]{0,1}\s*?(=>|=)\s*?['"]{0,1}\w+?['"\s])/){
		$currentElement = $1;
		$tmpA = length $1;
		$tmpA += index($mySubValuesStr,$1);
		$tmpB = substr($mySubValuesStr, 0, $tmpA);
		$tmpB =~ s/(['"\s]{0,1}\w+?['"]{0,1}\s*?(=>|=)\s*?['"]{0,1}\w+?['"\s])/#/;
		$tmpB =~ s/\s*//g;
		if($tmpB =~ /[\w'"]/){last;}
		$mySubValuesStr = substr($mySubValuesStr, $tmpA);
		$currentElement =~ s/\s*//g;
		push @arr, $currentElement;
		#print "STRING:	[$currentElement]	$tmpA\n####################################\n";
	}
	$mySubValuesStr=~s/\s*//g;
	if($mySubValuesStr ne ''){
		#print "::::::::::::::::::::::::::::::::::::\n		ERROR\n::::::::::::::::::::::::::::::::::::\n		$mySubValuesStr\n::::::::::::::::::::::::::::::::::::\n"
		$errType = "Hash element contain Space or Unnecessary Quotes";
	}
}
if(!$errType){
	#print "\nMy HASH:\n";
	for(my $i=0; $i<scalar(@arr); $i++){
		my($key,$val) = split(/=>|=/,$arr[$i]);
		if($key =~ /['"]/ && $key !~ /('\w+'|"\w+")/){
			#print "$key	=>	$val	WRONG KEY!\n";
			$errType = "In hash element has don't match quotes [KEY: |$key|]";
		}
		elsif($val =~ /['"]/ && $val !~ /('\w+'|"\w+")/){
			#print "$key	=>	$val	WRONG VALUE!\n";
			$errType = "In hash element has don't match quotes [VALUE: |$val|]";
		}
		else{
			$key =~ s/['"]*//g;
			$val =~ s/['"]*//g;
			$hash{$key}=$val;
			#print "$key	=>	$val\n";
		}
	}
}
if(!$errType){
	#print "REVERSE SORT: \n";
	#foreach my $key (reverse sort keys %hash){ print "$key: $hash{$key}\n"; }	
	while($mySubStr ne ''){
		my $tmpValue = '';
		my $tmpKeyLenght = 0;
		foreach my $key (reverse sort keys %hash){
			if($mySubStr =~ /^($key)/){
				$tmpValue = $hash{$key};
				$tmpKeyLenght = length $key;
				last;
			}
		}
		if($tmpValue ne ''){
			$resSubStr .= $tmpValue;
			$mySubStr = substr($mySubStr, $tmpKeyLenght);
		}
		else{
			$mySubStr =~ /^(\w)/;
			$resSubStr .= $1;
			$mySubStr = substr($mySubStr, 1);
		}
		#print "\nRESULT:\n$mySubStr\n$resSubStr\n\n";
	}
}

if($errType){$res = '0';}
else{$res = $resSubStr}

print STDOUT "$res\n";
print STDERR "ERROR: $test_file_path : $errType \n\n" if ($res=~/0/);




















