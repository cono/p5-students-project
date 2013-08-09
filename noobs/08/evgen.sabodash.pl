#!/usr/bin/perl -w
use strict;
package Date;			#if ( $s->{'year'}=~/^\d{4}$/ &&  $s->{'month'} =~ /^\d\d*$/ && )
sub new {
	my $class = shift;
	my $s = shift;
	my $self;
	if (defined($s)){
		if (ref($s) eq "HASH") { 
			if ( exists($s->{'year'}) && exists($s->{'month'}) && exists($s->{'day'})){				
					$self = $s;				
			}
			else {
				return undef;
			} 
		}		
		elsif (ref($s) eq "ARRAY") {
			
			if ( defined($s->[0]) && defined($s->[1]) && defined($s->[2]) ){
				$self->{'year'} = $s->[0];
				$self->{'month'} = $s->[1];
				$self->{'day'} = $s->[2];
			}
			else {
				return undef;
			}
		}
		else {return undef;}
	}
	else {
		my @d = localtime(time); 
		$self->{'year'} = $d[5];
		$self->{'month'} = $d[4];
		$self->{'day'} = $d[3];
		$self->{'year'}+=1900;		
		
	}
	bless $self, $class;
	return $self;
}

	sub get_struct {
		my $self = shift; 
		return $self->{'year'}.'/'.$self->{'month'}.'/'.$self->{'day'};
	 
	}
sub year {
	my $self = shift;
	if (@_) {
		$self->{'year'} = shift;
	} else {
		$self->{'year'};
	}
}
sub month {
	my $self = shift;
	if (@_) {
		$self->{'month'} = shift;
	} else {
		$self->{'month'};
	}
}

sub day {
	my $self = shift;
	if (@_) {
		$self->{'day'} = shift;
	} else {
		$self->{'day'};
	}
}
 1;
  
package Calendar; 
   
   our @ISA = qw(Date);
	
   use strict;  
   
   sub add_months(){
	my $self = shift;
	my $add = $self->{'month'} + shift;
	while ($add > 12){
		$add-=12;
		$self->{'year'}++;
	}
	$self->{'month'} = $add;
	return	$self;
	}
	
	sub add_days(){
	my %md;
	$md{'1'} = 31; $md{'2'} = 28; $md{'3'} = 31; $md{'4'} = 30; $md{'5'} = 31; $md{'6'} = 30;
	$md{'7'} = 31; $md{'8'} = 31; $md{'9'} = 30; $md{'10'} = 31; $md{'11'} = 30; $md{'12'} = 31;	
	my $self = shift;
	if (  $self->{'year'} % 4 == 0 &&   ( ( $self->{'year'} % 100 != 0) || ($self->{'year'} % 400 == 0) ) ) {
		$md{'2'} = 29;
	}
	
	my $add = $self->{'day'} + shift;
	while ( $add > $md{ $self->{'month'} } ){
		$add -= $md{ $self->{'month'} };
		$self->{'month'}++;
		if  ( $self->{'month'} > 12 ){
			$self->{'year'}++;
			$self->{'month'} = 1;
		}
		if (  $self->{'year'} % 4 == 0 &&   ( ( $self->{'year'} % 100 != 0) || ($self->{'year'} % 400 == 0) ) ) {
			$md{'2'} = 29;
		} else {
			$md{'2'} = 29;
		}
	}
	
	$self->{'day'} = $add;
	return $self;
	}
sub add_years(){
	my $self = shift;
		$self->{'year'} += shift;
		return $self;
	
}
 
 

package main;
use strict;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $fileContent;
{
 local $/;
 $fileContent = <FH>;
}
close(FH);
if ( !defined(eval $fileContent)){
	print STDOUT "ERROR\n";
}