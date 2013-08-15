#! /usr/bin/perl

use warnings;

use Data::Dumper;

my $file = $ARGV[0];

my $var;
my $value;
my %refs = ();

if (not -s $file){

	print STDOUT "ERROR\n";
	print STDERR "empty file\n";
	exit 1;
}

open my $fh, "<", $file or die "Can not open file $file: $!";

$var = <$fh>;
$var =~ s/^\s+|\s+$//;

$value .= $_ while(<$fh>);

close $fh;

if ($var !~ m/^[a-zA-Z_]\w*$/){

	print STDOUT "ERROR\n";
	print STDERR "wrong variable or empty first line\n";
	exit 1;
}

eval $value;

if ($@){

	print STDOUT "ERROR\n";
	print STDERR "wrong code\n";
	exit 1;
}

if (not defined $$var){
	
	print STDOUT "ERROR\n";
	print STDERR "not defined variable\n";
	exit 1;	
}

&my_Dumper(0, $$var);

print STDOUT "\n";

sub my_Dumper{
	
	my $deep = shift;
	my $value = shift;
	
	if (ref($value) eq "SCALAR"){
		
		print STDOUT "\'$$value\'";
	} elsif (ref($value) eq "ARRAY"){
		
		if (exists($refs{$value})){
		
			print STDOUT "ARRAY";
		} else {
			$refs{$value}++;
			#----------------
			my @arr = @$value;
			#----------------
			print STDOUT "[\n";
			while (@arr){
			
				$_ = shift @arr;
				print STDOUT "\t" x ($deep + 1);
				&my_Dumper($deep + 1, $_);
				scalar(@arr)? print STDOUT ",\n" : print STDOUT "\n";
			}
			print STDOUT "\t" x $deep, "]";	
		}
			
	} elsif (ref($value) eq "HASH"){

		if (exists($refs{$value})){
		
			print STDOUT "HASH";
		} else {
			$refs{$value}++;
			#----------------
			my @arr = sort keys %$value;
			#----------------			
			print STDOUT "{\n";
			while (@arr){
				$_ = shift @arr;
				print STDOUT "\t" x ($deep + 1),"$_ => ";
				&my_Dumper($deep + 1, $value->{$_});
				scalar(@arr)? print STDOUT ",\n" : print STDOUT "\n";
			}
			print STDOUT "\t" x $deep,"}";
		}
		
	} elsif (ref($value) eq "CODE" or
			 ref($value) eq "Regexp"){
		
		print STDOUT ref($value);
	} elsif (ref($value) eq "REF"){
		
		if (exists($refs{$value})){
		
			print STDOUT "REF";
		} else {
			$refs{$value}++;
			
			print STDOUT "REF:";
			&my_Dumper($deep, $$value);
		}
		
	} elsif (ref($value) ne ""){
		
		if ($value->get_struct() ne ""){
			&my_Dumper($deep, $value->get_struct());
		} else {
			print STDOUT "\'".$value->get_struct()."\'";
		}
	} else {
		defined($value)? print STDOUT "\'$value\'" : print STDOUT "''";
	}
}
