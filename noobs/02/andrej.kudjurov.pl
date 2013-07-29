#!/usr/bin/perl

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $line=<FH>;
chop $line;
my @work=split(/ /,$line);
my @check=split(//,$line);
my @chm=(A..Z,a..z,0..9,' ','_',"\t");
my $flag=1;
my %hash=();
my $res='';
my $errdesc='';
my $i=0;
my $i1=0;
if (length($line)==0){$flag=0;print "1";}
for ($i=0;$i<scalar(@check);$i++)
{
	my $tf=0;
	for ($i1=0;$i1<scalar(@chm);$i1++)
	{
		if ($check[$i] eq $chm[$i1]){$tf=1;}
	}
	if ($tf==0){$flag=0;print "2";}
}
if ($flag==1)
{
	for ($i=0;$i<scalar(@work);$i++)
	{
		if (($work[$i] eq '') or ($work[$i] eq "\t")) {delete @work[$i];}
	}
	for ($i=0;$i<scalar(@work);$i++)
	{
		if (defined($work[$i])){

		if (!defined($hash{$work[$i]}))
		{
			$hash{$work[$i]}=1;
		}
		else 
		{
			$hash{$work[$i]}+=1;
		}
		
		}
	}
	my @arr=keys %hash;
	@arr=sort @arr;
	for ($i=0;$i<scalar(@arr);$i++)
	{
		$res="$res "."$arr[$i] ".("*"x$hash{$arr[$i]})."\n";
	}
	
}
elsif ($flag==0)
{
	$res="error";
	$errdesc="Empty line or not allowed element";
}
print STDOUT "$res\n";
print STDERR "$errdesc\n" if ( $res eq 'error' );
close ( FH );
