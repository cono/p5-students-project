#!/usr/bin/perl
sub spaceNormalizeStr {
	if ( scalar(@_) == 1 ) {
		my ($s) = @_;
		$s =~ s/^[\r\n\s]+//;
		$s =~ s/[\r\n\s]+$//;
		$s =~ s/\s{2,}|\n/ /g;
		return $s;
	}
	else {
		print "ERROR\n";
		print STDERR "Wrong number of parameters in spaceNormalizeStr \n";
		return 0;
	}
}
sub isNumeric {
	if ( scalar(@_) == 1 ) {
		my ($s) = @_;
		$varS = $s =~ m/^([+-]?(?:(?:\d+(?:\.\d*)?)|(?:\.\d+))(?:e[+-]?\d+)?)$/i;
		return $varS;
	}
	else {
		print "ERROR\n";
		print STDERR "Wrong number of parameters in isNumeric \n";
		return 0;
	}
}
sub vectorIsNumeric {
	$vector = shift;
	foreach $temp ( @$vector ) {
		if ( !isNumeric($temp) ) {
			return 0;
		}
	}
	return 1;
}
sub matrixMult {
	if ( scalar(@_) == 2 ) {
		my ($m1, $m2) = @_;
		my ($m1rows, $m1cols) = matrixDimension($m1) ;
		my ($m2rows, $m2cols) = matrixDimension($m2);
		unless ($m1cols == $m2rows) {
			print "ERROR\n";
			die "IndexError: Matrices don't match to multiply rule: $m1cols != $m2rows\n";
		}
		my $result = [];
		my ($i, $j, $k);
		for $i ( range($m1rows) ) {
			for $j ( range($m2cols) ) {
				for $k ( range($m1cols) ) {
					 $result->[$i][$j] += $m1->[$i][$k] * $m2->[$k][$j];
				}
			}
		}
		return $result;
	}
	else {
		print "ERROR\n";
		die "MatrixError: Should be 2 matrix\n";
	}
}

sub range {0 .. (@_[0] - 1) }
sub vectorLength {
	my $arrayRef = shift;
	my $type = ref $arrayRef;
	if ( $type ne "ARRAY" ) { 
		print "ERROR\n";
		die "$type is bad array ref for $arrayRef\n" 
	}
	return scalar(@$arrayRef);
}

sub matrixDimension {
	my $matrix = shift;
	my $rows = vectorLength($matrix);
	my $cols = vectorLength($matrix->[0]);
	for ( my $i = 1; $i < $rows; $i++ ) {
		$colsCurrent = vectorLength($matrix->[$i]);
		if ( $colsCurrent != $cols ) {
			print "ERROR\n";
			die "Matrix rows lengths are not equal\n" 
		}
	}
	return ($rows, $cols);
}
sub matrixPrint {
	my $matrix = shift;
	my $rows = vectorLength($matrix);
	my $cols = vectorLength($matrix->[0]);
	for (my $i = 0; $i < $rows; $i++ ) {
		for (my $j = 0; $j < $cols - 1; $j++ ) {
			print $matrix->[$i][$j].' ';
		}
		print $matrix->[$i][$cols - 1]."\n";
	}
}

unless (@ARGV) {
	print "ERROR\n";
	die "No data file" 
}
unless ( open(F1, $ARGV[0]) ) {
	print "ERROR\n";
	die "Open file data error\n $!";
}
@file = <F1>;
unless ( close(F1) ) { 
	print "ERROR\n";
	die $!
};
if ( scalar(@file) == 0) {
	print "ERROR\n";
	print STDERR "File $ARGV[0] no data\n";
}
else {
	my @a = ();
	my @b = ();
	$flagA = 1;
	$canMult = 1;
	$countSpaceLines = 0;
	foreach $m (@file) {
		$m = spaceNormalizeStr($m);
		if ( $m eq '' ) {
			if ( scalar(@a) == 0 ) {
				print "ERROR\n";
				print STDERR "First line is empty\n";
				$flagA = 1;
				$canMult = 0;
				last;
			} 
			elsif ( scalar(@b) == 0 ) {
				$flagA = 0;
				$countSpaceLines++;
				if ( $countSpaceLines > 1 ) {
					print "ERROR\n";
					print STDERR "More than one space between two matrixs\n";
					$canMult = 0;
					last;
				}
			}
			else {
				last;
			}
		}
		else { 
			my @data = split /\s+/, $m;
			if ( vectorIsNumeric(\@data) ) {
				if ( $flagA ) {
					push @a, \@data;
				}
				else {
					push @b, \@data;
				}
			}
			else {
				print "ERROR\n";
				print STDERR "Error in matrix data\n";
				$canMult = 0;
				last;
			}
		}
	}
	if ( $canMult ) {
		@res = matrixMult(\@a, \@b);
		matrixPrint(@res);
	}
}
