#!/usr/bin/perl -w
use strict;

sub Observe();

my $file_path = $ARGV[0];

my $FH;

open($FH, "<", $file_path) or die "Can not open file \"$file_path\".\n";

my $variable = <$FH>;
chomp($variable);


my $initCode = do {
	local $/=undef;
	<$FH>;
};
close($FH);

my $temp = eval "my ".$initCode."return (\$".$variable.");"; 

my $dumpString = &Observe($temp,0,$temp);
print STDOUT "$dumpString\n";

exit 0;


sub Observe()
{
	my ($param, $level, $self) = @_;	
	my $result;
	my $node = ref($param);
	
	if ($node eq 'HASH')
	{
		$result .= "{\n";
		my @key = sort keys %$param;		
		for(my $i = 0; $i < scalar(@key); $i++)
		{
			my $type = ref($param->{$key[$i]});
			my $subNode = $type;
			 
			if ($type eq '')
			{
				$subNode = "\'".$param->{$key[$i]}."\'";
			}
			elsif ($param->{$key[$i]} == $self)
			{
				$subNode = $type;
			}
			else
			{
				$subNode = &Observe($param->{$key[$i]}, $level+1, $self);
			}			
			$result .= ("\t" x ($level+1)) . "$key[$i] => $subNode";
			$result .= "," unless ($i == (scalar(@key)-1));
			$result .= "\n";
		}
		$result .= ("\t" x $level) . "}";
	}
	elsif ($node eq 'ARRAY')
	{
		$result .= "[\n";
		my $size = scalar(@$param);
		#################
		
		for(my $i = 0; $i < $size; $i++)
		{
			my $type = ref($param->[$i]);
			my $subNode = $type;
			 
			if ($type eq '')
			{
				$subNode = "\'".$param->[$i]."\'";
			}
			elsif ($param->[$i] == $self)
			{
				$subNode = $type;
			}
			else
			{
				$subNode = &Observe($param->[$i], $level+1, $self);
			}			
			$result .= ("\t" x ($level+1)) . "$subNode";
			$result .= "," unless ($i == ($size-1));
			$result .= "\n";
		}
		
		#################
		$result .= ("\t" x $level) . "]";
	}
	elsif ($node eq 'REF')
	{
		$result .= "REF:";
		my $type = ref($$param);
		
		my $subNode = $type;
		 
		if ($type eq '')
		{
			my $temp = $$param;
			$subNode = "\'".$temp."\'";
		}
		elsif ($$param == $self)
		{
			$subNode = $type;
		}
		else
		{
			$subNode = &Observe($$param, $level, $self);
		}
		$result .= $subNode;
	}
	elsif ($node eq 'SCALAR')
	{
		$result .= "\'".$$param."\'";
	}
	elsif ($node eq 'CODE')
	{
		$result .= "$node";
	}
	elsif ($node eq 'GLOB')
	{
		$result .= "$node";
	}
	elsif ($node eq 'LVALUE')
	{
		$result .= "$node";
	}
	elsif ($node eq 'FORMAT')
	{
		$result .= "$node";
	}
	elsif ($node eq 'IO')
	{
		$result .= "$node";
	}
	elsif ($node eq 'VSTRING')
	{
		$result .= "$node";
	}
	elsif ($node eq 'Regexp')
	{
		$result .= "$node";
	}
	elsif ($node eq '')
	{
		$result .= "\'$param\'";
	}
	else 
	{		
		$result .= "'".$param->get_struct()."'";
	}
	
	return $result;
}
