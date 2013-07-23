#!/usr/bin/perl

# online calculator:
# http://numsys.ru/
=comment
Я согласен, что код - лажа и не работает с двоичной системой. Кроме того, отключены ворнинги и не используется стрикт.
Обещаю, что со следующим домашним заданием такого не повторится.
=cut


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

while ( <FH> ) 
{
@arr=split(/,/,$_);
%hashout=('0','0','1','1','2','2','3','3','4','4','5','5','6','6','7','7','8','8','9','9','10','A','11','B','12','C','13','D','14','E','15','F','16','G','17','H','18','I','19','J','20','K','21','L','22','M','23','N','24','O','25','P','26','Q','27','R','28','S','29','T','30','U','31','V','32','W','33','X','34','Y','35','Z');
%hashin=undef;
$flag=1;
for ($i=1;$i<=35;$i++)
{
	$buf=$hashout{$i};
	$hashin{$buf}=$i;
}
@buf=undef;
$res='';
@ready=undef;
($io,$num,$sys)=@arr[0,1,2];
if ((!defined $io) or (!defined $num) or (!defined $sys)){$flag=0;}
if (($io/2==0) or ($sys/2==0)){$flag=0;}
@splited=split(//,$num);
for ($i=0;$i<scalar(@splited);$i++)
{
	$splited[$i]=$hashin{$splited[$i]};
	if($hashin{$splited[$i]}>($sys-1)){$flag=0;}
}
if (($io==1) and ($flag==1))
{
	while ($num!=0)
	{
		$rest=$num%$sys;
		$num=int($num/$sys);
		push @buf,$hashout{$rest};
	}
	for($i=1;$i<(scalar(@buf));$i++)
	{
		$ready[$i]=$buf[-$i];
		$res=$res.$buf[-$i];
	}
}
elsif (($io==2) and ($flag==1))
{
	$res=0;
	$i2=scalar(@splited)-1;
	for ($i=0;$i<=(scalar(@splited)-1);$i++)
	{
		$res+=($sys**$i2)*$splited[$i];
		$i2--;
	}
}
else
{
	$res='Error';
	$errdesc="Wrong input";
}

print STDOUT "$res\n";
print STDERR "$errdesc\n" if ( $res eq 'Error' );
}
close ( FH );
