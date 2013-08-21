#!/usr/bin/perl -w
use strict;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $string = <FH>;
chomp ($string);
$string=~s/#.+//g;
if ($string eq ''||$string=~/^\s*$/){
       print STDOUT "0\n" and die "no entry\n";
       }
if ($string=~/\W/){
       print STDOUT "0\n" and die "invalid entry\n";
       }
my (%hash1, %hash2, $k, $v, $i, $mas);
while (<FH>){
	chomp;
	$mas=$_;
	if ($mas=~/^#/||$mas=~/^\s*$/){
	next;
	}
	$mas=~s/#.+//g;
	if ($mas=~/=>/){
		($k, $v)=split(/=>/, $mas);
	}
	elsif ($mas=~/=/){
		($k, $v)=split(/=/, $mas);
	}
	else{
		print STDOUT "0\n" and die "invalid data\n";
		}
	$k=~s/^\s+|\s+$//g;
	$v=~s/^\s+|\s+$//g;
	if ($k=~/^"(.+)"$/){
	$k=~s/^"(.+)"$/$1/;
	}
	elsif ($k=~/^'(.+)'$/){
	$k=~s/^'(.+)'$/$1/;
	}
	if ($v=~/^"(.+)"$/){
	$v=~s/^"(.+)"$/$1/;
	}
	elsif ($v=~/^'(.+)'$/){
	$v=~s/^'(.+)'$/$1/;
	}
	if ($k=~/\W/||$v=~/\W/){
		print STDOUT "0\n" and die "invalid data\n";
		}
	$i.="#";
	$hash1{$k}=$i;
	$hash2{$i}=$v;
	next;
	}
foreach $k(sort {$b cmp $a} keys %hash1){
		$string=~s/$k/*$hash1{$k}*/g;
		}
foreach $i(keys %hash2){
		$string=~s/\*$i\*/$hash2{$i}/g;
		}
print STDOUT "$string\n";
close ( FH );