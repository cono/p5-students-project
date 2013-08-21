#!/usr/bin/perl

sub doing
{
eval{
	my $ql = @_[0];
	my $qvar = @_[1];
	my $sth = $dbh->prepare($ql);
		if (defined @_[1]) 
		{
			my @qv = ();
			if ($qvar=~/,/)
			{
			$qvar=~s/\n//;
			@qv=split(/,/, $qvar);
			for (my $i=0; $i<scalar @qv; $i++){
			$sth->bind_param($i+1, $qv[$i]);}
			$sth->execute();
			}
			else
			{
			@qv = split(/\n/,$qvar);
			$sth->execute_array({},\@qv);
			}
		}
		else{$sth->execute;}
		if ($ql=~/select/i)
		{
			while (my @ans = $sth->fetchrow_array)
			{
				for (my $i=0; $i < scalar @ans; $i++)
				{
					print STDOUT $ans[$i];
					if ($i!=scalar(@ans)-1){print STDOUT "|";}
				}
				print STDOUT "\n";
			}

		}
	$sth->finish;
};
if ($@){print STDOUT "0\n"; die "$@\n";}
}
$file=$ARGV[0];
open (FH, "<", $file);
$host = <FH>;
chop $host;
$port = <FH>;
chop $port;
$DBn = <FH>;
chop $DBn;
$uname = <FH>;
chop $uname;
$pass = <FH>;
chop $pass;

use DBI;
my $dsn="DBI:mysql:database=$DBn;host=$host;port=$port";
eval{
our $dbh=DBI->connect($dsn,$uname,$pass,{PrintError=>0, RaiseError=>1});
};
if ($@){print STDOUT "0\n"; die "$@\n";}
if (!defined $dbh){print STDOUT "0\n"; die "Error in connection data\n";}

my $beg = 0;
my $val = 0;
my $end = 1;
my $holder = "";
my $par = "";
while (<FH>)
{
	my $tmp=$_;
	if ($tmp eq "-- sql\n")
	{
		if ($end == 1)
		{
			$beg = 1;
			$end = 0;
		}
		else{print STDOUT "0\n"; die "unexpected command\n";}
	}
	elsif ($tmp eq "-- param\n")
	{
		if ($beg == 1)
		{
			$val = 1;
		}
		else{print STDOUT "0\n"; die "unexpected command\n";}
	}
	elsif ($tmp eq "-- end\n")
	{
		if (($end == 0) and ($beg == 1))
		{
			$beg = 0;
			$end = 1;
			if ($val == 0){doing($holder);}
			else{doing($holder, $par);}
			$holder = "";
			$par = "";
			$val = 0;
		}
		else{print STDOUT "0\n"; die "unexpected command\n";}
	}
	elsif (($beg == 1) and ($val == 0) and ($tmp ne "\n"))
	{
		$holder.=$tmp;
	}
	elsif (($beg == 1) and ($val == 1) and ($tmp ne "\n"))
	{
		$par.=$tmp;
	}
}
