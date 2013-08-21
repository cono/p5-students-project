#!/usr/bin/perl -w
use strict;

package Operations;
use File::Copy;

sub openfile  {
	open( FH, "<", "$_[0]" ) or ($!="not found file form openfile",return "0\n");
	my @arr;
	@arr = (<FH>);
	close(FH);
	return @arr;
}

sub search{
	my $search = $_[0];
	shift @_;
	my @arr = @_;
	unless ( defined $_[0] | defined $_[1] ) {
		$! = "a search function is not all input";
		return ("0\n");
	}
	my @rez = grep { $_ =~ /$search/g } @arr;
	return @rez;

}

sub copyfile {
	
	unless ( defined $_[0] | defined $_[1] ) {
		$! = "a copyfile function is not  input";
		return "0\n";
	}
	copy( $_[0], $_[1] ) or 
	($!="error from copyfile",return ("0\n"));
	return '';
}

sub deletefile {
	unless ( defined $_[0] ) {
		$! = "a deletefile function is not  input";
		return ("0\n");
	}
	unlink( $_[0] ) or 
	($!="error from deletefile",return ("0\n"));
	return '';
}
sub sortfile {
	unless ( defined $_[0] ) {
		$! = "a sortfile function is not  input";
		return ("0\n");
	}
	my @arr = sort @_;
	return @arr;
}
sub exitshell { exit 0 }

sub movefile {
	unless ( defined $_[0] | defined $_[1] ) {
		$! = "a movefile function is not  input";
		return ("0\n");
	}
	move( $_[0], $_[1] ) or ($!="not found file form move",return "0\n");
	return "";
}

sub savefile {
	unless ( defined $_[0] ) {
		$! = "a savefile function is not  input";
		return ("0\n");
	}
	my @arr;
	open( FF, ">", "$_[0]" ) or ($!="not found file form savefile",return "0\n");
	shift @_;
	@arr = @_;
	print( FF @arr );
	close(FF);
	return "";
}

sub printfile {
	unless ( defined $_[0] ) {
		$! = "print function is not  input";
		return ("0\n");
		
	}
	return Operations::openfile(@_);
}

package main;

while (1) {
	my $test_file_path = $ARGV[0];
	open( FY, "<", "$test_file_path" ) or return "0\n";
	while (<FY>) {
		print "MySh::>";
		my $input = $_;
		print $input;
		#my $input= <STDIN>;
		#chomp$input;
		if ( $input =~ /[>]/g ) {if($input!~/(\>)[\w\. ]+(\|)+/) {$input =~ s/\>/\>\< /g }else{$! = "output not valid";print "0\n";next;
		}}
		
		my @arr = split( /\||\>/, $input );
		my @rez=("0\n");
		foreach (@arr) {
			if ( $_ =~
/^((\s+)?(?<key>[\w\.\<]+)(\s+)?(?<value>[\w\.]+)?(\s+)?(?<value1>[\w\.]+)?(\s+)?)$/
			  )
			{ 
				my @output = @rez;
				my $in     = $+{value};
				my $in1    = $+{value1};
				my $key    = $+{key};
				if ( $_ =~ />/g ) { $key = '>' }
				if ( $key eq "copy" ) { @rez = Operations::copyfile( $in, $in1 ) ;if($rez[0]eq"0\n"){last}; }
				elsif ( $key eq "delete" ) { @rez = Operations::deletefile($in) ;if($rez[0]eq"0\n"){last}; }
				elsif ( $key eq "search" ) {
					if ( defined $in1 ) { @rez = Operations::openfile($in1) }
					@rez = Operations::search( $in, @rez );if($rez[0]eq"0\n"){last}; 
				}
				elsif ( $key eq "sort" ) {
					if ( defined $in ) { @rez = Operations::openfile($in) }
					@rez = Operations::sortfile(@rez);if($rez[0]eq"0\n"){last}; 
				}
				elsif ( $key eq "move" ) { @rez = Operations::movefile( $in, $in1 );if($rez[0]eq"0\n"){last};  }
				elsif ( $key eq "print" ) { @rez = Operations::printfile($in);if($rez[0]eq"0\n"){last}; }
				elsif ( $key eq "<" ) { @rez = Operations::savefile( $in, @rez ) ;if($rez[0]eq"0\n"){last}; }
				elsif ( $key eq "exit" ) { exit 0 }
				else { $! = "not corret input"; @rez = ("0\n");last }
			}
		}

		print STDOUT @rez;
		print STDERR "$!\n" if ( $rez[0] eq '0' );
	}print "MySh::>exit\n";exit 0;
	close(FY);
}
