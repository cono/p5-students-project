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
	@extendData = ("A".."Z");
	$i = 10;
	foreach $temp (@extendData) {
		$extendHashData{$temp} = $i;
		++$i;
	}
	foreach $m (@file) {
		$m =~ s/\n//gi;
		@data = split /\s*,\s*/, $m;
		$dataLength = $#data + 1;
		if ( $dataLength == 3 ) {
			$toFromDec = $data[0] + 0;
			$varToFromDec = $toFromDec =~ m/^\s*(\d+)/i;
			$realToFromDec = $1;
			$x = $data[1];
			$varX = $x =~ m/\s*([a-zA-Z0-9]+)/i;
			$realX = $1;
			$radix = $data[2] + 0;
			$varRadix = $radix =~ m/(\d+)/i;
			$realRadix = $1;
			#print "$toFromDec $x $radix\n";
			#print "$realToFromDec $realX $realRadix\n";
			if ( $varToFromDec && $varX && $varRadix && $realToFromDec eq $toFromDec && $realX eq $x && $realRadix eq $radix ) {
				if ( ($toFromDec == 1) || ($toFromDec == 2) ) {
					if ( $radix >= 2 && $radix <= 36 ) {
						$radixCheck = $radix;
						if ( $toFromDec == 1 ) {
							$radixCheck = 10;
						}
						@digitData = split (/ */, $x);
						#print "@digitData\n";
						$digitDataLength = $#digitData + 1;
						if ( checkDataRadix($radixCheck) ) {
							if ( $toFromDec == 1 ) {
								#from DEC
								@result = ();
								while ( $x != 0 ) {
									$ost = $x % $radix;
									if ( $ost > 9 ) {
										$ost = $extendData[$ost-10];
									}
									push @result, $ost;
									$x = int( $x / $radix );
								}
								print reverse(@result)."\n";
							} 
							elsif ( $toFromDec == 2 ) {
								#to DEC
								@reverseDigitData = reverse(@digitData);
								$result = 0;
								for ( $i = 0; $i < $digitDataLength; $i++ ) {
									$d = "\U$reverseDigitData[$i]\E";
									if ( exists $extendHashData{$d} ) {
										$result = $result + $extendHashData{$d} * ($radix ** $i);
									}
									else {
										$result = $result + $d * ($radix ** $i);
									}
								}
								print "$result\n";
							}
						}
						else {
							print STDERR "File $ARGV[0] data input error. Line $strN error. Data of the second parameter exceeds the radix\n"	
						}
					}
					else {
						print STDERR "File $ARGV[0] data input error. Line $strN error. Radix must be greater than 2 but less than 36\n"
					}
				}
				else {
					print STDERR "File $ARGV[0] data input error. Line $strN error.  The first parameter of translation in an incorrect value, the permissible value of 1 or 2\n"
				}
			}
			else {
				print STDERR "File $ARGV[0]. Line $strN. Digit data error\n";
			}
		}
		else {
			print STDERR "File $ARGV[0] data input error. Line $strN error. \n"
		}
		$strN++;
	}
}
sub checkDataRadix {
	my $myRadix = $_[0];
	$flag = 1;
	$i = 0;
	while ( $flag && $i < $digitDataLength ) {
		$d = "\U$digitData[$i]\E";
		#print "$d\n";
		if ( exists $extendHashData{$d} ) {
			$flag = $extendHashData{$d} < $myRadix;
		}
		else {
			$flag = $d < $myRadix;
		}
		$i++;
	}
	return $flag;
}