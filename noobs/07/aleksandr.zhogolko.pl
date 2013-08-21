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
	$nameOfVar = spaceNormalizeStr($file[0]);
	$varName = $nameOfVar =~ m/^[a-z_]+[a-z_0-9]*$/i;
	if ( $varName ) {
		my $evalCodeText = '';
		for ( $i = 1; $i < scalar(@file); $i++ ) {
			$evalCodeText = $evalCodeText.$file[$i];
		}
		eval ($evalCodeText);
		MyDataDumper($$nameOfVar, 0, 1);
	}
	else {
		print "ERROR\n";
		print STDERR "Name of variable is not alphanumeric\n";
	}
}
sub printTabs {
	my $tabsCount = shift;
	for ( my $i = 0; $i < $tabsCount; $i++ ) {
		print "\t";
	}
}
$address = {};
sub MyDataDumper {
	my $start = shift;
	my $tabsCount = shift;
	my $isLast = shift;
	my $type = ref $start;
	$varAddress = $start =~ m/\w+\((.+?)\)/i;
	if ( $varAddress ) {
		if ( exists $address{$1} ) {
			if ( $isLast ) {
				print $type."\n";
			}
			else {
				print $type.",\n";
			}
			return 1;
		}
		$address{$1} = $type;
	}
	if ( $type eq "" ) {
		if ( $isLast ) {
			print "'".$start."'\n";
		}
		else {
			print "'".$start."',\n";
		}
	}
	elsif ( $type eq "SCALAR" ) {
		if ( $isLast ) {
			print "'".${$start}."'\n";
		}
		else {
			print "'".${$start}."',\n";
		}
	}
	elsif ( ($type eq "CODE") || ($type eq "Regexp") || ($type eq "GLOB") || ($type eq "LVALUE") || ($type eq "FORMAT") || ($type eq "IO") || ($type eq "VSTRING") ) {
		if ( $isLast ) {
			print $type."\n";
		}
		else {
			print $type.",\n";
		}
	}
	elsif ( $type eq "ARRAY" ) {
		my @A = @{$start};
		print "[\n";
		my $i = 1;
		foreach my $a (@A) {
			printTabs($tabsCount+1);
			MyDataDumper($a, $tabsCount+1, ($i == scalar(@A)));
			$i++;
		}
		printTabs($tabsCount);
		if ( $isLast ) {
			print "]\n";
		}
		else {
			print "],\n";
		}
	}
	elsif ( $type eq "HASH" ) {
		my %H = %{$start};
		my @H_keys = keys %H;
		@H_keys = sort @H_keys;
		print "{\n";
		my $i = 1;
		foreach my $H_k (@H_keys) {
			printTabs($tabsCount+1);
			print $H_k." => ";
			MyDataDumper($H{$H_k}, $tabsCount+1,($i == scalar(@H_keys)));
			$i++;
		}
		printTabs($tabsCount);
		if ( $isLast ) {
			print "}\n";
		}
		else {
			print "},\n";
		}
	}
	elsif ( $type eq "REF" ) {
		my $R = ${$start};
		print "REF:";
		MyDataDumper($R, $tabsCount);
	}
	else {
		my $O = $start;
		print $O->get_struct.",\n";
	}
}
