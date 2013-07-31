#!/usr/bin/perl
die "No data file" unless @ARGV;
open(F1, $ARGV[0]) or die "Open file data error\n $!";
@file = <F1>;
close(F1) or die $!;
if ( scalar(@file) == 0) {
	print STDERR "File $ARGV[0] no data\n";
}
else {
	$strN = 0;
	foreach $m (@file) {
		$m =~ s/\n//gi;
		@data = split /\s*,\s*/, $m;
		$dataLength = $#data + 1;
		if ( $dataLength == 3 ) {
			$a = $data[0];
			$varA = $a =~ m/^\s*([+-]?(?:(?:\d+(?:\.\d*)?)|(?:\.\d+))(?:e[+-]?\d+)?)/i;
			$realA = $1;
			$b = $data[1];
			$varB = $b =~ m/^\s*([+-]?(?:(?:\d+(?:\.\d*)?)|(?:\.\d+))(?:e[+-]?\d+)?)/i;
			$realB = $1;
			$c = $data[2];
			$varC = $c =~ m/^\s*([+-]?(?:(?:\d+(?:\.\d*)?)|(?:\.\d+))(?:e[+-]?\d+)?)/i;
			$realC = $1;
			if ( $varA && $varB && $varC && $realA eq $a && $realB eq $b && $realC eq $c ) {
				$d = $b*$b - 4 * $a * $c;
				if ( $d < 0 ) {
					print "0\n";
				}
				else {
					$sqrtD = sqrt $d;
					if ( $d == 0 ) {
						$x = -$b / (2 * $a);
						print "1 ($x)\n";
					}
					else {
						$x1 = (-$b + $sqrtD) / (2 * $a);
						$x2 = (-$b - $sqrtD) / (2 * $a);
						print "2 ($x1 $x2)\n";
					}
				}
			}
			else {
				print STDERR "File $ARGV[0]. Line $strN. Digit data error\n";
			}
		}
		else {
			print STDERR "File $ARGV[0] data input error. Line $strN error\n"
		}
		$strN++;
	}
}