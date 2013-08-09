#!/usr/bin/perl 

use warnings;

my $fl = $ARGV[0];
if(!$fl || ! -f $fl ){
	print STDERR "Usage: $0 <filename>\n";
	exit;
}

open(my $fh, '<', $fl) || die "Can't open file $fl\n";
my $line = <$fh>;
chomp $line;

my $code_block = "";
while(<$fh>){
	$code_block .= $_;
}

eval($code_block);

no strict "refs";
my $var = $$line;

my $checked_refs = {};

sub dump {
	my $var = shift;
	my $indent = shift;

	$indent = $indent ? $indent : 1;
	my $ref = ref $var;
	
	if($ref){
		$checked_refs->{"$var"} = $checked_refs->{"$var"} ? $checked_refs->{"$var"} + 1 : 1 ;

		if($checked_refs->{"$var"} && $checked_refs->{"$var"} > 1){
			return "$ref";
		}
	}

	my $out = "";
	if($ref eq 'SCALAR'){
		$out .= "'" .  $$var . "'";
	}elsif($ref eq 'ARRAY'){
		$out .= "[" . "\n" 
		. join(",\n", map("\t" x $indent . &dump($_, $indent + 1), @$var)) 
		. "\n" . "\t" x ($indent - 1) . "]";
	}elsif($ref eq 'HASH'){
		$out .= "{" . "\n" 
		. join(",\n", map("\t" x $indent. $_ . " => " . &dump($var->{$_}, $indent + 1), sort {uc($a) cmp uc($b)} keys %$var))
		. "\n". "\t" x ($indent - 1) . "}";
	}elsif($ref eq 'REF'){
		$out = "REF:" . &dump($$var, $indent);
	}elsif($ref && UNIVERSAL::can($var, "can") && $ref->can("get_struct")){
		$out .= &dump($var->get_struct(), $indent);
	}elsif($ref){
		$out .= $ref;
	}else{
		$out .= "'$var'";
	}

	return $out;
}

print &dump($var) . "\n";
