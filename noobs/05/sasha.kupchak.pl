#!/usr/bin/perl


use warnings;

{
package MySh;
sub copy1{
	
	 for(my $i=0;$i<scalar(@_);$i++){
	 	if($_[$i] eq "")
	 	{shift;
	 		}
}
	
	use File::Copy qw(copy);
	open( FH1, ">", "$_[2]") or die "Can not open test file: $!";
         
	close ( FH1 );
	copy $_[1], $_[2];
	
}
sub delete1{
unlink $_[1];
}sub print1{
	
 for(my $i=0;$i<scalar(@_);$i++){
	 	if($_[$i] eq "")
	 	{shift;
	 		}
}	
open( FH2, "<", "$_[1]") or die "Can not open test file: $!";
         while(<FH2>){
         	my $fff=$_;
         	chomp($fff);
         print STDOUT "$fff\n";}
	close ( FH2 );}

sub sort1{	
	
 for(my $i=0;$i<scalar(@_);$i++){
	 	if($_[$i] eq "")
	 	{shift;
	 		}
}	
open( FH2, "<", "$_[1]") or die "Can not open test file: $!";
         while(<FH2>){
         	chomp($_);
         
         	push(@array,$_);
}
	close ( FH2 );
	 @gs=sort @array;
	
 for(my $i=0;$i<scalar(@gs);$i++)
{print STDOUT "$gs[$i]\n"}
undef @gs;}

sub search1{
	 for(my $i=0;$i<scalar(@_);$i++){
	 	if($_[$i] eq "")
	 	{shift;
	 		}
}
	
	open( FH2, "<", "$_[2]") or die "Can not open test file: $!";
         while(<FH2>){
         	chomp($_);
         	push(@array1,$_);
}
	close ( FH2 );
	 for(my $i=0;$i<scalar(@array1);$i++){
	 	
if($array[$i]=~/$_[1]/){	 	
	 print STDOUT "$array[$i]\n";
	 }}
	}
sub sort2{
	 for(my $i=0;$i<scalar(@_);$i++){
	 	if($_[$i] eq "")
	 	{shift;
	 		}
}

open( FH2, "<", "$_[1]") or die "Can not open test file: $!";
         while(<FH2>){
         	chomp($_);
         	
         	push(@arrays,$_);
}
	close ( FH2 );
	 @g4=sort @arrays;
 for(my $i=0;$i<scalar(@g4);$i++)
{print STDOUT "$g4[$i]\n"}
}

sub search2{
	
	 for(my $i=0;$i<scalar(@_);$i++){
	 	if($_[$i] eq "")
	 	{shift;
	 		}
}

	open( FH2, "<", "$_[2]") or die "Can not open test file: $!";
         while(<FH2>){
         	chomp($_);
         	push(@array5,$_);
}
	close ( FH2 );
	 for(my $i=0;$i<scalar(@array5);$i++){
	 	
if($array5[$i]=~/$_[1]/){	 	
	 print STDOUT "$array5[$i]\n";
	 
}
}
	
}
sub search3{
	
	 for(my $i=0;$i<scalar(@_);$i++){
	 	if($_[$i] eq "")
	 	{shift;
	 		}
}



	open( FH2, "<", "$_[2]") or die "Can not open test file: $!";
         while(<FH2>){
         	chomp($_);
         	push(@array6,$_);
}
	close ( FH2 );
	 for(my $i=0;$i<scalar(@array6);$i++){
	 	
if($array6[$i]=~/$_[1]/){	 	
	push(@wesdom,$array6[$i]);
	 
}
}
	return @wesdom;
}

sub zapis {
	
	 for(my $i=0;$i<scalar(@_);$i++){
	 	if($_[$i] eq "")
	 	{shift;
	 		}
}$cet=pop;
open( FH1, ">", "$cet") or die "Can not open test file: $!";
 for(my $i=0;$i<scalar(@_);$i++){
         print FH1 "$_[$i]\n";
         }
	close ( FH1 );
}

}



# MAIN
package main;
$filename= $ARGV[0];
open( FH, "<", "$filename") or die "Can not open test file: $!";
while(<FH>){
$str=$_;
$str1=$str;
$str2=$str1;
chomp($str);$str1=~s/[0-9a-z_.|>]//g;
$str1=~s/\s+//g;
if($str1=~/[A-Z]/)
{
	 print "MySh::>$str\n";
print STDOUT "0\n";
print STDERR "large letter\n";		
	$str="";}
$str2=~s/\s+//g;
$str2=~s/\w+//g;
$str2=~s/\.//g;
$str2=~s/\>//g;
$str2=~s/\|//g;
chomp($str2);
if($str2 ne ""){
	print "MySh::>$str\n";	print STDOUT "0\n";
print STDERR "Nedopust symvol\n";		
	$str="";}

chomp($str);
if($str ne ""){
@arr=split(/ /,$str);
 for(my $i=0;$i<scalar(@arr);$i++)
{$arr[$i]=~s/ //g;}	
print "MySh::>$str\n";

if($str=~/copy/||$str=~/move/){
	if(scalar(@arr)>3){
	print STDOUT "0\n";
print STDERR "mnogo znacheniy\n";		
	$str="";
	}else{
MySh::copy1(@arr);
}
}
if($str=~/delete/){
if(scalar(@arr)>2){
	print STDOUT "0\n";
print STDERR "mnogo znacheniy\n";		
	$str="";	
}else{
MySh::delete1(@arr);}
}

if($str=~/print/){
my $kol=scalar(@arr);
if($kol==2){
MySh::print1(@arr);}


}


if($str=~/sort/){
my $kol=scalar(@arr);
if($kol==2){
MySh::sort1(@arr);}

}


if($str=~/search/){
my $kol=scalar(@arr);
if($kol==3){
MySh::search1(@arr);
}

}if($str=~/exit/){}

if($str=~/\>/)
{
	
	
	@pipes = split(/\>/,$str);
@got = split(/ /,$pipes[0]);

@wes=MySh::search3(@got);
push(@wes,$pipes[1]);
MySh::zapis(@wes);} 

if($str=~/\|/)
{
	@pipe = split(/\|/,$str);
	$n=scalar(@pipe);
if($pipe[$n-1]=~/sort/){
	
	for(my $i=scalar(@pipe)-1;$i>=0;$i--){
	if($pipe[$i]=~/\w+\.txt/)
	{
		
		@t=split(/ /,$pipe[$i]);
	MySh::sort2(@t);}	
	
	}
	}
	
	if($pipe[$n-1]=~/search/){
@qwer=split(/ /,$pipe[$n-1]);

for(my $i=scalar(@pipe)-1;$i>=0;$i--){
	if($pipe[$i]=~/\w+\.txt/)
	{
		 
		@t=split(/ /,$pipe[$i]);
		$nom=scalar(@t);
		
		push(@qwer,$t[$nom-1]);
	MySh::search2(@qwer);
}	
	
	
}
}
	for(my $i=scalar(@pipe)-1;$i>=0;$i--){
	if($pipe[$i]=~/\w+\.txt/)
	{
		@t=split(/ /,$pipe[$i]);
		if($t[$i]=~/sort/){
			
		my $kol=scalar(@t);
		
		MySh::sort2(@t);
	
}


}
			}}}
}
close(FH);





