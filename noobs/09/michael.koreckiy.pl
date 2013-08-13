#!/usr/bin/perl -w
use strict;

use Data::Dumper;
use DBI;

sub dbsel($$);
sub dbreq($$);

my $file_path = shift @ARGV if @ARGV;
my $handle;
open ($handle, "<", $file_path) or die "Error! Can not open file: \"$file_path\"";
my @settings;
for (my $itr = 0; $itr < 5; $itr++)
{
	local $_ = <$handle>;
	chomp;
	push @settings, $_;
}

my $dbh = eval { DBI->connect("DBI:mysql:database=$settings[2]:host=$settings[0]:port=$settings[1]",
	$settings[3], $settings[4],
	{
		RaiseError => 1,
		PrintError => 0,
		AutoCommit => 0 });
};

if ($@)
{
	print STDOUT "0\n";
	print STDERR "Huston, we have a problem: $@.\n";
	exit 1;
}	
	
while (<$handle>)
{
	my $request;
	my $params;
	chomp;
	if ($_ =~ /^\s*$/)
	{
		next;
	}
	
	if ($_ =~ /^\s*--\s*sql\s*$/)
	{
		my $command = do
		{
			local $/ = '-- end';
			local $_ = <$handle>;			
		};
		#print "-- sql\n$command\n";
		if ($command =~ /-- param(.*)-- end\s*$/s)
		{
			$request = $`;
			$params = $1;
			unless ($request =~ /\?/)
			{
				print STDERR "Wrong content of file.\n";
				print STDOUT "0\n";
				exit 1;
			}
			#print "$request - $params\n";
		}
		elsif ($command =~ /^\s*(.*)-- end\s*$/s)
		{
			$request = $1;
			if ($request =~ /\?/)
			{
				print STDERR "Wrong content of file.\n";
				print STDOUT "0\n";
				exit 1;
			}
		}
		
		if ($request =~ /^\s*select/i)
		{
			dbsel($request, $params);
		}
		#print "$request  $params\n";
		else
		{
			dbreq($request, $params);
			
		}
		#print "$request\n";
	}
	else
	{
		print STDERR "Wrong content of file.\n";
		print STDOUT "0\n";
		exit 1;
	}
}
		
$dbh->disconnect();



sub dbsel($$)
{
	my $param;
	my @params;
	my $select;
	if ($_[0])
	{
		$select = shift;
		chomp $select;
		#print "$_\n";
	}
	my $sth = $dbh->prepare($select);
	
	if ($_[0])
	{
		$param = shift;		
		$param =~ s/^\s*//;
		@params = split(/\n/,$param);
		foreach (@params)
		{
			my @p = split(/,/);
			eval {
			unless ($sth->execute(@p))
			{
				print STDERR "Execution was faild.\n";
				print STDOUT "0\n";
				exit 1;
			}};
			
			if ($@)
			{
				print STDOUT "0\n";
				print STDERR "Error: $@\n";
				exit 1;
			}
			
			while (my $ans = $sth->fetchrow_arrayref)
			{				
				my @string;
				foreach my $key (@$ans)
				{
					push @string, $key;
				}
			print join('|', @string)."\n";
				
			}
		}
	}
	else
	{
		eval {
			unless ($sth->execute)
			{
				print STDERR "Execution was faild.\n";
				print STDOUT "0\n";
				exit 1;
			}
		};
		
		if ($@)
		{
			print STDOUT "0\n";
			print STDERR "Error: $@\n";
			exit 1;
		}
		
		while (my $ans = $sth->fetchrow_arrayref)
		{
			my @string;
			foreach my $key (@$ans)
			{
				push @string, $key;
			}
			print join('|', @string)."\n";
			#print Dumper($ans)."\n";
		}
	}		
	$sth->finish;
}

sub dbreq($$)
{
	my $param;
	my @params;
	my $select;
	if ($_[0])
	{
		$select = shift;
		chomp $select;
		#print "$_\n";
	}
	else
	{
	
	}
	
	if ($_[0])
	{
		$param = shift;		
		$param =~ s/^\s*//;
		@params = split(/\n/,$param);
		foreach (@params)
		{
			my @p = split(/,/);
			eval {
				unless ($dbh->do($select,undef,@p))
				{
					print STDERR "Execution was faild.\n";
					print STDOUT "0\n";
					exit 1;
				}
			};
			
			if ($@)
			{
				print STDOUT "0\n";
				print STDERR "Error: $@\n";
				exit 1;
			}
		}
	}
	else
	{
		eval {
			unless ($dbh->do($select))
			{
				print STDERR "Execution was faild.\n";
				print STDOUT "0\n";
				exit 1;
			}
		};
		
		if ($@)
		{
			print STDOUT "0\n";
			print STDERR "Error: $@\n";
			exit 1;
		}
		
	}		
}