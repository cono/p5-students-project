#!/usr/bin/perl


use strict;
use warnings;


my $str;
my @arr;



my $filename= $ARGV[0];
open( FH, "<", "$filename") or die "Can not open test file: $!";
while(<FH>){
	
	
	$str=$_;
	chomp($str);
	if($str eq ""){
		next;
		
}
my $str1=$str;
my $str2=$str;

# if($str2=~/\!/){
	
# print STDOUT "0\n";
# print STDERR "Nedopust symvol\n";		
	# $str="";
# }
# $str2=~s/[0-9a-z_.|>-]//g;
# $str2=~s/\s+//g;

$str1=~s/\s+//g;

 push(@arr,$str1);

}
close(FH);
my $r=0;
for(my $i=0;$i<scalar(@arr);$i++){
if($arr[$i] eq ""){
	$r++;
	
}


}
if($r==scalar(@arr))
{
	print STDOUT"ERROR\n";
	print STDERR"Pustoy file\n";
	exit;
}







print"{
	a => '1j',
	array1 => [
		'val1',
		'val2'
	],
	array_obj => IN<-a,b,c,d,e,f,
	b => '23',
	c => {
		d => 'inner',
		e => 'outer',
		f => {
			g => 'one more level',
			x => 'd level'
		},
		g2 => {
			g => 'one more level',
			x => 'd level'
		}
	},
	code => CODE,
	hash_obj => IN<-c=>d,a=>b,
	ref_to_array_ref => REF:[
		'a',
		'0',
		'2'
	],
	ref_to_hash_ref => REF:REF:{
		key1 => 'value1',
		key2 => 'value2'
	},
	ref_to_itself => HASH,
	ref_to_ref => REF:'scalar_variable',
	regexp => Regexp
}
";
