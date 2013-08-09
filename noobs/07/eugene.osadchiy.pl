#!/usr/bin/perl -w
use strict;
my @path;
sub Dump {
	my $tab = shift;
	my $hash_tab = shift;
	if("HASH" eq ref $_[0]) {
		
		foreach my$item (@path)
		{
			if($item eq $_[0])
			{
				return "HASH";
			}			
		}
		push @path, $_[0];
		
		my %hash = %{$_[0]};
		my $i = 0;
		my $keys_count = scalar (keys %hash);
		print "{\n";
		$tab++;
		foreach my$item (sort keys %hash) {
			$i++;
			print "\t" x $tab . "$item => ";
			if($i!=$keys_count) {
				print Dump($tab, 0, $hash{$item});
				print ",\n";
			}
			else {
				print Dump($tab, 0, $hash{$item}) . "\n";
			}
		}
		$tab--;
		print "\t" x $tab . "}";
		
		pop @path;
		
		return;
	}
	elsif("ARRAY" eq ref $_[0]) {
		print "[\n";
		my @array = @{$_[0]};
		
		foreach my$item (@path)
		{
			if($item eq $_[0])
			{
				return "ARRAY";
			}			
		}
		push @path, $_[0];
		
		$tab++;
		for (my$item = 0; $item < scalar(@array) - 1; $item++)
		{
			print Dump($tab, 1, $array[$item]) . ",\n";
		}
		print Dump($tab, 1, $array[scalar(@array) - 1]) . "\n";
		$tab--;
		print "\t" x $tab . "]";
		
		pop @path;
		
		return;
	}
	elsif("" eq ref $_[0]) {
		return "\t" x ($tab*$hash_tab) . "\'$_[0]\'";
	}
	elsif("SCALAR" eq ref $_[0]) {
		return "\t" x ($tab*$hash_tab) . "\'${$_[0]}\'";
	}
	elsif("REF" eq ref $_[0]) {
		print "\t" x ($tab*$hash_tab) . "REF:";
		
		foreach my$item (@path)
		{
			if($item eq $_[0])
			{
				return "REF\n";
			}			
		}
		push @path, $_[0];
		
		my $temp = ${$_[0]};
		print Dump($tab, 0, ${$_[0]});
		
		pop @path;
		
		return;
	}
	elsif("Regexp" eq ref $_[0])
	{
		return "Regexp";
	}
	elsif("CODE" eq ref $_[0])
	{
		return "CODE";
	}
	else {
		eval { $_[0]->isa("UNIVERSAL"); };
		if ( $@=~/unblessed/ ) {
			return;
        } else {
                print $_[0]->get_struct;
				return;
        }		
	}
}


my $test_file_path = $ARGV[0];
open (FH, "<", "$test_file_path") or die "Can not open test file: $!";

my $variable = <FH>;
chomp($variable);
if($variable =~ /^\s*(\w+)\s*$/)
{
	$variable = $1;
}
else
{
	die "Error. Not found variable";
}
push @path, "$variable";
my $file_program;


while(<FH>) {
	$file_program .= $_;
}

close (FH);
$file_program =~ /([\$\@\%]\b$variable\b)/;
if(defined($1)) {
	$variable = $1;
}
else {
	exit 0;
}
$file_program = "my $variable;\n" . $file_program . "print Dump(0, 1, $variable);";
eval ($file_program);
if ($@) {
	die "Error in eval $@";
}
print "\n";