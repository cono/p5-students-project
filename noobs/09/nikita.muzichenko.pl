#!/usr/bin/perl -w
use strict;
use DBI;

sub database {
	chomp( my $postname = shift );
	chomp( my $port     = shift );
	chomp( my $database = shift );
	chomp( my $user     = shift );
	chomp( my $password = shift );
	my @prepare;
	my $prepare;
	my @param;
	my @arg;
	my @el;
	my $string;
	my $dbh;
	foreach (@_) { $string = $string . $_ }
	my $dsn = "DBI:mysql:database=$database;host=$postname;port=$port";
	eval {$dbh = DBI->connect(
		$dsn, $user,
		$password,
		{
			RaiseError => 1,
			PrintError => 0,
		}
	)};if ($@) {print STDOUT "0\n";
		print STDERR "ERROR not corectly connect : $@\n";
	}
	@prepare = split( /-- end|-- sql/, $string );
	foreach my $el (@prepare) {
		@arg = ("");
		if ( $el =~ /^$/ | $el =~ /^\s+$/ ) { next }
		$prepare = $el;
		eval {
			if ( $prepare =~ /\?/g ) {
				@param   = split( /-- param/, $prepare );
				$prepare = $param[0];
				@arg     = split( /\n/, $param[1] );
			}
			foreach my $el2 (@arg) {
				#if($el2=~/^$/){next};
				@el = ($el2);
				if ( $prepare =~ /(delete)|(update)|(drop)|(insert)|(create)/i ) {
					if ( $prepare =~ /\?/ ) {
						my $sth = $dbh->prepare($prepare);
						@el = split( /,/, $el[0] );
						$sth->execute(@el);
						$sth->finish;
						next;
					}
					else {
						my $sth1 = $dbh->do($prepare)
					
					}
					next;
				}
				my $sth = $dbh->prepare($prepare);
				if ( $el[0] eq "" ) { $sth->execute() }
				else {@el = split( /,/, $el[0] ); $sth->execute(@el) }
while ( my $data = $sth->fetchrow_arrayref ) {     
      foreach(my $i=0;$i<@$data;$i++){
	print @$data[$i];if($i!=@$data-1){print "|"};
}print "\n";}
				$sth->finish;
			}
		};
	}
	if ($@) {$dbh->disconnect();print STDOUT "0\n";
		print STDERR "ERROR not corectly input data: $@\n";
	}$dbh->disconnect();
}
my @arr;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path" ) or die "Can not open test file: $!";
while (<FH>) {
	if ( $_ =~ /-- end|-- sql|-- param/ ) { chomp $_ }
	if ( $_ =~ /^$/ ) { $_ = "" }
	@arr = ( @arr, $_ );
}
close(FH);
&database(@arr);
