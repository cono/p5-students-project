#!/usr/bin/perl -w

use strict;

package MyShell;

#Context parameters
our @context = ();

#OUT
sub printOut {
	chomp(@_);
	foreach my $line (@_) {
		print STDOUT "$line\n";
	}
}

sub printInFile {
	my $file   = shift(@_);
	my @result = @_;
	open( OUT, ">", $file )
	  or warn "Unable to open file $file\n"
	  and print STDOUT "0\n";
	chomp(@result);
	foreach my $line (@result) {
		print OUT $line;
	}
	close(OUT);
}

#PRINT
sub print {
	if ( @_ == 0 ) {
		if ("@context") {
			return 1;
		}
		else {
			warn "No params or context\n";
			return undef;
		}
	}
	if ( @_ > 1 ) {
		warn "Wrong params\n";
		return undef;
	}
	my $file = shift(@_);
	open( FH, "<", $file )
	  or warn "Unable to open $file\n"
	  and return undef;
	my @temp = ();
	@context = readline FH;
	close(FH);
	return 1;

}

#MOVE
sub move {
	if ( @_ < 2 ) { warn "Wrong parametres"; return undef; }
	my ( $old_name, $new_name ) = @_;
	unless ( rename $old_name, $new_name ) {
		warn "Rename is faild! $!\n";
		return undef;
	}
	@context = ();
	return 1;
}

#COPY
sub copy {
	if ( @_ < 2 ) { warn "Wrong parametres"; return undef; }
	my ( $old_file, $new_file ) = @_;
	if ( $old_file eq $new_file ) {
		warn "Unable to copy file with same name: $old_file\n";
		return undef;
	}
	open( IN, "<", $old_file )
	  or warn "Unable to open file: $!\n"
	  and return undef;
	open( OUT, ">", $new_file )
	  or warn "Unable to open file: $!\n"
	  and return undef;
	my @lines = readline IN;
	print OUT @lines;
	close(IN);
	close(OUT);
	@context = ();
	return 1;
}

#SEARCH
sub search {
	my ( $exp, $file, @lines ) = undef;
	my @result = ();
	if ( @_ == 1 ) {
		if ("@context") { $exp = shift(@_); @lines = @context; }
	}
	elsif ( @_ == 2 ) {
		( $exp, $file ) = @_;
		open( FH, "<", $file )
		  or warn "Unable to open $file\n"
		  and return undef;
		@lines = readline FH;
		close(FH);
	}
	else { warn "Wrong parameters"; return undef; }
	foreach my $line (@lines) {
		if ( $line =~ m/$exp/ ) {
			push( @result, $line );
		}
	}
	@context = @result;
	return 1;
}

#SORT
sub sort {
	my @lines = undef;
	if ( @_ == 0 ) {
		if ("@context") {
			@lines = @context;
		}
		else { warn "Wrong sort params"; return undef; }
	}
	else {
		my $file = shift(@_);
		open( INPUT, "<", $file )
		  or warn "Unable to open $file: $!\n"
		  and return undef;
		@lines = readline INPUT;
		close(INPUT);
	}

	@context = sort @lines;
	return 1;
}

#DELETE
sub delete {
	if ( @_ != 1 ) { warn "Wrong parametres"; return undef; }
	if ( unlink( shift(@_) ) ) {
		@context = ();
		return 1;
	}
	else {
		warn "Deleting file can't be complete\n";
		return undef;

	}

}

#EXIT

sub exit {
	exit 1;
}

package main;

my %cmd_hash = (
	"delete"   => \&MyShell::delete,
	"move"     => \&MyShell::move,
	"copy"     => \&MyShell::copy,
	"print"    => \&MyShell::print,
	"sort"     => \&MyShell::sort,
	"search"   => \&MyShell::search,
	"exit"     => \&MyShell::exit,
	"sort >"   => \&MyShell::sortTo,
	"search >" => \&MyShell::searchTo,
	"print >"  => \&MyShell::printTo

);

my @commands     = keys %cmd_hash;
my $global_param = $ARGV[0];

sub mainFunction {
	my $file_to_print        = undef;
	my $inputStr             = shift(@_);
	my @commands_for_execute = ();
	my @params               = ();
	my $IsErr                = undef;
	@MyShell::context = undef;

#if ">" in the final command, crop all commands and file parameter where printing to
	if ( $inputStr =~ /[\>]\s*?(?<filename>[\w\.]+)\s*?$/ ) {
		$inputStr      = $`;
		$file_to_print = $+{filename};
	}
	my @command_lines = split( /\|/, $inputStr );

	#Selecting valid commands with params
	foreach my $cmd (@command_lines) {
		@params = ();    #Clear parameters for new function
		if ( $cmd =~
			/^\s*(?<func>\w+)(\s(?<param1>[\w\.]+))?(\s(?<param2>[\w\.]+))?\s*$/
		  )
		{
			if ( exists $cmd_hash{ $+{func} } ) {

				if ( $+{param1} ) { push( @params, $+{param1} ); }
				if ( $+{param2} ) { push( @params, $+{param2} ); }
				if ( !( &{ $cmd_hash{ $+{func} } }(@params) ) ) {
					warn "Execute canceled\n";
					$IsErr = "Error";
					last;
				}
			}

			else {
				warn "Wrong command\n";
				@commands_for_execute = ();
				$IsErr                = "Error";
				last;
			}
		}
		else {
			warn "Input error";
			$IsErr = "Error";
			last;
		}
	}

	#OUTPUT
	if ($IsErr) {
		print STDOUT "0\n";
	}
	elsif ($file_to_print) {
		if ("@MyShell::context") {
			MyShell::printInFile( $file_to_print, @context );
		}
		else {
			warn "Command returns emty context\n";
			print STDOUT "0\n";
		}

	}
	else {
		if ("@MyShell::context") { MyShell::printOut(@MyShell::context); }
	}

}

#

if ($global_param) {
	open( FH, "<", $global_param ) or die "Can not open test file: $!";
	while (<FH>) {
		print "MySh::>" . $_;
		&mainFunction($_);
	}

	close(FH);
}

else {
	print STDOUT "MySh::>";	
	while (<STDIN>) {		
		&mainFunction($_);
		print STDOUT "MySh::>";
	}
}

