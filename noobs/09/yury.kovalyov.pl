#!/usr/bin/perl

########################################################
package Parser;
use warnings;
use strict;
use constant DUMMY_BUFFER => ( action => undef,  args => undef );

=pod

my @states = ( 'ZERO', 'SQL', 'PARAM', 'END' );
my @commands = ( 'sql', 'param', 'end' );

=cut

#
# STATE.command -> NEWSTATE
#
our %transitions =
(
	'ZERO'.'sql' => 'SQL',
	
	'SQL'.'param' => 'PARAM',
	'SQL'.'end' =>'END',

	'PARAM'.'end' => 'END',
	
	'END'.'sql' => 'SQL',

);

sub get_next_state
{
	my $self = shift;
	my $command = shift;

	my $transition = $self->{current_state}.$command;

	my $next_state = undef;

	if ( exists $transitions{$transition} )
	{
		$next_state = $transitions{$transition};
	}

	return $next_state;
}

sub move__
{
	my $self = shift;
	my $command = shift;

	my $next_state = $self->get_next_state($command);

	if ( my $invalidSequence = !defined($next_state) )
	{
		die( "Data has syntax error. From '$self->{current_state}'-state can not handle '$command'-command." );
	}
	
	( my $prev_state, $self->{current_state} ) = ( $self->{current_state}, $next_state );

	return $prev_state;
}

our @output = ();
sub hook
{
	my $self = shift;

	my $hook = $self->{options}{hook};
	if ( my $noHookInstalled = !defined( $hook ) )
	{
		pop( @output );
		return;
	}

	$hook->handle( pop( @output ) );
	
	return;
}

our %acts =
(
	'sql' => sub 
	{
		my $self = shift;
		$self->{input} = ""; # clear input for sure only
	},

	'param' => sub 
	{
		my $self = shift;

		my $str = $self->{input};
		chomp( $str );

		$self->{buffer}{action} = $str;  # current input contains sql-action code
		$self->{input} = "";
	},

	'end' => sub 
	{
		my $self = shift;
		my $prev = shift;

		my $str = $self->{input};
		chomp( $str );

		if ( 'SQL' eq $prev ) 
		{
			$self->{buffer}{action} = $str;
		} 
		elsif ( 'PARAM' eq $prev ) 
		{
			$self->{buffer}{args} = $str;
		}
		else
		{
			die( "Internal Error. Probably number of states were changed." );
		}

		$self->{input} = ""; # clear input
		
		push( @output, $self->{buffer} );
		
		$self->{buffer} = {DUMMY_BUFFER};
		
		$self->hook();
	}

);

sub new 
{
	my ( $class, @args ) = @_;

	my $self = _construct( @args );

	if ( !defined( $self ) )
	{
		die( "Construction exception of $class." );
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

			$self =
			{
				(
					current_state => 'ZERO',
					input => "",
					buffer => { DUMMY_BUFFER },
					options => { hook => undef },
				)
			};
		}
		elsif ( 'HASH' eq $type_name )
		{
			$self =
			{
				(
					current_state => 'ZERO',
					input => "",
					buffer => { DUMMY_BUFFER },
					options => @_,
				)
			};
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

# can not use '$self->{command'} in regexp invocation becuase of unknown reason (and 'my $command' as well)
# TODO: need to move static variable into object
our $command = undef;

sub parse
{
	my $self = shift;
	my $lines = shift;

	while ( my $eventGenerated = 
	(
			$lines 							# MEMO: handle multiline SQL-comments on the top of this regexp	
			=~ 
			m/(
					(?:^--\ sql[^\n]*\n)	(?{ $command = 'sql'; })
				|
					(?:^--\ param[^\n]*\n)	(?{ $command = 'param'; })
				|
					(?:^--\ end[^\n]*\n)	(?{ $command = 'end'; })
				|
					(?:[^\n]*\n)			### lets eat blank lines
				|
					(:?.)					(?{ die( "Internal Lexer Error. Probably regex was modified." ); })
			
			)/gmxs							### 
		)
	)
	{
		if ( my $justInputLine = !defined( $command ) )
		{
			$self->{input} .= $1;
			next;
		}

		my $prev_state = $self->move__( $command );

		my $sub = $acts{ $command };
		$self->$sub( $prev_state );

		$command = undef;
	}
	
	{
		my $state = "$self->{current_state}";
		#print "$state\n";
		my $parsingFinishedCorrectly = defined( $state ) && ( 'END' eq $self->{current_state} or 'ZERO' eq $self->{current_state} );

		if ( !$parsingFinishedCorrectly )
		{
			die( "Script contains syntax error. Parser expects data in state '$state'." );
		}
	}

	return;
}

1;

########################################################
package DataBase;
use warnings;
use strict;
use DBI;

#################################################################
#
# try/catch code is obtained from publuic domain
# http://www.perlmonks.org/?node_id=384038
#
sub try (&@) 
{
	my( $try, $catch ) = @_;
	eval { &$try };
	if ( $@ )
	{
	    local $_ = $@;
		&$catch;
	}
}

sub catch (&) 
{ 
	$_[0] 
}
#################################################################

sub new 
{
	my ( $class, @args ) = @_;

	my $self = _construct( @args );

	if ( !defined( $self ) )
	{
		die( "Construction exception of $class." );
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
			if ( my $wrongParametersInNew = ( 5 != scalar(@_) ) )
			{
				last;
			}

			$self =
			[
				@_
			];
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

sub _unwrap
{
	my $statement = shift;

	my $action = $statement->{action};
	my $args = $statement->{args};

	if ( !defined( $action ) )
	{
		$action = "";
	}

	if ( !defined( $args ) )
	{
		$args = "";
	}
	
	my @args = split( '\n', $args ); # pass through empty items fine
	#print join( '|', @args );print "\n";
	
	return ( $action, @args );
}

# TODO: check - http://stackoverflow.com/questions/576536/how-can-i-print-a-literal-null-for-undefined-values-in-perl
# ... "From http://search.cpan.org/~timb/DBI-1.607/DBI.pm , it will return null values as 'undef'."
sub handle
{
	my $self = shift;
	my ( $statement_and_args ) = @_;
	
	my ( $statement, @args ) = _unwrap( $statement_and_args );
	# prints( $statement );
	
	my $dbh = @{$self}[5];
	
	my $isSelectQuery = ( $statement =~ m/^\s*select/i );
	my $isParamerized = ( 0 != scalar( @args ) );
	
	if ( $isSelectQuery ) 
	{
		if ( $isParamerized )
		{
			my $sth = $dbh->prepare( $statement );

			try
			{
				foreach ( @args )
				{
					chomp;
					my @valsues = split( ',', $_ ); 
					$sth->execute( @valsues );

					while ( my @row = $sth->fetchrow_array )
					{
						print join( '|', map { $_ // 'NULL' } @row ) ."\n";
					}

				}

			}
			catch
			{
				my $rc = $sth->finish();
				chomp( $@, $! );
				die( "Select error: $@ - $!." );

			};

			$sth->finish();

		}
		else
		{
			my $sth = $dbh->prepare( $statement );

			try
			{
				$sth->execute();

				while ( my @row = $sth->fetchrow_array )
				{
					print join( '|', map { $_ // 'NULL' } @row ) ."\n";
				}

			}
			catch
			{
				my $rc = $sth->finish();
				chomp( $@, $! );
				die( "Fetching error: $@ - $!." );

			};

			$sth->finish();

		}

	}
	else # not-Select case:
	{
		if ( $isParamerized )
		{
			my $sth = $dbh->prepare( $statement );

			try
			{
				foreach ( @args )
				{
					chomp;
					my @valsues = split( ',', $_ ); 
					my $rc = $sth->execute( @valsues );
					#print "rc=($rc);($_);";print @valsues;print "\n";
				}

			}
			catch
			{
				my $rc = $sth->finish();
				chomp( $@, $! );
				die( "Fetching error: $@ - $!." );
				
			};

			$sth->finish();
			
		}
		else
		{
			try
			{
				my $affected = $dbh->do( $statement );

#				my $wrongAction = !defined( $affected );
#				my $noRowsUpdated = ( '0E0' eq $affected ); 
		
			}
			catch
			{
				chomp( $@, $! );
				die( "Exception of 'do'-method: $@ - $!." );
			};

		}


	}
	
	return;
}

# TODO: possibly it is resonable to implemenet connect with several efforts.
sub connect
{
	my $self = shift;

	my @options = @{$self};
	
	my ( $host, $port, $databasename, $username, $password ) = @options;

#	TODO:
#	actually we have to prepend '%' and '_'	with backslash '\'
#	$databasename =~ s/%/\\%/g;
#	$databasename =~ s/_/\\_/g;

	#printd @options;

	my $dsn = "DBI:mysql:database=$databasename;host=$host;port=$port";

	my $dbh = DBI->connect( $dsn, $username, $password, 
								{ RaiseError => 1, PrintError => 0 } # + AutoCommit => 0 
							); 
    
	if ( $dbh->ping() ) 
	{
    	# printd "Pinged successfuly\n";
	}

	push( @{$self}, $dbh );

	return;
}

sub disconnect
{
	my $self = shift;

	my $dbh = @{$self}[5];
	@{$self}[5] = undef;

	try # never saw issues - try/catch for sure only
	{
		if ( my $goodStateForSure = defined( $dbh ) )
		{
			$dbh->disconnect() or warn( "Error disconnecting: $DBI::errstr" );
		}
	}
	catch
	{
	};

	return;
}

sub prints
{
	my ( $statement ) = @_;

	if ( defined( $statement->{action} ) )
	{
		print "-- sql\n$statement->{action}";
	}

	if ( defined( $statement->{args} ) )
	{
		print "-- param\n$statement->{args}";
	}

	print "-- end\n\n";

	return;
}

1;

########################################################
package main;
use warnings;
use strict;

#################################################################
#
# try/catch code is obtained from publuic domain
# http://www.perlmonks.org/?node_id=384038
#
sub try (&@) 
{
	my( $try, $catch ) = @_;
	eval { &$try };
	if ( $@ )
	{
	    local $_ = $@;
		&$catch;
	}
}

sub catch (&) 
{ 
	$_[0] 
}
#################################################################

sub printe
{
	my $message = shift;
	print STDOUT "0\n";
	print STDERR $message;
	return;
}

sub printd # for debugging purpose
{
	if ( 0 )
	{
		print @_;
	}
}

sub load_info
{
	my $test_file_handle = $_[0];
	
	my @result = ();
	
	while ( <$test_file_handle> )
	{
		chomp;

		push( @result, $_ );
	
		if ( my $positionIsSetToLineFive = ( 5 == $. ) )
		{
			last;
		}
	}

	return @result;
}

sub load_instructions
{
	my $test_file_handle = $_[0];
	
	my $lines = do { local $/; <$test_file_handle> };
	
	return $lines;
}

( 0 == $#ARGV ) or die( "Wrong number of arguments: pass test file name, please." );
my $test_file_name = $ARGV[0];

open ( my $test_file_handle, "<", $test_file_name ) or die( "Can not open test file: $!" );

my $mysql = undef;
try 
{
	my ( $host, $port, $databasename, $username, $password ) = load_info( *$test_file_handle );
	printd ( $host, $port, $databasename, $username, $password );

	$mysql = DataBase->new( $host, $port, $databasename, $username, $password );

	$mysql->connect();
}
catch
{
	chomp( $@, $! );
	printe "Database initialization error. $@ - $!";
	exit 1;
};

try 
{
	my $parser = Parser->new( { hook => $mysql } );

	my $instructions = load_instructions( *$test_file_handle );
	printd $instructions;
	
	$parser->parse( $instructions );
}
catch
{
	chomp( $@, $! );
	printe "Error. $@ - $!";
	exit 2;
};

# need "finally"
$mysql->disconnect();

exit 0;
