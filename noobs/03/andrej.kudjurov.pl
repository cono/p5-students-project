#!/usr/bin/perl
use warnings;
use strict;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $start=<FH>;
my $hdata=<FH>;
chop $start;
$_=$hdata;
my @wds=m/\w+/g;
my %hash=();
my $loop=0;
my $flag=1;
for (my $i=0;($i+1)<scalar(@wds);$i+=2)
{
	$hash{$wds[$i]}=$wds[$i+1];
}
$_=$hdata;
my @mass=/(\w+=>\w+)/g;
if ((scalar(@mass))!=(scalar(keys %hash))){$flag=0;}
if (($start eq '') or ($start eq "\n") or ($hdata eq '') or ($hdata eq "\n")){$flag=0;}
$_=$hdata;
undef @mass;
@mass=m/=>+/g;
if ((scalar(@mass))!=(scalar(keys %hash))){$flag=0;}
$_=$hdata;
undef @mass;
@mass=m/,/g;
if ((scalar(@mass))!=(scalar(keys %hash)-1)){$flag=0;}
my $res=$start;
my $errdesc='';
my @way=($res);
my $buf=$res;
my $is=0;
if ($flag==1){
for (my $i=0;$i<scalar(keys %hash);$i++)
{
	if (defined($hash{$buf}) and ($loop==0))
	{
		$buf=$hash{$buf};
		for (my $i1=0;$i1<scalar(@way);$i1++)
		{
			if ($way[$i1] eq $buf){$is=1;}
		}
		if ($is==0){push(@way,$buf);}
		else {$loop=1;$i=scalar(keys %hash);push(@way,$buf);}
	}
	elsif (!defined($hash{$buf}))
	{
		$res="error";
		$errdesc="there no way through";
		$i=scalar(keys %hash);
	}
	
}
if (($loop==0) and ($res ne "error")){$res=join("-",@way);}
elsif (($loop==1) and ($res ne "error")){$res=join("-",@way)."\n"."looped";}
}
elsif ($flag==0)
{
	$res="error";
	$errdesc="input error";
}
print STDOUT "$res\n";
print STDERR "$errdesc\n" if ( $res eq 'error' );
close ( FH );