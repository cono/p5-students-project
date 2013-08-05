#!/usr/bin/perl -w
use strict;
use constant INVITE => q(MySh::>);

package MySh::Com;

sub copy()
{
	my $result;
	my $hS;
	my $hD;
	my $source;
	my $dest;
	my $temp = $_[0];
	my $prevResult = $_[1];
	my @some;
	@$prevResult = @some;
	if (@$temp == 3)
	{
		my $source = @$temp[1];
		my $dest = @$temp[2];		
		unless (open($hS, "<", "$source"))
		{
			print STDERR "copy: Can not open file \"$source\".\n";
			return $result = -1;
		}
		unless (open($hD, ">", "$dest"))		
		{
			print STDERR "copy: Can not open file \"$dest\".\n";
			return $result = -1;
		}
		while (<$hS>)
		{
			print $hD "$_";
		}
		close ($hS);
		close ($hD);	
		$result = 0;
	}
	else
	{
		print STDERR "copy: Wrong parameters for \"copy\".\n";
		$result = -1;
	}
	
	return $result;	
}

sub move(\@\@)
{
	my $result;
	my $hS;
	my $hD;
	my $source;
	my $dest;
	my $temp = $_[0];
	my $prevResult = $_[1];
	my @some;
	@$prevResult = @some;
	if (@$temp == 3)
	{
		my $source = @$temp[1];
		my $dest = @$temp[2];	
		unless (open($hS, "<", "$source"))
		{
			print STDERR "move: Can not open file \"$source\".\n";
			return $result = -1;
		}
		unless (open($hD, ">", "$dest"))		
		{
			print STDERR "move: Can not create file \"$dest\".\n";
			return $result = -1;
		}
		while (<$hS>)
		{
			print $hD "$_";
		}
		close ($hS);
		close ($hD);
		unlink "$source";		
		$result = 0;
	}
	else
	{
		print STDERR "move: Wrong parameters.\n";
		$result = -1;
	}	
	return $result;		
}

sub print(\@\@)
{
	my $hS;
	my $result;		
	my $temp = $_[0];
	my $prevResult = $_[1];
	my @clear;
	@$prevResult = @clear;
	if (@$temp == 2)
	{
		my $source = @$temp[1];		
		unless (open($hS, "<", "$source"))
		{
			print STDERR "print: Can not open file \"$source\".\n";
			return $result = -1;
		}
		else
		{
			while (<$hS>)
			{
				push @$prevResult, $_;
			}
			$result = 0;
		}
	}
	else
	{
		print STDERR "print: Wrong parameters.\n";
		$result = -1;
	}	
	return $result;		
}

sub delete(\@)
{
	my $result;		
	my $temp = $_[0];
	my $prevResult = $_[1];
	
	if (@$temp > 1)
	{
		shift @$temp;
		foreach (@$temp)
		{
			my $source = $_;		
			unless (unlink "$source")
			{
				print STDERR "delete: file \"$source\" is not exists.\n";
				$result = -1;
			}
		}
		unless (defined $result)
		{
			$result = 0;
		}
	}
	else
	{
		print STDERR "delete: Wrong parameters.\n";
		$result = -1;
	}
	my @some;
	@$prevResult = @some;
	return $result;		
}

sub sort(\@\@)
{
	my $result;	
	my @sorted;
	my $hS;
	my $temp = $_[0];
	my $prevResult = $_[1];
	
	if (@$temp == 2)
	{
		my $source = @$temp[1];		
		unless (open($hS, "<", "$source"))
		{
			print STDERR "sort: Can not open file \"$source\".\n";
			return $result = -1;
		}
		while (<$hS>)
		{
			chomp;
			push @sorted, "$_\n";
		}
		close $hS;
		@$prevResult = sort @sorted;
		$result = 0;
	}
	elsif (@$temp == 1)
	{
		@sorted = map {chomp; $_ = "$_\n";}@$prevResult;
		@$prevResult = sort @sorted;
		$result = 0;
	}
	else
	{
		print STDERR "sort: Wrong parameters.\n";
		$result = -1;
	}
	
	return $result;		
}

sub search(\@\@)
{
	my $result;
	my $hS;	
	my $source;
	my $temp = $_[0];
	my $object = @$temp[1];
	my $prevResult = $_[1];
	my @some;
	if (@$temp == 3)
	{
		@$prevResult = @some;		
		my $source = @$temp[2];		
		unless (open($hS, "<", "$source"))
		{
			print STDERR "search: Can not open file \"$source\".\n";
			return $result = -1;
		}		
		while (<$hS>)
		{
			chomp;
			push @some, "$_\n";
		}
		close ($hS);
		@$prevResult = grep {index($_, $object) >= 0} @some;	
		$result = 0;
	}
	elsif (@$temp == 2)
	{		
		@some = map {chomp; $_ = "$_\n";}@$prevResult;
		my @clear;
		@$prevResult = @clear;
		@$prevResult = grep {index($_, $object) >= 0} @some;
		$result = 0;
	}
	else
	{
		print STDERR "search: Wrong parameters.\n";
		$result = -1;
	}
	
	return $result;	
}

sub out(\@)
{
	exit 0;
}

package main;

my $handle;

if (defined $ARGV[0])
{
	my $test_file_path = $ARGV[0];
	open($handle, "<", "$test_file_path") || die "Can not open test file: $!";	
}
else
{
	$handle = "STDIN";
}

print STDOUT INVITE;

my %funcRef = ( 'copy' => \&MySh::Com::copy,
				'delete' => \&MySh::Com::delete,
				'move' => \&MySh::Com::move,
				'search' => \&MySh::Com::search,
				'exit' => \&MySh::Com::out,
				'print' => \&MySh::Com::print,
				'sort' => \&MySh::Com::sort );

while ( <$handle> ) {
	chomp;
	if ($handle ne "STDIN")
	{
		print STDOUT "$_\n";
	}
	#else {print STDOUT "\n";}
	
	#&{$funcRef{$1}}() if ($_ =~ /^\s*(\w+)\s*$/);
	if ($_ =~ /^\s*((\w+)(\s+([^\|>\s]+))*)(\s*\|\s*(\w+)(\s+([^\|>\s]+))*)*(\s*>\s*[^\|>\s]+)?\s*$/) #$_ =~ /^(\s*\w+\s*(\s*(\.?\/)?\w*(\.\w+)*\s*)*)(\|\4)*(>\s*\w+(\.\w+)*)?$/)   (sort|print|copy|delete|move|search|exit)       #/^\s*(\w+)\s*(\|\s*([\w\.]+)\s*)*(>\s*\w*(\.\w+)*)?\s*$/
	{
		my $hOut;
		my $commands;
		my $output;
		my @comands;
		if ($_ =~ />/)
		{
			$commands = $`;
			$output = $';			
		}	
		else
		{
			$commands = $_;
		}
		
		unless (defined $output)
		{
			$hOut = *STDOUT;
		}
		if ($commands =~ /\|/)
		{
			#print "split | \n";
			@comands = split(/\s*\|\s*/, $commands);
			#print "@comands\n";
		}
		else 
		{
			$comands[0] = $commands;
		}
		#print "Comands: ".scalar(@comands)."\n";
		my $error;
		my $errMessage;
		my $result;
		my @tmpResult;
		for (my $itr = 0; scalar(@comands) > $itr; $itr++)
		{
			#print "$comands[$itr]\n";
			my @temp = split(/\s+/,$comands[$itr]);
			if (exists $funcRef{$temp[0]})
			{
				#print "comand & parameters: @temp\n";				
				$result = &{$funcRef{$temp[0]}}(\@temp, \@tmpResult);    #################################################### *FUNC INVOKING
				if ($result == -1)
				{
					$error = "0\n";
					last;
				}
			}
			else
			{
				my $temp = shift @temp;
				$error = "0\n";
				print STDERR "Error! Command \'$temp\' is not exists.\n";				
			}
		}		
		if (defined $error)
		{
			print STDOUT "$error";			
		}
		else		
		{
			if (defined $output)
			{
				$output =~ s/\s*//g;
				unless (open($hOut, ">", "$output"))
				{
					print STDERR "Error! Can  not open file \"$output\" for writing.\n";
					print STDOUT "0\n";
				}
				else
				{
					local $" = "";
					print $hOut "@tmpResult";
				}
			}
			else
			{
				local $" = "";
				print $hOut "@tmpResult";	
			}
		}
		
	}
	else 
	{
		if ($_ =~ /^\s*$/)
		{
			print STDOUT INVITE;
			next;
		}
		print STDOUT "0\n";
		print STDERR "Error! Wrong line \"$_\".\n";
	}
	print STDOUT INVITE;
	
}