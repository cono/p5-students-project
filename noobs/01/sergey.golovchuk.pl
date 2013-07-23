#! /usr/bin/perl -w
use strict;

my $file = $ARGV[0];
my @digits = ( "0".."9", "A".."Z" );

open (FIN, "<", $file) or die "Can't open $file file: $!";

my $strings = 0;
while(my $line = <FIN>){
	++$strings;
	chomp($line);
	my $out = "";
	my $error = "";
	
	$line =~ s/\s+//g;
	
	if ($line =~ m/^0*\d,[0-9A-Za-z]+,\d+/){

		my ($operation, $digit, $base) = split(/,/, $line);
		my $result = "";
		
		if ($operation == 1){
			if ($digit =~ m/[A-Za-z]/){
				$out = "Error";
				$error = "Wrong numeric base at line ".$strings." file $file in operation 1";			
			} else {
				$digit = uc $digit;
				my @res = ();
				for (my $i = 0; $digit; ++$i){
					$res[$i] = $digit % $base;
					$digit = int ($digit / $base);
				}
				
				@res = reverse @res;
				
				foreach (@res){
					$result .= $digits[$_];
				}
				
				$out = $result;
			}
		} elsif ($operation == 2) {
		
			if(&checkWrongBase($digit, $base)){
				$out = "Error";
				$error = "Wrong numeric base at line ".$strings." file $file in operation 2";
			} else {
				my @digit = reverse split(//,$digit);
				my $index = 0;
				my $result = 0;
				
				foreach (@digit){
					
					for (my $i = 0; $i < $base; ++$i){
						
						if ($_ eq $digits[$i]){
							$result += $i * ($base ** $index);
						}
					}
					++$index;
				}
				$out = $result;
			}
		} else {
			$out = "Error";
			$error = "Wrong operation at line ".$strings." file $file";
		}
	} else {
		$out = "Error";
		$error = "Wrong data format at line ".$strings." file $file";
	}
	
	print STDOUT $out."\n";
	print STDERR $out.". ".$error."\n" if ($out eq "Error");
}

close (FIN);

sub checkWrongBase(){
	my $digit = shift;
	my $base = shift;
	
	my $pattern = join ("", @digits[int($base)..scalar(@digits - 1)]);

	return $digit =~ m/[$pattern]/;
}