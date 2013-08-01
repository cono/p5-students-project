#!/usr/bin/perl
die "No data file" unless @ARGV;
open(F1, $ARGV[0]) or die "Open file data error\n $!";
@file = <F1>;
close(F1) or die $!;
$m = $file[0];
$m =~ s/^[\r\n\s]+//;
$m =~ s/[\r\n\s]+$//;
$m =~ s/\s{2,}|\n/ /g;
$startLine = $m;
if ( $startLine eq "" ) {
	print "0\n";
	die "First line is empty. It must containes substitution string./n";
}
$varStartLine = $startLine =~ m/\s*([A-Za-z]+)\s*/i;
$realStartLine = $1;
if ( !($realStartLine eq $startLine) ) {
	print "0\n";
	die "First line containes spaces. It's wrong. /n";
}
#print "$m\n";
$hashIndex = 0;
for ( $i = 1; $i < scalar(@file); $i++ ) {
	$m = $file[$i];
	$m =~ s/^[\r\n\s]+//;
	$m =~ s/[\r\n\s]+$//;
	$m =~ s/\s{2,}|\n/ /g;

	$varM = $m =~ m/\s*(.*?)\s*\#/i;
	if ( $varM ) {
		$m = $1;
	}
	if ( !($m eq "") ) {
		#print "$m\n";
		@keyValue = split /\s*(?:=>|=)\s*/, $m;
		if ( scalar(@keyValue) == 1 ) {
			print "0\n";
			die "Hash data error. Spliter or hash value error found in $hashIndex hash elements\n";
		}
		else {	
			$key = $keyValue[0];
			$varKey = $key =~ m/^\s*(["']?)([A-Za-z0-9]+)(["']?)\s*$/;
			#print "$1 $2 $3\n";
			if ( $varKey ) {
				if ( !($1 eq $3) ) {
					print "0\n";
					die "Quotes in hash key $hashIndex are not the same.\n";				
				}
				$realKey = $2;
			}
			else {
				print "0\n";
				die "Hash key $hashIndex is not alphanumeric.\n";
			}		
			
			$value = $keyValue[1];
			$varValue = $value =~ m/^\s*(["']?)([A-Za-z0-9]+)(["']?)\s*$/;
			
			if ( $varValue ) {
				if ( !($1 eq $3) ) {
					print "0\n";
					die "Quotes in hash value $hashIndex are not the same.\n";				
				}
				$realValue = $2;
			}
			else {
				print "0\n";
				die "Hash value $hashIndex is not alphanumeric.\n";
			}		
			$hashData{$realKey} = $realValue;	
			$hashIndex++;
		}
	}
}
@dataKey = keys %hashData;
@dataKey = reverse (sort @dataKey);
$resultLine = '';
foreach $temp (@dataKey) {
	$var = $startLine =~ s/$temp/$hashData{$temp}/ge;
}
print "$startLine\n";
