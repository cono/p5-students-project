#!/usr/bin/perl -w
use strict;
use diagnostics;

sub puzzleout
{
	my $pfpipe = shift;
	my $prout = pop;
	unless (defined $pfpipe) {open( FHP, ">", "pipe00"); close FHP; $pfpipe = "pipe00";}
	else {if (@_) {$pfpipe++; open( FHP, ">","$pfpipe"); close FHP}}
	#print "$fpipe\n";
	unless (@_)
	{
		fprint ($pfpipe, $prout);
		$prout = undef;
	}
	else
	{
		$_ = shift @_;
		#next unless (defined ($_));
		if (/^\s*copy\s*(\w+(?:\.?\w+)?)\s+(\w+(?:\.?\w+)?)\s*$/) {fprint ($1, $2); print "$1 $2 $prout\n"}
		#elsif (/^\s*move\s*(\w+(?:\.?\w+)?)\s+(\w+(?:\.?\w+)?)\s*$/) {move($1, $2); $fpipe = undef;}
		#elsif (/^\s*delete\s*(\w+(?:\.?\w+)?)\s*$/) {fdelete ($1); $fpipe = undef;}
		elsif (/^\s*print\s*(\w+(?:\.?\w+)?)\s*$/) {fprint ($1, $pfpipe)}
		#elsif (/^\s*sort(.*$)/) {@comar = fsort ($1, @comar, $rout);}
		#elsif (/^\s*search(.*$)/) {@comar = search ($1, @comar, $rout);}
		elsif (/^\s*exit\s*$/) {
		fdelete ($pfpipe) if (defined $pfpipe); 
		exit;}
		else {print "0\n"; die "unknown command\n";}
		puzzleout ($pfpipe, @_, $prout);
		
	}
	if (@_) {fdelete ($pfpipe) if (defined $pfpipe);}
}

sub fprint
{
	my $fh =  shift;
	my $rout = pop;
	my $fhpr;
	
	if (defined ($fh))
	{
		if (defined ($rout)) {open( FHP, ">", "$rout"); $fhpr = *FHP;} else {$fhpr = *STDOUT}
		unless (open( FH, "<", "$fh")){print "0\n"; die "file not exist"};
		while (<FH>)
		{
			print $fhpr $_;
		}
		close FH;
		close $fhpr if (defined ($rout));
		
	}
}

sub move
{
	my $sors = shift;
	my $dest = pop;
	fprint ($sors, $dest);
	fdelete ($sors);
	
}

sub fdelete
{
	my $dest = shift;
	unless (unlink ("$dest")) {print "0\n"; die "file not exist";}
	
}



#my $test_file_path = $ARGV[0];
#open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my @comar;
my ($comstr, $rout, $fname, $fpipe);

print 'MySh::>';

while ( <STDIN> ) 
{
	$comstr = $_;
	"a" =~ /a/;
	$comstr =~ s/(>.*$)//;
	#print "$1 \n";
	$rout = $1;
	if (defined($rout))	{
	if ($rout =~ /^>\s*(\w+(?:\.?\w+)?)\s*$/ )
	{$rout = $1; } else {print "0\n"; die "bad output file name";} } #perenapravlenie v fayl
	@comar = split(/\|/,$comstr);
	puzzleout (undef, @comar, $rout) unless ($comstr=~/^\s*$/);
	
	$rout = undef;
	@comar =();
	$_ = undef;
	print 'MySh::>';
	
}


#close ( FH );



