#!/usr/bin/perl

use warnings;
use strict;

my %list =
(
);

sub printe
{
	my $message = shift;
	print STDOUT "error\n";
	print STDERR $message;
}

sub print_list
{
	my $head = shift;
	if ( my $invalidArgument = ( !defined $head ) )
	{
		return;
	}

	print( "$head" );
	my $ptr = next_($head);
	
	while ( defined($ptr) )
	{
		print( "-$ptr" );
		$ptr = next_($ptr);
	};

}

sub print_list_with_loop
{
	my ( $head, $loop ) = @_;
	if ( my $invalidArgument = ( !defined($head) or !defined($loop) ) )
	{
		return;
	}

	if ( $head ne $loop )
	{
		# head
		print( "$head" );
		my $ptr = next_($head);

		# head's tail
		while ( $ptr ne $loop )
		{
			print( "-$ptr" );
			$ptr = next_($ptr);
		};

		print( "-" );
	}

	# loop
	print( "$loop" );
	my $ptr = next_($loop);

	# loop's tail
	while ( $ptr ne $loop )
	{
		print( "-$ptr" );
		$ptr = next_($ptr);
	};

	print( "-$loop" );	
}

sub next_
{
	my $pos = shift;
	
	# To be on the safe side and to allow next_(next_(...)) lets process it:
	if ( my $undefinedArgument = ( !defined $pos ) )
	{
		return undef;
	}

	if ( exists $list{$pos} )
	{
		my $next_pos = $list{$pos};
		
		# assert for sure (almost secure iterator; die - for full secure)
		unless ( my $assert = defined( $next_pos ) )
		{
			warn "Internal error! Unexpected hash data!";
		}

		return $next_pos;
	}
	
	# normal case e.g. element is absent in hash
	return undef;
}

sub getEntryOfLoop
{
	my $head = shift;
	
	if ( my $invalidArgument = ( !defined($head) or !exists($list{$head}) ) )
	{
		return (undef,undef);
	}
	
	my $slow = $head;
	my $fast = $head;
	
	while ( defined( $fast ) and defined( next_( $fast ) ) )
	{
		$fast = next_( next_( $fast ) );
		$slow = next_( $slow );
		
		if ( my $finishAchieved = ( !defined($fast) ) ) # no need to check "or !defined($slow)" too as fast-car is quicker 
		{
			last;
		}
		
		# fast-car may get a rendezvous with slow-car if and only if we have loop!
		if ( my $rendezvousAppear = ( $fast eq $slow ) )
		{
			last;
		}

	};

	if ( my $noRendezvous = ( !defined( $fast ) or !defined( next_( $fast ) ) ) )
	{
		return ($head,undef);
	}
	
	# In this case - processing looped list safely:
	$slow = $head;
	while ( $slow ne $fast )
	{
		$slow = next_($slow);
		$fast = next_($fast);
	}
	return ($head,$fast);
}

my $handle = undef;

sub initialize
{
	( 0 == $#ARGV ) or die "Wrong number of arguments: pass test file name, please.";
	my $test_file_name = $ARGV[0];

	open ( $handle, "<", $test_file_name ) or die "Can not open test file: $!";

	my $head = <$handle>;
	if ( defined ( $head ) ) 
	{
		chomp $head;
	}

	my $hash = <$handle>;
	if ( defined ( $hash ) ) 
	{
		chomp $hash;
	}

	return ($head,$hash);
}

sub uninitialize
{
	if ( defined( $handle ) )
	{
		close ( $handle );
	}
}

# -----------------------------------------
my ($head,$hash) = initialize();

{
	if ( !defined ($head) )
	{
		printe "Invalid entry point: check test file is not empty, please.\n";
		last;
	}

	# cut border spaces:
	$head =~ s/^\s+|\s+$//g;
	
	if ( my $wrongHead = ( $head !~ m/^\w+$/ ) )
	{
		printe "Invalid entry point data: check first line of test file, please.\n";
		last;
	}

	if ( !defined ($hash) )
	{
		printe "Invalid hash-string data: check test file contains second line, please.\n";
		last;
	}

	# idea: $token = '\s*\w+\s*\=\>\s*\w+\s*';
	# full token: ^ $token ( \, $token)* $
	if ( my $wrongHashString = ( $hash !~ m/^\s*\w+\s*\=\>\s*\w+\s*(?:\,\s*\w+\s*\=\>\s*\w+\s*)*$/ ) )
	{
		printe "Invalid hash-string data: check second line of test file, please.\n";
		last;
	}

	# fill the list
	while ( $hash =~ m/\s*(\w+)\s*\=\>\s*(\w+)\s*/g )
	{
		$list{$1}=$2;
	}

	my ( $start, $loop ) = getEntryOfLoop( $head );

	if ( my $internalError = ( !defined($start) && defined($loop) ) )
	{
		printe "Internal error. Please contact with a developer.\n";
		last;
	}

	if ( my $noEntryElement = ( !defined($start) && !defined($loop) ) )
	{
		printe "No sush entry point! Check test file data, please.\n";
		last;
	}

	if ( my $simpleNoLoopsCase = ( defined($start) && !defined($loop) ) )
	{
		print_list( $start );
		print "\n";
		last;
	}

	print_list_with_loop( $start, $loop );
	print "\nlooped\n";
	last;
}

uninitialize();
