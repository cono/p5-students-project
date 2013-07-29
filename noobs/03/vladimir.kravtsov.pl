#!/usr/bin/perl -w
use strict;
use diagnostics;




my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

if ( my $elem = <FH>)
	{
		if (my $str1 = <FH>)
		{
			$elem = " ".$elem." ";
			$elem =~ s/\s/ /g;
			$elem =~ y/ / /s;
			$elem = substr($elem,1,-1);
			unless (length $elem == ($elem =~ y/a-zA-Z_0-9//) and $elem ne "")
			{
					print "error\n";
					die "First line contain error\n";
			}
			
			$str1 = " ".$str1." ";
			$str1 =~ s/\s/ /g;
			$str1 =~ y/ / /s;
			$str1 = substr($str1,1,-1);
			$str1 =~ s/> />/g;$str1 =~ s/ =/=/g;$str1 =~ s/ ,/,/g;$str1 =~ s/, /,/g;
			#print "\n",$str1,"\n";
			$_=substr($str1,-1,1);
			#print "\n",$_,"\n";
			#print m/,/,"g" if  (m{[=,>]});
			unless (length $str1 == ($str1 =~ y/a-zA-Z_=>,0-9//) and $str1 ne "" and !m{[=,>]})
			{
					print "error\n";
					die "Second line contain error\n";
			}
			
			$str1 =~ s/\s//g;
			my $nwp =0;
			my $nd = 0;
			for (my $nw = 0; $nw <= length $str1; $nw ++)
			{
				if ((chr vec($str1, $nw, 8) eq "=") and (chr vec($str1, $nw + 1, 8) eq ">"))
				{
					$nwp++;
				}
				elsif (((chr vec($str1, $nw, 8) eq "=") and (chr vec($str1, $nw + 1, 8) ne ">")) or
						((chr vec($str1, $nw, 8) eq ">") and (chr vec($str1, $nw - 1, 8) ne "=")))
				{
					print "error\n";
					die "Second line contain error\n";
				}
				$nd++ if (chr vec($str1, $nw, 8) eq "," );
				
				unless ( $nwp == $nd+1 or $nwp == $nd or 
						((chr vec($str1, $nw, 8) eq "=") and (chr vec($str1, $nw + 1, 8) eq "=")) or
						((chr vec($str1, $nw, 8) eq ">") and (chr vec($str1, $nw + 1, 8) eq ">")))
				{
					print "error\n";
					die "Second line contain error\n";
				}
				if ( 	((chr vec($str1, $nw, 8) eq "=") and (chr vec($str1, $nw + 1, 8) eq "=")) or
						((chr vec($str1, $nw, 8) eq ">") and (chr vec($str1, $nw + 1, 8) eq ">")))
				{
					print "error\n";
					die "Second line contain error\n";
				}
			
			}

			
			$str1 =~ y/=>,/,/s;
			my $relem = $elem;

			my %hash = split(/,/,$str1);
			print $elem;
			my $loop = 0;
			while ($loop == 0)
			{
				$loop++ if (!exists ($hash{$relem}));
				while ( my ($key, $value) = each(%hash) ) 
				{
					if ($key eq $relem)
					{
						print "-",$value;
						$relem = $value;
						if ($relem eq $elem)
						{
							print "\nlooped\n";
							$loop++;
							last;
						}
						redo;
					}
				}
			}
			
		}
		else
		{
			print "error\n";
			print STDERR "File contain only one string \n";
	
		}
	}
	else
	{
	print "error\n";
	print STDERR "File is empty\n";
	
	}



close ( FH );



