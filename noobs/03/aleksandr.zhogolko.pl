#!/usr/bin/perl
die "No data file" unless @ARGV;
open(F1, $ARGV[0]) or die "Open file data error\n $!";
$line1 = <F1>;
$line1 =~ s/^[\r\n\s]+//;
$line1 =~ s/[\r\n\s]+$//;
if ( $line1 eq '' ) {
	print "error\n";
	die "No start key found in first line.\n";
}
$varLine1 = $line1 =~ m/\s*([A-Za-z]+|\d+)\s*/i;
if ( $varLine1 ) {
	$realLine1 = $1;
	if ( !($realLine1 eq $line1) ) {
		print "error\n";
		die "Start key is not one word.\n";
	}
}
else {
	print "error\n";
	die "Start key is not digit or word.\n";
}
$line2 = <F1>;
$line2 =~ s/^[\r\n\s]+//;
$line2 =~ s/[\r\n\s]+$//;
if ( $line2 eq '' ) {
	print "error\n";
	die "No hash data found in second line.\n";
}
close(F1) or die $!;
@data = split /\s*,\s*/, $line2;
if ( scalar(@data) == 0 ) {
	print "error\n";
	die "Hash data error. No data in hash string\n";
}
$hashIndex = 0;
foreach $temp (@data) {
	@keyValue = split /\s*=>\s*/, $temp;
	if ( scalar(@keyValue) == 1 ) {
		print "error\n";
		die "Hash data error. Spliter or hash value error found in $hashIndex hash elements\n";
	}
	else {
		$key = $keyValue[0];
		$varKey = $key =~ m/\s*([A-Za-z]+|\d+)\s*/i;
		if ( $varKey ) {
			$realKey = $1;
			if ( !($realKey eq $key) ) {
				print "error\n";
				die "Hash key $hashIndex is not one word in one of the hash elements.\n";
			}
		}
		else {
			print "error\n";
			die "Hash key $hashIndex is not digit or word in one of the hash elements.\n";
		}		
		
		$value = $keyValue[1];
		$varValue = $value =~ m/\s*([A-Za-z]+|\d+)\s*/i;
		if ( $varValue ) {
			$realValue = $1;
			if ( !($realValue eq $value) ) {
				print "error\n";
				die "Hash value $hashIndex is not one word in one of the hash elements.\n";
			}
		}
		else {
			print "error\n";
			die "Hash value $hashIndex is not digit or word in one of the hash elements.\n";
		}		
		$extendHashData{$key} = $value;
	}
	$hashIndex++;
}

$start = $line1;
$notStop = 1;
$s = '';
$loopFlag = '';
while ( $notStop ) {
	$notStop = 0;
	$s = $s.'-'.$start;
	#print "$s\n";
	if ( exists $extendHashData{$start} ) {
		if ( exists $startPoints{$start} ) {
			$loopFlag = 'looped';
		}
		else {
			$startPoints{$start} = 1;
			$notStop = 1;
		}
		$start = $extendHashData{$start};
	}
}
$s = substr($s, 1);
if ( $s eq $line1 ) {
	print "error\n";
	die "No start key found. Data file $ARGV[0] error. Line 1\n";
}
else {	
	print "$s\n";
	print "$loopFlag\n";
}
