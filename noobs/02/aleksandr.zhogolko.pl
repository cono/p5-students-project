#!/usr/bin/perl
die "No data file" unless @ARGV;
open(F1, $ARGV[0]) or die "Open file data error\n $!";
@file = <F1>;
close(F1) or die $!;
if ( scalar(@file) == 0) {
	print "error\n";
	print STDERR "File $ARGV[0] no data\n";
}
else {
	foreach $m (@file) {
		$m =~ s/\n//gi;
		@data = split /\s+/, $m;
		my @new_array = sort @data;
		foreach $temp (@new_array) {
			$temp1 = $temp;
			$temp1 =~ s/([a-zA-Z_0-9]+)//ge;
			if ( $temp1 eq '' ) {
				if ( exists $extendHashData{$temp} ) {
					$extendHashData{$temp} = $extendHashData{$temp} + 1;
				}
				else {
					$extendHashData{$temp} = 1;
					push @result, $temp;
				}
			}
			else {
				print "error\n";
				print STDERR "$temp - The data do not match the pattern\n";
			}
		}
		foreach $temp (@result) {
			$s = '';
			for ($i = 0; $i < $extendHashData{$temp}; $i++ ) {
				$s = $s.'*';
			}
			print $temp.' '.$s."\n";
		}
	}
}