#!/usr/bin/perl -w
#use strict;
#use Data::Dumper;


sub recursia {
	my $element = shift;
	my $flag = shift;
	if(ref $element){
		foreach my $wayElement (@array){ if($wayElement eq $element){ $element = ref $element; $loop = 'found'; } }
	}
	if(ref $element eq 'HASH'){
		push @array, scalar($element);
		print "{\n";
		my $i = 0;
		$tabas .= "\t";
		$comma = ',';
		
		foreach my $subElt (sort keys %{$element}){
			my $numberOfLines = scalar(keys(%{$element}));
			print $tabas."".$subElt." => ";
			++$i;
			if($i == $numberOfLines){$comma = '';  recursia($element->{$subElt},'true');}
			#print " [".$numberOfLines."] [$i] [$comma] ";
			else{recursia($element->{$subElt});}
		}
		$tabas =~ s/\t//;
		print $tabas."}";
	}
	elsif(ref $element eq 'ARRAY'){
		push @array, scalar($element);
		print "[\n";
		my $i = 0;
		$tabas .= "\t";
		$comma = ',';
		
		foreach my $subElt (@{$element}){
			my $numberOfLines = scalar(@{$element});
			print $tabas;
			++$i;
			if($i == $numberOfLines){$comma = ''; recursia($subElt,'true');}
			#print " [".$numberOfLines."] [$i] [$comma] ";
			else{recursia($subElt);}
		}
		$tabas =~ s/\t//;
		print $tabas."]";
	}
	elsif(ref $element eq 'REF'){
		push @array, scalar($element);
		print "REF:";
		recursia($$element);
	}
	elsif($loop){print $element;$loop='';}
	elsif(ref $element eq 'CODE'){print "CODE";}
	elsif(ref $element eq 'Regexp'){print "Regexp";}
	elsif(ref $element eq 'SCALAR'){print "'".$$element."'";}
	elsif( ref $element && (ref $element ne 'GLOB' || ref $element ne 'LVALUE' || ref $element ne 'FORMAT' 
							|| ref $element ne 'IO' || ref $element ne 'VSTRING') ){print "'".$element->get_struct."'"}
	else{print "'".$element."'";}
	if($flag && ref $element ne 'REF'){print "\n";}
	elsif(ref $element ne 'REF'){print $comma."\n";}
	$comma = ',';
}

my $test_file_path;
if(@ARGV){$test_file_path = $ARGV[0];}
else{print STDOUT "ERROR\n"; die "No incoming parameters\n";}
unless( open( FH, "<", $test_file_path) ){print STDOUT "ERROR\n"; die "Can not open file: $!";}
my $dumpThis = <FH>;
$dumpThis =~ s/^\s+?//;
$dumpThis =~ s/\s+?$//;
unless($dumpThis){print STDOUT "ERROR\n"; die "in incoming file not have argument for dumper\n";}
my $incomingCode = '';
while ( defined(my $file_string = <FH>) ) { $incomingCode .= $file_string; }
unless( close ( FH ) ){print STDOUT "ERROR\n"; die "Can not clouse file: $!";}
eval ($incomingCode);
if($@){print STDOUT "ERROR\n"; die $@."\n";}


recursia($$dumpThis,"HUY");
