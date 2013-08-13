#!/usr/bin/perl -W

use strict;
use DBI;



my $dsn;
my $user;
my $password;

my $test_file_path = $ARGV[0];

open( FHI, "<", $test_file_path) or die "Can not open test file: $!";
my $freestring=0;
my @inpparam=('myhost','myport','mydatabase','myuser','mypassword');
my $myhost;
my $myport;
my $mydatabase;
my $myuser;
my $mypassword;
my %myconnectdata;
my $count=0;
my $flagrequest=0;
my $request='';
my $succesconnect;
my $dbh;
while(<FHI>)
{
	chomp;
	if ($_ ne '' && $count<5)
	{
		$myconnectdata{"$inpparam[$count]"}=$_;
		$count++;
		$freestring=1;
		$succesconnect=1;
	}	
	if ($count==5 && $succesconnect==1)
	{
		my $dsn = "DBI:mysql:database=".$myconnectdata{$inpparam[2]}.";host=".$myconnectdata{$inpparam[0]}.";port=".$myconnectdata{$inpparam[1]};
		my $user = $myconnectdata{$inpparam[3]};
		my $password = $myconnectdata{$inpparam[4]};
		eval 
		{
		$dbh = DBI->connect($dsn, $user, $password,
													{
														RaiseError => 1,
														PrintError => 0,
												#       AutoCommit => 0
													}
								);	
		};
		if ($@)
		{
			print STDOUT "0\n";
			print STDERR "Can't connect to database\n".$@."\n";
			exit 1;
		}
		if ($dbh->ping) 
		{
			$succesconnect=2;
		}
		else
		{
			print STDOUT "0\n";
			print STDERR "Can't connect to database\n";
			exit 1;
		}
	}
	$freestring=2 if ($freestring==1 && $_ eq '');
	if ($freestring==2)
	{
		if($_ eq '')
		{
			$request='';
			next;			
		}
		else
		{	
			my $subbegin='-- sql';
			my $subend='-- end';
			$flagrequest =2 if ($_=~/$subbegin/i );
			if ($_=~/$subend/i )
			{
				my $subparam='-- param';
				if ($request=~/$subparam/i)
				{
					$_=$request;
					
					m/(.+)--[ ]param(.+)/i;
					
					my $zapros=$1;
					my $param=$2;
					$zapros=~s/[\s]{2,}//ig;
					$param=~s/[\s]{2,}//ig;
					if (defined($param))
					{
						if ($request=~/\?/i)
						{
							my $countLocalSimbolQuastion+=s/\?//ig;							
							my @er=split(/[,\s]/,$param);
							my @localparam=();
							foreach (@er)
							{
								push @localparam,$_ if ($_ ne '' && $_ ne 'undef')	;								
							}
							
							
							if ( ! (scalar(@localparam) % $countLocalSimbolQuastion))
							{			
								if ($request=~/^select/i)
								{
									my $sth;			
									for(my $i=0;$i<scalar(@localparam);$i+=$countLocalSimbolQuastion)
									{
										my $localParametrsForRequest='';
										#my $localParametrsForRequest="'";
										for (my $y=$i;$y<$i+$countLocalSimbolQuastion;$y++)
										{
											$localParametrsForRequest.=$localparam[$y] if ($y==$i);
											$localParametrsForRequest.=",".$localparam[$y] if ($y!=0 && $countLocalSimbolQuastion!=1);
											#$localParametrsForRequest.=$localparam[$y]."'" if ($y==$i);
											#$localParametrsForRequest.=",'".$localparam[$y]."'" if ($y!=0 && $countLocalSimbolQuastion!=1);
										}
										#print "!!!!!$localParametrsForRequest!!!!!!\n";
										eval
										{
											$sth = $dbh->prepare($zapros);
											$sth->execute($localParametrsForRequest);
											my $ar=$sth->{NAME};
											while (my $ans = $sth->fetchrow_hashref) 
											{	
												for (my $i=0;$i<scalar(@$ar);$i++)
												{									
													print "$ans->{@$ar[$i]}" if ($i==0);
													print "|$ans->{@$ar[$i]}" if ($i!=0);
												}
												print "\n";
											}	
										};
										if ($@) 
										{
											print STDOUT "0\n";
											print STDERR "Error happened: $@\n";
										}	
									}	
									#$sth->finish;
								}
								else
								{
									my $sth;
									#print 'scalar(@localparam):'.scalar(@localparam)."\n";
									#print '$countLocalSimbolQuastion:'."$countLocalSimbolQuastion\n";
									for(my $i=0;$i<scalar(@localparam);$i+=$countLocalSimbolQuastion)
									{
										my $localParametrsForRequest='';
										#my $localParametrsForRequest="'";
										for (my $y=$i;$y<$i+$countLocalSimbolQuastion;$y++)
										{
											$localParametrsForRequest.=$localparam[$y] if ($y==$i);
											$localParametrsForRequest.=",".$localparam[$y] if ($y!=0 && $countLocalSimbolQuastion!=1);
											#$localParametrsForRequest.=$localparam[$y]."'" if ($y==$i);
											#$localParametrsForRequest.=",'".$localparam[$y]."'" if ($y!=0 && $countLocalSimbolQuastion!=1);
										}
										eval
										{
											$sth = $dbh->do($zapros,undef,split(/,/,$localParametrsForRequest));
										};
										if ($@) 
										{
											print STDOUT "0\n";
											print STDERR "Error happened: $@\n";
										}				 
									}		
								}
								if ($@) 
								{
									print "Error happened: $@\n";
								}
									
							}
							else
							{
								print STDOUT "0\n";
								print STDERR "Incorrect quantity of parametrs\n";
							}
						}
					}
					else
					{		
						print STDOUT "0\n";
						print STDERR "Can't find parameters\n";
					}
				}
				else
				{	
					$request=~s/[\s]{2,}//ig;
					if (($request=~/\?/i && $request!~/$subparam/i) ||($request!~/\?/i && $request=~/$subparam/i))
					{
						print STDOUT "0\n";
						print STDERR "Can't find parameters\n";
						#next;
					}

#
					if ($request!~/^select/i)
					{	
						eval 
						{
							my $sth = $dbh->do($request);
						};
						if ($@) 
						{
							print STDOUT "0\n";
							print STDERR "Error happened: $@\n";
						}
					}
					else
					{
						eval 
						{
							my $sth = $dbh->prepare($request);
							$sth->execute;	
							my $ar=$sth->{NAME};
							while (my $ans = $sth->fetchrow_hashref) 
							{	
								for (my $i=0;$i<scalar(@$ar);$i++)
								{									
									print "$ans->{@$ar[$i]}" if ($i==0);
									print "|$ans->{@$ar[$i]}" if ($i!=0);
								}
								print "\n";
							}
							$sth->finish;
						};
						if ($@) 
						{
							print STDOUT "0\n";
							print STDERR "Error happened: $@\n";
						}
					}					
				}
				$flagrequest=1;
				$request='';
			}
			if ($flagrequest==2)
			{	
				if (!($_=~/$subbegin/i))
				{
					$request.=$_." ";
				}
				else
				{next;}
			}			
		}
	}	
}
close(FHI);
$dbh->disconnect;