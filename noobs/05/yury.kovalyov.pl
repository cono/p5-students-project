#!/usr/bin/perl
########################################################

=pod

1)
print 1.txt > 1.txt 
e.g.
Linux : 'cat 1.txt > 1.txt' - fails command execution - as well 'delete 1.txt > 1.txt'
Windows: 'type 1.txt > 1.txt' - just truncates 1.txt - but fails 'delete 1.txt > 1.txt'
MySh : to get Linux(?) behaviour need to lock file [it was not implemented unfortunately]

also:

we can detect does 'print' and '>' uses same file or not. 
To avoid issue with the access to the same file through links -
for Windows - we need just open both and compare *handles*
for linux - situation is more complicated.

2)
All 'sort'-utilities produces *differnt* output (details are in the code) 
even with the simplest text files e.g.:
= = = = = = = =
HL-DT-ST DVDRAM GSA-T20N WR02 (ATA)
Current Profile: CD-R

Disc Information:
Status: Complete
State of Last Session: Complete
Erasable: No
Sessions: 1
Sectors: 303�637
Size: 621�848�576 bytes
Time: 67:30:37 (MM:SS:FF)
MID: 97m27s18f (Plasmon Data Systems)
Supported Write Speeds: 10x; 16x; 24x

TOC Information:
Session 1... (LBA: 0 / 00:02:00)
-> Track 01  (Mode 1, LBA: 0 / 00:02:00)
-> LeadOut  (LBA: 303637 / 67:30:37)

ATIP Information:
Disc ID: 97m27s18f
Manufacturer: Plasmon Data Systems
Start Time of LeadIn: 97m27s18f
Last Possible Start Time of LeadOut: 79m59s74f

Performance (Write Speed):
Descriptor 1...
-> B0: 0x02; B1: 0x00; B2: 0x00; B3: 0x00
-> EL: 303636 (0x0004A214)
-> RS: 1�827 KB/s (10,4x) - WS: 1�764 KB/s (10x)
Descriptor 2...
-> B0: 0x02; B1: 0x00; B2: 0x00; B3: 0x00
-> EL: 303636 (0x0004A214)
-> RS: 1�827 KB/s (10,4x) - WS: 2�822 KB/s (16x)
Descriptor 3...
-> B0: 0x02; B1: 0x00; B2: 0x00; B3: 0x00
-> EL: 303636 (0x0004A214)
-> RS: 1�827 KB/s (10,4x) - WS: 4�234 KB/s (24x)



= = = = = = = =
- probably because of 'use locale' (+'open'?) but the issue was not resolved and 
perl-sort works differently than all system-sort tools I had access and 
have spent a lot of time for tests.

3)
Loop 'while ( <> )' was used for process user input interactively and 
file-arguments - as it was suggested in the lecture time.

4)
There were not applied any special restrictions (e.g. alphanumeric) for filenames in MySh.

5)
You may use 'prind "$code\n";' to check generated eval-program.

=cut

########################################################
package message;

use warnings;
use strict;

use constant WRONG_CALL => "Internal error: wrong call of sub.";
use constant COMMAND_SYNTAX_ERROR => "Incorrect command arguments.";
use constant INTERNAL_ERROR => "Internal error.";
use constant SYSTEM_ERROR => "System error.";

1;

########################################################
package file;

use warnings;
use strict;
use List::Util qw(min);

use constant BUFFER_SIZE => (4*4096);

sub pump
{
	my $available = shift // 0;
	my $from = shift or die( message::WRONG_CALL );
	my $to = shift or die( message::WRONG_CALL );

	my $buffer = undef;
	my $len = undef;

	while (
			( 0 < $available )
		&&
			( defined ( $len = sysread( $from, $buffer, min( BUFFER_SIZE, $available ) ) ) or die($!) )
		&&
			( 0 < $len )
		 )
	{
		if ( defined ( my $written = syswrite( $to, $buffer, $len ) ) or die($!) )
		{
			# all-or-nothing - lets handle the issue without "retrains"-ways but die:
			unless ( my $assert = ( $len == $written ) )
			{
				die( "Unexpected error: please contact with customer support organization." );
			}
		}
	
		$available -= $len;
	}

}

sub copy
{
	my $from_file_name = shift or die( message::WRONG_CALL );
	my $to_file_name = shift or die( message::WRONG_CALL );

	open( my $from, '<', $from_file_name ) or die($!);
	binmode( $from );

	open( my $to, '>', $to_file_name ) or die($!);
	binmode( $to );

	my $available = -s $from_file_name;
	pump ( $available, $from, $to );

	close( $to );
	close( $from );

}

# still debugger issues (something with STDOUT)
sub pump_std
{
	my $available = shift or die( message::WRONG_CALL );
	my $from = shift or die( message::WRONG_CALL );
	my $to = shift or die( message::WRONG_CALL );

	my $buffer = undef;
	my $len = undef;

	while (
			( 0 < $available )
		&&
			( defined ( $len = sysread( $from, $buffer, min( BUFFER_SIZE, $available ) ) ) or die($!) )
		&&
			( 0 < $len )
		 )
	{
		my $offset = 0;

		# Handle partial writes.

		while (
				( 0 < $len )
			&&
				( defined ( my $written = syswrite( $to, $buffer, $len, $offset ) ) or die($!) )
#				&&
#					( my $forSureNotZeroLoop = ( 0 < $written ) )
			 )
		{
			$len -= $written;
			$offset += $written;
		};

		$available -= $offset;
	}

}

#test: copy ( $ARGV[0], $ARGV[1] );

1;

########################################################
package sort;

use warnings;
use strict;

# need to check
# http://pragmaticperl.com/issues/04/pragmaticperl-04-%D1%81%D0%BE%D1%80%D1%82%D0%B8%D1%80%D0%BE%D0%B2%D0%BA%D0%B0-%D0%B2-perl.html#.Uf1RFRHWjUB
# http://en.wikipedia.org/wiki/Schwartzian_transform
# http://www.sysarch.com/Perl/sort_paper.html
# http://search.cpan.org/~creamyg/Sort-External-0.18/lib/Sort/External/Cookbook.pod


# Notes:
#
# * it still does not match with linux 'sort' (is vm tuned ok?);
# * after testing with .fb2 files - I see
# *  	!!! GnuWin32-sort, Windows-sort, Linux-sort, MySh-sort - all produces different results!!!
# * possibly - it is locale dependent;
# * to sort big files need to implement extrnal sort ;
#

sub sort_in_memory
{
	my $from = shift;
	binmode( $from );
#binmode($from, ":utf8") or die(".");


	my $to = shift;

	{
#effort4 use locale;use POSIX;setlocale(LC_CTYPE, 'en');
#effort5 use locale;use POSIX;setlocale(LC_COLLATE, "") or die("!");
#effort6 use locale;use POSIX;setlocale(LC_CTYPE, "") or die("!");
#effort7 use POSIX;setlocale(LC_ALL, "C");
		use locale;
#effort3	use locale ':not_characters';
		$$to = join( '', sort <$from> );
	#	$$to = join( '', sort map { s/^[[:space:]]*(.*?)[[:space:]]*$/$1/; "$_\n" } <$from> );
	#	$$to = join( '', map { s/^\s+$//g; $_ } sort <$from> );
	}

	return;
}


#
# Notes:
# there may be some pltform dependent issues with extern sort-utility e.g. 
#
# Windows: 'sort' may need to set some internal buffer size (/REC) on some files -
# 	type BOOK.fb2 | sort /REC 65535 > BOOKSORTED.fb2 2> BOOKSORTED.err
#
# Linux: ? ? ?
# 	cat  BOOK.fb2 | sort            > BOOKSORTED.fb2 2> BOOKSORTED.err
#

# TODO: No time
sub search_external_utility
{
}

1;

########################################################
package search;

use warnings;
use strict;

#
# TODO: nedd to test - is this aproach effective or not - 
# 		may be MemString+Open+LineByLine is better?
#
sub search_in_memory
{
	my $pattern = shift;

	my $from = shift;
	binmode( $from );

	my $to = shift;

	{
		my $re = qr/$pattern/; 

#		local $/; #TODO : impacts results !!!

		# delivery of result string (C# has 'ref/out' for such things):
		$$to = join( '', grep { m/$re/ } <$from> );
	}

	return;
}

sub search_line_by_line
{
	my $pattern = shift;

	my $from = shift;
	binmode( $from );

	my $to = shift;

	my $re = qr/$pattern/; 

#	local $/;
	while ( <$from> )
	{
		if ( m/$re/ )
		{
			print $to $_;
		}
	}
	
	return;
}

#
# Notes:
# there may be some pltform dependent issues with extern findstr-utility e.g. 
#
# Windows: 'findstr' may need to set some flag /R to use regular expressions
# 	type BOOK.fb2 | findstr test > BOOKGREPED.fb2 2> BOOKGREPED.err
#
# Windows: 'grep' may need to use -U option to keep CR-char
#	type BOOK.fb2 | grep -U
#
# Linux: ? ? ?
#
#

#
# TODO: need to catch STDOUT and STDERR carefully + generate tempfilenames
#
sub search_external_utility
{
	my $pattern = shift;
	my $from = shift;
	
	my $to = "zzzzzz";

# win32
#	my $var = `findstr $pattern $from > $to`;

# ----
	my $var = `grep -U $pattern $from > $to`;

	if ( $? )
	{
		# findstr & grep (GnuWin32)
		# 			0 - ok
		#			256 - file not found
		#			256 - no matches
	}

	if ( $? )
	{
		die( "$? - $!" );
	}
	
	temp::replace_with( $to );
	return;
}

1;

########################################################
package temp;

use warnings;
use strict;

#
# TODO : it should be a class
# * a lot of OOP was not implemented because of issues with sort & search & lock & locale & binmode
# * get/set internal handle - is questionable design
# * but creating a rich class (with sort/search/etc.  - methods) too
# * meanwhile - temp:: is used as a kind of singleton - $tmp - is the value here
#

my $tmp = undef;

sub open
{
	CORE::open( $tmp, "+>", undef ) or die "Can not open temporary file.";
	return $tmp;
}

sub open_another
{
	my $handle = undef;
	CORE::open( $handle, "+>", undef ) or die "Can not open extra temporary file.";
	return $handle;
}

sub get_handle
{
	return $tmp;
}

sub set_handle
{
	my $old = $tmp;

	$tmp = shift;

	return $old;
}

sub replace_with
{
	my $file_name_new = shift;
	CORE::open( $tmp, "+<", $file_name_new ) or die( "$!" );
	return;
}

sub close
{
	close( $tmp );
	return;
}

sub prepare
{
	seek( $tmp, 0, 0 );
	return;
}

sub truncate
{
	seek( $tmp, 0, 0 ); # e.g. prepare();
	truncate( $tmp, 0 );

	return;	
}

sub print
{
	# + Works good - prints prompts and printed content in *proper order*, but 
	#
	#	seek( $tmp, 0, 0 );
	#	print <$tmp>;
	#
	# EATS some empty lines! - removed.

	prepare();

	# change autoflush to get correct order of output for 'content' and 'prompts of this shell'
	local $| = 1;

	my $size = get_size_impl( $tmp );
		
	file::pump( $size, $tmp, *STDOUT );

	return;	
}

sub fetch_text_from(*)
{
	my $from = shift;

	my $size = get_size_impl( $from );

	# + may be it is resonable to use here more effective copy as for binaries? 
	# + what about crlf-files?
	# + this copy may fail on "narrow"-data files but lets hope buffering mitigate the issue
	#
	#	while ( <$from> )
	#	{
	#		print $tmp $_;
	#	}
	#
	# IT FAILS FOR REAL FILES! - removed.
	
	file::pump( $size, $from, $tmp );

	return;	
}

sub save_to(*)
{
	my $to = shift;
	my $size = get_size_impl( $tmp );

	prepare();	
	file::pump( $size, $tmp, $to );

	return;	
}

sub get_size
{
	return get_size_impl( $tmp );
}

sub get_size_impl(*)
{
	my $file = shift;

	my $size = 0;

	{
		my $pos = tell( $file );
		seek( $file, 0, 2 ); # 2 == SEEK_END
		$size = tell( $file );
		seek( $file, $pos, 0); # 0 == SEEK_SET
	}
		
	return $size;
}

1;

########################################################
package utils;

use warnings;
use strict;

use constant KB => 1024;
use constant MB => 1024*KB;
use constant GB => 1024*MB;

use constant TINY_FILE => (0);
use constant SMALL_FILE => (64*KB+1);
use constant MEDIUM_FILE => (4*MB+1);
use constant EXTREME_FILE => (64*MB+1);

sub isTiny
{
	my $size = shift;
	return ( ( TINY_FILE <= $size ) && ( $size < SMALL_FILE ) );
}

sub isSmall
{
	my $size = shift;
	return ( ( SMALL_FILE <= $size ) && ( $size < MEDIUM_FILE ) );
}

sub isMedium
{
	my $size = shift;
	return ( ( MEDIUM_FILE <= $size ) && ( $size < EXTREME_FILE ) );
}

sub isExtreme
{
	my $size = shift;
	return ( ( EXTREME_FILE <= $size ) && ( 1 ) );
}

1;

########################################################
package my;

use warnings;
use strict;

# copy, move, delete, 
# print, sort, search, 
# exit

# Notes:
# 1 - invocations of commands are performed sequentially up to the error;

# 2 - invocator does not check their names, so "print 1 | sort | wrong | sort"
# will call "print" & "sort" befor getting run-time error with "wrong";

#--------------------------------------------
sub _copy
{
	my $args = shift or die( message::WRONG_CALL );
	
	my @params = unchain( $args );
	( 2 == @params ) or die( message::COMMAND_SYNTAX_ERROR ); 

	my ( $from, $to ) = @params;

	temp::truncate();
	
	file::copy( $from, $to );
	
	return;
}

sub _move
{
	my $args = shift or die( message::WRONG_CALL );

	my @params = unchain( $args );
	( 2 == @params ) or die( message::COMMAND_SYNTAX_ERROR ); 

	temp::truncate();

	my $success = rename $params[0],$params[1];
	( $success ) or die( message::SYSTEM_ERROR );

	return;
}

sub _delete
{
	my $args = shift or die( message::WRONG_CALL );

	my @params = unchain( $args );
	( 1 == @params ) or die( message::COMMAND_SYNTAX_ERROR ); 

	temp::truncate();

	my $numberDeleted = unlink @params;
	( 1 == $numberDeleted ) or die( message::SYSTEM_ERROR );

	return;
}

#--------------------------------------------
sub _print
{
	my $args = shift or die( message::WRONG_CALL );

	my @params = unchain( $args );	
	( 1 == @params ) or die( message::COMMAND_SYNTAX_ERROR ); 

	my ( $file_name ) = @params;

	open( my $handle, "<", $file_name ) or die( "Can not open file '$file_name': $!" );

	temp::fetch_text_from( *$handle );

	return;
}

sub _sort
{
	my $args = shift or die( message::WRONG_CALL );
	
	my @params = unchain( $args );
	my $count = @params;
	( $count < 2 ) or die( message::COMMAND_SYNTAX_ERROR ); 

	my @data = ();

	my $size = temp::get_size();
	
	if ( my $needToProcessExternalFile = ( 1 == $count ) )
	{
		my ( $file_name ) = shift @params;
		_sort_of_external( $file_name );
	}
	else
	{
		_sort_of_temp();
	}

	return;
}

sub _sort_of_external
{
	my ( $file_name ) = shift;
	
	( -e $file_name ) or die( "Access error: '$file_name': $!" );

	my $file_size = -s $file_name;

	temp::truncate();

	if ( 1 or utils::isTiny( $file_size ) )
	{
		open( my $from, '<', $file_name ) or die( message::INTERNAL_ERROR . ": $!" );
		my $to = "";

		temp::truncate();
		sort::sort_in_memory( $from, \$to );

		my $output = temp::get_handle();
		temp::prepare();
		print $output $to;
		
		close( $from );

		return;
	}

# TODO: No time	
#	{
#		sort::sort_external_utility( $pattern ... );
#		return;
#	}

	return;
}

sub _sort_of_temp
{
	my $file_size = temp::get_size();
	
	if ( 1 or utils::isTiny( $file_size ) )
	{
		my $from = temp::get_handle();
		my $to = "";

		temp::prepare();
		sort::sort_in_memory( $from, \$to );

		temp::truncate();
		print $from $to;

		return;
	}
	
	if ( utils::isSmall( $file_size ) )
	{
		return;
	}
	
	if ( 1 or utils::isMedium( $file_size ) )
	{
		return;
	}

# TODO: No time	
#	{
#		sort::sort_external_utility( $pattern ... );
#		return;
#	}

}

sub _search
{
	my $args = shift or die( message::WRONG_CALL );
	
	my @params = unchain( $args );
	my $count = @params;
	( ( $count > 0 ) && ( $count < 3 ) ) or die( message::COMMAND_SYNTAX_ERROR ); 
	
	my ( $pattern, $file_name ) = @params;
	
	if ( my $needToProcessExternalFile = ( 2 == $count ) )
	{
		_search_of_external( $pattern, $file_name );
	}
	else
	{
		_search_of_temp( $pattern );
	}
	
	return;
}

sub _search_of_external
{
	my ( $pattern ) = shift;
	my ( $file_name ) = shift;
	
	# TODO : Is this racing importnat? < -e -s >
	( -e $file_name ) or die( "Access error: '$file_name': $!" );

	my $file_size = -s $file_name;

	temp::truncate();

	if ( utils::isTiny( $file_size ) )
	{
		open( my $from, '<', $file_name ) or die( message::INTERNAL_ERROR . ": $!" );
		my $to = "";
		
		search::search_in_memory( $pattern, $from, \$to );
		
		my $output = temp::get_handle();
		temp::prepare();
		print $output $to;
		
		close( $from );

		return;
	}

	if ( utils::isSmall( $file_size ) )
	{
		my $memory = "";
	
		open( my $from, '<', $file_name ) or die( message::INTERNAL_ERROR . ": $!" );
		open( my $to, '>', \$memory ) or die( message::INTERNAL_ERROR . ": $!" );

		search::search_line_by_line( $pattern, $from, $to );

		my $output = temp::get_handle();
		temp::prepare();
		print $output $memory;

		return;
	}

	if ( 1 or utils::isMedium( $file_size ) )
	{
		open( my $from, '<', $file_name ) or die( message::INTERNAL_ERROR . ": $!" );
		my $to = temp::open_another();

		search::search_line_by_line( $pattern, $from, $to );
		
		temp::close();              # close old temp-file
		temp::set_handle( $to );    # set new temp-file

		return;
	}

# TODO: No time
#	{
#		search::search_external_utility( $pattern ... );
#		return;
#	}

	return;
}

sub _search_of_temp
{
	my ( $pattern ) = shift;

	my $file_size = temp::get_size();
	
	if ( utils::isTiny( $file_size ) )
	{
		my $from = temp::get_handle();
		my $to = "";

		temp::prepare();
		search::search_in_memory( $pattern, $from, \$to );

		temp::truncate();
		print $from $to;

		return;
	}
	
	if ( utils::isSmall( $file_size ) )
	{
		my $memory = "";
	
		my $from = temp::get_handle();
		open( my $to, '>', \$memory ) or die( message::INTERNAL_ERROR . ": $!" );

		temp::prepare();
		search::search_line_by_line( $pattern, $from, $to );

		temp::truncate();
		print $from $memory;

		return;
	}
	
	if ( 1 or utils::isMedium( $file_size ) )
	{
		my $from = temp::get_handle();
		my $to = temp::open_another();

		temp::prepare();
		search::search_line_by_line( $pattern, $from, $to );
		
		temp::truncate(); 			# for sure only (afair it sets only virtual pointers and does not trancate file on the disk):
		temp::close();              # close old temp-file
		temp::set_handle( $to );    # set new temp-file

		return;
	}

# TODO: No time
#	{
#		search::search_external_utility( $pattern ... );
#		return;
#	}

}

#--------------------------------------------
sub _canredirect
{
	my ( $args ) = shift;
	
	open( my $handle, ">$args" ) or die( "Access denied: '$args': $!" );

	# no action here

	close( $handle );

	return;
}

sub _doredirect
{
	my ( $args, @data ) = @_;
	
	open( my $handle, $args ) or die "Can not open file for output: '$args': $!";

	temp::save_to( $handle );

	close( $handle );

	return;
}

#--------------------------------------------
sub _exit
{
	exit;
}

# simple solution here e.g. without Winsows-" " and Linux-spaces
# TODO : Linux spaces "\ " would be nice
sub unchain
{
	my $args = shift or die( message::INTERNAL_ERROR );
	my @arr = split( ' ', $args );
	return @arr;
}

1;

########################################################
package exec;

use warnings;
use strict;

use constant UNEXPECTED_ERROR => "Unexpected error.";

sub printd # debugging purpose
{
	if ( 0 )
	{
		print @_;
	}
}

sub printe
{
	my $message = shift;
	print STDOUT "0\n";
	print STDERR $message;
}

# TODO: for this task J.E.F.Friedl tells to use 2 regex-es 
# instead of 1 because of preformance purposes.
sub cutspaces
{
	my $var = shift; 
	$var =~ s/^\s+|\s+$//g;
	return $var;
}

my $header = <<'EOT';
# program for evaluation
# start:

my @shared;
{
	temp::open();
}

EOT

my $footer = <<'EOT';
# output if any:
{
	temp::print();
}
# and close temp:
{
	temp::close();
}

# end.
EOT

my $template_std = <<'EOT';
# line: "$line"
# command: "$cmd"
# args: "$args"

{
	my::_$function( ' $parameters ' );
}

EOT

my $template_canredirect = <<'EOT';
# line: "$line"
# command: "$cmd"
# args: "$args"
# check redirect:
{
	# TODO: fix races of _canredirect() & _doredirect() 
	# The space -> '... ' usually important for commands with no arguments!
	my::_canredirect( '$parameters ' );
	
	# TODO: need to 'lock' the target file here and thus
	# (any) next command will fail to access locked file. (No time + Such examples do not work ok).
}

EOT

my $template_doredirect = <<'EOT';
# line: "$line"
# command: "$cmd"
# args: "$args"
# do redirect:
{
	# The space -> '... ' usually important for commands with no arguments!
	my::_doredirect( '$parameters ' );

	# As redirect just has happened - nothing in the buffer now:
	temp::truncate();
}

EOT

sub build_code
{
	my $template = shift or die( UNEXPECTED_ERROR );
	my $line = shift or die( UNEXPECTED_ERROR );
	my $cmd  = shift or die( UNEXPECTED_ERROR );
	my $args = shift;
	
	my $portion	= $template;
	{
		$portion =~ s/\$line/$line/g;
		$portion =~ s/\$cmd/$cmd/g;
		$portion =~ s/\$args/$args/g;
	}

	my $function = cutspaces($cmd);
	my $parameters = cutspaces($args);
	{
		$portion =~ s/\$function/$function/g;
		$portion =~ s/\$parameters/$parameters/g;
	}

	return $portion;
}

sub translate_message_impl
{
	my $line = shift;

	my $code = $header;
	
	while ( $line =~ m/\s*(\w+)([^\|\>]*)(\>\s*[^\>]*)?/g )
	{
		my $redirect = $3 ? $3 : "";
		printd "\npartition: '$&'\n\tcommand: '$1'\t\targs: '$2'\t\tredirect: '$redirect'\n\n";

		if ( $redirect )
		{
			$code .= build_code( $template_canredirect, $redirect, "_canredirect", $redirect );
		}

		if ( 1 == 1 )
		{
			$code .= build_code( $template_std, $&, $1, $2 );
		}
		
		if ( $redirect )
		{
			$code .= build_code( $template_doredirect, $redirect, "_doredirect", $redirect );
		}

	}
	
	$code .= $footer;

	return $code;
}

sub translate_message
{
	my $line = shift or die( UNEXPECTED_ERROR );

	if ( my $wrongLine = ( $line !~ m/^(?:\s*\w+[^\|\>]*)(?:\|\s*\w+[^\|\>]*)*(?:\>\s*[^\|\>\s]+\s*)?$/ ) )
	{
		printe "The syntax of the command is incorrect.\n";
		return undef;
	}

	my $code = translate_message_impl( $line );
	printd "$code\n";

	return $code;
}

sub dispatch_message
{
	my $code = shift or die( UNEXPECTED_ERROR );

	my $result = eval( $code );
	
	if ( $@ )
	{
		chomp( $@ );
		chomp( $! );

		# for "secure": 
		# strip namespace and '_' from 'Undefined subroutine &my::_FUNCTIONNAME...'
		my $secure = $@ =~ s/&my::_//r;
		printe "exception: '$secure', '$!'\n";

		printd "$code\n";
	}
		
}

1;

########################################################
package main;

use warnings;
use strict;

use constant PROMPT => "MySh::>";

my $batch_mode = ( 0 == $#ARGV ); # '( -1 == $#ARGV )' for interactive_mode

print PROMPT;

while ( <> )
{
	{
		if ( $batch_mode )
		{
			print $_; # mirror input to display
		}

		chomp;

		if ( my $skipEmptyEnter = ( $_ =~ m/^\s*$/g ) )
		{
			next;
		}

		my $code = exec::translate_message( $_ );
		if ( my $skipSyntaxErrorToPromptUser = !defined ( $code ) )
		{
			next;
		}

		exec::dispatch_message( $code );
	}

	print PROMPT;
};

# fix of artificial condition
if ( $batch_mode )
{
	print "\n";
}

1;
