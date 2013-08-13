#!/usr/bin/perl

use DBI;
sub spaceNormalizeStr {
	if ( scalar(@_) == 1 ) {
		my ($s) = @_;
		$s =~ s/^[\r\n\s]+//;
		$s =~ s/[\r\n\s]+$//;
		$s =~ s/\s{2,}|\n/ /g;
		return $s;
	}
	else {
		print "0\n";
		print STDERR "Wrong number of parameters in spaceNormalizeStr \n";
		return 0;
	}
}
sub countNeedParams { #count ?
	if ( scalar(@_) == 1 ) {
		my ($s) = @_;
		my $cnt = $s =~ tr/\?/\?/;
		return $cnt;
	}
	else {
		print "0\n";
		print STDERR "Wrong number of parameters in countNeedParams \n";
		return 0;
	}	
}
sub countPlacedParams {
	if ( scalar(@_) == 1 ) {
		my ($s) = @_;
		my @data = split /\s*,\s*/, $s;
		return scalar(@data);
	}
	else {
		print "0\n";
		print STDERR "Wrong number of parameters in countPlacedParams \n";
		return 0;
	}
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
sub range {0 .. (@_[0] - 1) }
sub vectorLength {
	my $arrayRef = shift;
	my $type = ref $arrayRef;
	if ( $type ne "ARRAY" ) { 
		print "0\n";
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
			print "0\n";
			die "Matrix rows lengths are not equal\n" 
		}
	}
	return ($rows, $cols);
}
sub matrixTransp {
	if ( scalar(@_) == 1 ) {
		my ($m1) = @_;
		my ($m1rows, $m1cols) = matrixDimension($m1);
		my $result = [];
		my ($i, $j, $k);
		for $i ( range($m1rows) ) {
			for $j ( range($m1cols) ) {
				$result->[$j][$i] = $m1->[$i][$j];
			}
		}
		return $result;
	}
}

sub range {0 .. (@_[0] - 1) }
unless (@ARGV) {
	print "0\n";
	die "No data file" 
}
unless ( open(F1, $ARGV[0]) ) {
	print "0\n";
	die "Open file data error\n $!";
}
my @file = <F1>;
unless ( close(F1) ) { 
	print "0\n";
	die $!
};
if ( scalar(@file) == 0) {
	print "0\n";
	die "File $ARGV[0] no data\n";
}
else {
	my $hostname = spaceNormalizeStr($file[0]);
	my $port = spaceNormalizeStr($file[1]);
	my $database = spaceNormalizeStr($file[2]);
	my $user = spaceNormalizeStr($file[3]);
	my $password = spaceNormalizeStr($file[4]);
	my $spaceDelim = spaceNormalizeStr($file[5]);
	my $dsn = "DBI:mysql:database=".$database.";host=".$hostname.";port=".$port;
	my $dbh;
	eval {
		$dbh = DBI->connect($dsn, $user, $password,
							{
								RaiseError => 1,
								PrintError => 0,
							}
				);
	};
	if ( $@ ) {
		print "0\n";
		die "Error DB connection\n";
	}
	if ( $dbh->ping ) {
		my $fileLength = scalar(@file);
		my $i = 6;
		my $sqlText = "";
		while ( $i < $fileLength ) {
			$fileRow = spaceNormalizeStr($file[$i]);
			if ( $fileRow eq "-- sql" ) {
				$sqlText = "";
				$i++;
				while ( not($fileRow eq "-- end") && ($i < $fileLength) ) {
					$fileRow = spaceNormalizeStr($file[$i]);
					$sqlText = $sqlText.$fileRow." ";
					$i++;
				}
				$sqlText =~ s/\s+--\s+end\s+//;
			}
			my $varSql = $sqlText =~ m/(\w+)\s+(.+?)(?:\s+--\s+param\s+(.+?))*$/i;
			my $sqlCommand = $1;
			my $sqlCommandExt = $2;
			my $sqlParams = $3;
			my $sqlT = $sqlCommand." ".$sqlCommandExt;
			my $sth = $dbh->prepare($sqlT);
			my $sqlParamCnt = countNeedParams($sqlT);
			if ( $sqlParams eq "" ){
				eval {
					$sth->execute();
				};
				if ( $@ ) {
					print "0\n";
					die "Can not execute sql query\n";
				}
			}
			else {
				my @data = split /\s+/, $sqlParams;
				my @fetchArray = ();
				foreach $dataValue (@data) {
					my @dataComa = split /\s*,\s*/, $dataValue;
					if ( $sqlParamCnt == scalar(@dataComa) ) {
						push @fetchArray, \@dataComa;
					}
					else {
						print "0\n";
						die "Count of params in sql text and -- param section are different\n";
					}
				}
				@fetchArray = matrixTransp(\@fetchArray);
				$arrayRef = shift @fetchArray;
				
				for ( $k = 0; $k < scalar(@$arrayRef); $k++ ) {
					$sth->bind_param_array($k+1, $arrayRef->[$k]);
				}
				eval {
					$sth->execute_array( {} );
				};
				if ( $@ ) {
					print "0\n";
					die "Can not execute sql query\n";
				}
			}
			if ( $sqlCommand eq 'select' ) {
				while ( my $ans = $sth->fetchrow_hashref ) {
					@keysRecord  = sort (keys %{$ans});
					my $s = "";
					for  $key (@keysRecord) {
						$s = $s.$ans->{$key}."|"
					}
					$s =~ s/[\|]+$//;
					print "$s\n";
				}
			}
			$sth->finish;
			$i++;
		}
		$dbh->disconnect;
	}
	else {
		print "0\n";
		die "Pinged error\n";
	}
	$dbh->disconnect;
	
}