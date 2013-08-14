#!/usr/bin/perl -w
#task_02
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", $test_file_path) or die "Can not open test file: $!";

while ( <FH> ) {
if ($_  ne "\n")
{	
	my @a=split (' ', $_);
	@a=sort @a;
	my $buf=$a[0];
	my $count=0;
	s/\s//g;
	my $FalseCount=s/\W//ig;
	if (!$FalseCount)
	{		
		foreach(@a)
		{
			if ($_ eq $buf)
			{
				$count++;
			}
			else
			{
				print STDOUT "$buf ".'*' x $count . "\n";
				$buf=$_;
				$count=1;
			}
		}
		print STDOUT "$buf ".'*' x $count . "\n";
	}
	else
	{
		print STDOUT "error\n";
		print STDERR "Wrong input string\n";
	}
	do
	{
	 local $"="\n";	
	};
	last;
	}
	else
	{
		print STDOUT "error\n";
		print STDERR "Empti string\n";
	}
	
}
close ( FH );
