#!/usr/bin/perl

use warnings;
use strict;

########################################################
### shared functions, utils. ###########################
package Help;

use warnings;
use strict;
use Time::localtime;
use Date::Calc qw(check_date Add_Delta_YMD);

# https://metacpan.org/module/Date::Calc

sub get_current_date
{
	my $tm = localtime;
	my ( $year, $month, $day ) = ( 1900+$tm->year, 1+$tm->mon, $tm->mday );
}

sub members()
{
	qw( year month day )
}

sub is_good_date
{
	return check_date(@_);
}

sub add_years
{
	my $years = shift;
	my ($year, $month, $day) = Add_Delta_YMD(@_,$years,0,0);
}
sub add_months
{
	my $months = shift;
	my ($year, $month, $day) = Add_Delta_YMD(@_,0,$months,0);
}
sub add_days
{
	my $days = shift;
	my ($year, $month, $day) = Add_Delta_YMD(@_,0,0,$days);
}

1;

########################################################
package Date;
use warnings;
use strict;

sub new 
{
	my ( $class, @args ) = @_;

	my $self = _construct( @args );

	# should we return null or throw exceptions in Perl?
	if ( !defined( $self ) )
	{
		return undef;
	}

	return bless( $self, $class );
}

sub _construct
{
	my $self = undef;

	{
		my $type_name = ref( $_[0] );

		if ( my $defaultConstructor = ( not $type_name ) )
		{
			if ( my $wrongExtraParametersInNew = ( 0 != scalar(@_) ) )
			{
				last;
			}

			my @members = Help::members();
			my @params = Help::get_current_date();

			my %hash; @hash{ @members } = @params;
			$self = { %hash };
		}
		elsif ( 'ARRAY' eq $type_name )
		{
			if ( my $wrongExtraParametersInNew = ( 1 != scalar(@_) ) )
			{
				last;
			}

			my @members = Help::members();
			my @params = @{ $_[0] };

			if ( scalar( @members ) != scalar( grep { defined $_ } @params ) )
			{
				last;
			}
			
			if ( ! Help::is_good_date( @params ) )
			{
				last;
			}

			my %hash; @hash{ @members } = @params;
			$self = { %hash };
		}
		elsif ( 'HASH' eq $type_name )
		{
			if ( my $wrongExtraParametersInNew = ( 1 != scalar(@_) ) )
			{
				last;
			}
		
			my @members = sort( Help::members() );
			
			my $hash_ref = shift;
			if ( !defined( $hash_ref ) )
			{
				last;
			}

			my %hash = %{ $hash_ref };
		
			my @values = values %hash;
			if ( scalar( @members ) > scalar( grep { defined $_ } @values ) )
			{
				last;
			}
			
			my @keys = sort( keys %hash );
			if ( scalar( @members ) > scalar( grep { defined $_ } @keys ) )
			{
				last;
			}

#			removed arrays direct compare as there can be extra arguments in hash (last information)
#			if ( !( @members ~~ @keys ) )
#			{
#				last;
#			}
			if ( my $quickFixNotEnoughDataPassed = ( scalar(@members) != scalar( grep { exists( $hash{$_} ) } @members )  ) )
			{
				last;
			}
#			i.e the same -
#			if ( my $quickFixNotEnoughDataPassed = !( exists( $hash{$members[0]} ) and exists( $hash{$members[1]} ) and exists( $hash{$members[2]} ) ) )
#			{
#				last;
#			}

			if ( ! Help::is_good_date( map{ $hash{$_} } reverse @members ) )
			{
				last;
			}
			
			$self = { %hash }; 
		}
		else
		{
			# two aproaches possible : throw exception -
			# die( "Strange constructor call with: '$type_name'." );
			# or return null -
		}
	}

	return $self;
}

sub serialize
{
	my $self = shift;
#	( $self->{year}, $self->{month}, $self->{day} );
	map { $self->{$_} } Help::members();
}

# to create exception safe code -
# usually we have to create internal object and safely swap with self inner object
# not to shift/shift/shift...
# what about Per?
sub deserialize
{
	my $self = shift;

	$self->{year} = shift;
	$self->{month} = shift;
	$self->{day} = shift;

	return $self;
}

sub clone
{
	my $self = shift;

	my @ymd = $self->serialize();

	my $copy = Date->new(\@ymd);

	return $copy;
}

sub year
{
	my $self = shift;

	if ( @_ )
	{
		if ( my $quickFixAnswer78 = ( 1 < scalar(@_) ) )
		{
			return undef;
		}

		my $copy = $self->clone();
		$copy->{year} = shift;

		if ( !Help::is_good_date( serialize($copy) ) )
		{
			# die( "Wrong year." );
			return undef;
		}
		
		$self->{year} = $copy->{year};
	}

	return $self->{year};
}

sub month
{
	my $self = shift;

	if ( @_ )
	{
		if ( my $quickFixAnswer78 = ( 1 < scalar(@_) ) )
		{
			return undef;
		}

		my $copy = $self->clone();
		$copy->{month} = shift;

		if ( !Help::is_good_date( serialize($copy) ) )
		{
			# die( "Wrong month." );
			return undef;
		}
		
		$self->{month} = $copy->{month};
	}

	return $self->{month};
}

sub day
{
	my $self = shift;

	if ( @_ )
	{
		if ( my $quickFixAnswer78 = ( 1 < scalar(@_) ) ) 
		{
			return undef;
		}

		my $copy = $self->clone();
		$copy->{day} = shift;

		if ( !Help::is_good_date( serialize($copy) ) )
		{
			# die( "Wrong day." );
			return undef;
		}
		
		$self->{day} = $copy->{day};
	}

	return $self->{day};
}

sub get_struct
{
	my $self = shift;
#
#	return join( '/', map { $self->{$_} } reverse sort keys %{ $self } ); 
#	or -
	my %h = map { $_ => 1 } Help::members();
	return join( '/', map { $self->{$_} } grep { exists( $h{$_} ) } reverse sort keys %$self );
#	is a kind of "funny way" \perldoc contains such words\ (or Perl-idiomatic aproach?) to 
#	return join( '/', ($self->{year},$self->{month},$self->{day}) );
}

1;

########################################################
package Calendar;
use warnings;
use strict;

our @ISA = ('Date');

sub add_years
{
	my $self = shift;

	if ( my $quickFixAnswer78 = ( 1 < scalar(@_) ) ) 
	{
		return undef;
	}

	my @ymd = Help::add_years( shift, $self->serialize() );

	if ( ! Help::is_good_date( @ymd ) )
	{
		# die( "Internal error." );
		return undef;
	}

	return $self->deserialize( @ymd );
}
	
sub add_months
{
	my $self = shift;

	if ( my $quickFixAnswer78 = ( 1 < scalar(@_) ) ) 
	{
		return undef;
	}

	my @ymd = Help::add_months( shift, $self->serialize() );

	if ( ! Help::is_good_date( @ymd ) )
	{
		# die( "Internal error." );
		return undef;
	}

	return $self->deserialize( @ymd );
}
	
sub add_days
{
	my $self = shift;

	if ( my $quickFixAnswer78 = ( 1 < scalar(@_) ) ) 
	{
		return undef;
	}

	my @ymd = Help::add_days( shift, $self->serialize() );

	if ( ! Help::is_good_date( @ymd ) )
	{
		# die( "Internal error." );
		return undef;
	}

	return $self->deserialize( @ymd );
}
	

1;

########################################################
package main;
use warnings;
use strict;

sub printe
{
	my $message = shift;
	print STDOUT "ERROR\n";
	print STDERR $message;
	return;
}

( 0 == $#ARGV ) or die "Wrong number of arguments: pass test file name, please.";
my $test_file_name = $ARGV[0];

open ( my $test_file_handle, "<", $test_file_name ) or die "Can not open test file: $!";

my $code = join( '', <$test_file_handle> );

my $result = eval( $code );
if ( $@ )
{
	chomp( $@ );
	chomp( $! );
	printe "$@ - $!\n";
	exit 2;	
}

