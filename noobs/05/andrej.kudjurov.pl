#!/usr/bin/perl

my $test_file_path = $ARGV[0];

package subs;
sub exi
{
	exit 0;
}
sub move
{
	my $tmp=0;
	if ((rename @_[0], @_[1]) and (scalar(@_)==2)){$tmp=1;}
	return $tmp;
}
sub copy
{
	my $tmp=0;
	if (open(my $ff, "<", @_[0]) and (scalar(@_)==2))
	{
		if (open(my $ft, ">", @_[1]))
		{
			while(<$ff>)
			{
				print $ft $_;
			}
			close $ff;
			close $ft;
			$tmp=1;
		}
	}
	return $tmp;
}
sub del
{
	my $tmp=0;
	if((scalar(@_)==1) and (unlink @_[0])){$tmp=1;}
	return $tmp;
}
sub pr
{
	my $tmp=0;
	if ((open(my $fh, "<", @_[0])) and (scalar(@_)==1))
	{
		my $buf="";
		while (<$fh>)
		{
			$buf.=$_;
		}
		close $fh;
		$tmp=$buf;
	}
	return $tmp;
}
sub srt
{
	my $tmp=0;
	if (open(my $fh, "<", @_[0]) and (scalar(@_)==1) and (@_[0]=~/^\w+\.\w+$/))
	{
		my @buf=();
		my $sbuf="";
		while(<$fh>)
		{
			push(@buf, $_);
		}
		@buf=sort @buf;
		for (my $i=0;$i<scalar(@buf);$i++){$sbuf.=$buf[$i];}
		$tmp=$sbuf;
	}
	elsif ((scalar(@_)==1) and (!(@_[0]=~/^\w+\.\w+$/)))
	{
		my @buf=split(/\n/,@_[0]);
		my $sbuf="";
		@buf=sort @buf;
		for (my $i=0;$i<scalar(@buf);$i++){$sbuf.=$buf[$i]."\n";}
		$tmp=$sbuf;
	}
	return $tmp;
}
sub sch
{
	$tmp=0;
	if (open(my $fh, "<", @_[1]) and (scalar(@_)==2) and (@_[1]=~/^\w+\.\w+$/))
	{
		my $sres="";
		while(<$fh>)
		{	
			my $buf=$_;
			if($buf=~/@_[0]/){$sres.=$buf;}
		}
		close $fh;
		$tmp=$sres;
	}
	elsif ((scalar(@_)==2) and (!(@_[1]=~/^\w+\.\w+$/)))
	{
		my @buf=split(/\n/,@_[1]);
		my $sbuf="";
		for (my $i=0;$i<scalar(@buf);$i++)
		{
			if ($buf[$i]=~/@_[0]/){$sbuf.=$buf[$i]."\n";}
		}
		$tmp=$sbuf;
	}
	return $tmp;
}
package main;
use subs;
sub doing
{
	my @q=@_;
	shift @q, @_[0];
	my $tmp=undef;
	my %as=("copy", 'subs::copy(@q)', "move", 'subs::move(@q)', "sort",  'subs::srt(@q)', "delete", 'subs::del(@q)', "search",  'subs::sch(@q)', "print",  'subs::pr(@q)', "exit", 'subs::exi(@q)');
	$tmp=eval($as{@_[0]});
	return $tmp;
}
open(FH, "<", "$test_file_path");
while (<FH>)
{
	my $com=$_;
	if ($com eq "\n"){print STDOUT "MySh::>\n";}
	if ($com ne "\n")
	{
	my @data=split(/\s*\|\s*/, $com);
	print STDOUT "MySh::>"."$com";
	my $red=0;
	my $stat=1;
	my $pipe=0;
	my $ans;
	my $rt;
	for (my $i=0; $i < scalar @data; $i++)
	{
		if (@data[$i]=~/>/g)
		{
			if ((scalar(@data)-1==$i) and ($data[$i]=~/\s*>\s*\w+\.\w+$/) and($data[$i]=~/print|sort|search/))
			{
				$red=1;
				$data[$i]=~s/\s*>\s*(.+$)//;
				$rt=$1;
			}
			else{$stat=0; $i = scalar @data;}
		}
		my @todo=split(/\s+/, $data[$i]);
		if ($pipe==1)
		{
			if (@todo[0] eq "sort")
			{
				if (scalar @todo==1){push @todo, $ans;}
			}
			elsif (@todo[0] eq "search")
			{
				if (scalar @todo==2){push @todo, $ans;}
			}
		}
		if ($stat!=0)
		{
			$ans=doing(@todo);
			if ($ans)
			{
				if (scalar(@data)-1==$i)
				{
					if (($ans!=1) and ($red!=1)){print STDOUT $ans;}
					elsif (($ans==1) and ($red!=1)){}
					elsif (($ans!=1) and ($red==1))
					{
						open(my $fr, ">", $rt);
						print $fr $ans;
					}
				}
				else{$pipe=1;}
			}
			else {$i = scalar @data; print STDOUT "0\n";}
		}
		else {$i = scalar @data; print STDOUT "0\n";}
	}
	}
}

