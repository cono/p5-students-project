#!/usr/bin/perl -w
#task_05
use strict;
use File::Copy;

package MySh;

sub Run
{	
	my @Result=();
	my @d=();
	my $di=@_;
	($_)=@_;
	
	if ($di==2)
	{	
		my $temp;
		($_,$temp)=@_;
		@d=@$temp;
	};
	m/(.+)/;
	
	if (defined($1))
	{
		
		$_=$1;
		my $stringCom=$1;
		m/^.?(copy|move|delete|print|sort|search|exit)(.+)?/ig;
		my $command=$1;		
		my ($parameter, $pamWr)=split(/[>]/,$2);
		$_=$parameter;
		my $hlamLast=$3;
		if ($command eq 'copy')
		{	
			MyShCommand::myCopy($parameter);
		}
		elsif ($command eq 'move')
		{	
			MyShCommand::myMove($parameter);
		}
		elsif ($command eq 'delete')
		{
			MyShCommand::myDelete($parameter);
		}
		elsif ($command eq 'print')
		{
			@Result=MyShCommand::myPrint($parameter);
		}
		elsif ($command eq 'sort')
		{		
			my @parameter=@d;
			if( $di==2)
			{					
				($_,@d)=@_;
			}
			else
			{
				my ($par0,$par1)=split(/\s/,$parameter);
				@parameter=MyShCommand::myPrint($par1);		
			}
			@Result= MyShCommand::mySort(@parameter);
		}
		elsif ($command eq 'search')
		{
		
			if ($di==1)
			{	
				my ($par0,$par1,$par2)=split(/\s/,$parameter);
				@d=MyShCommand::myPrint($par2);
				$parameter=$par1;
			}
			
			foreach (MyShCommand::mySearch($parameter,\@d))
			{
				push @Result,$_;
			}			
		}
		elsif($command eq 'exit')
		{
			MyShCommand::myExit();
		}	
		if(defined($pamWr))
		{
			$_=$pamWr;			
			$pamWr=~s/[ ]//ig;
			MyShCommand::myWriteToFile($pamWr,\@Result);
			@Result=();
		}
		my @arrayCom=split(/\s/,$stringCom);
	}	
	return @Result;
}
sub printCall
{
	print 'MySh::>';
}
1;

package MyShCommand;
sub myCopy
{
	
    ($_) =@_;	
	m/^[ ]?([\w\d\.]{2,})[ ]([\w\d\.]{2,})/;
	my $hlam1=$1;
	my $hlam2=$2;
	File::Copy::copy($hlam1,$hlam2) if (-e $hlam1);
	do{
		print STDOUT "0\n";
		print STDERR "Absent copyring file\n";
	}if (!(-e $hlam1));
}
sub myMove
{
	($_ ) =@_;	
	m/^[ ]?([\w\d\.]{2,})[ ]([\w\d\.]{2,})/;
	my $hlam1=$1;
	my $hlam2=$2;
	#print "$hlam1\n";
	if (-e $hlam1)
	{
		File::Copy::move($hlam1,$hlam2);
	}
	else
	{		
		print STDOUT "0\n";
		print STDERR "Absent moving file\n";
	};
}
sub myDelete
{	
	
    ($_) =@_;	
	m/^[\s]?([\w\.]{2,})[ ]?/;
	my $hlam1=$1;
	if (-e $hlam1)
	{
		unlink($hlam1);
	}
	else
	{		
		print STDOUT "0\n";
		print STDERR "Absent deleting file\n";
	};
}
sub myPrint
{	
	my @result;
    ($_) =@_;	
	m/^[ ]?([\w\d\.]{2,})[ ]?/;
	my $hlam1=$1;
	if (open( FH, "<", "$hlam1"))
	{
		 while(<FH>)
		 {
			push @result,$_;
		 };
		 return @result;
	}
	else
	{		
		print STDOUT "0\n";
		print STDERR "Absent copyring file\n";
	};
	
	
}
sub mySort
{
	my @str;
    (@str) =@_;	
	sort(@str);	
}
sub mySearch
{
	my @result;
	my $temp;
	($_,$temp)=@_;
	s/[ ]//ig;
	my $patern=$_;

    foreach (@$temp)
	{		
		push @result,$_ if ($_=~/$patern/);
	}	
	return @result;
}		
sub myWriteToFile
{
	my $temp;
    ($_,$temp) =@_;		
	s/[ ]//ig;
	my $hlam1=$_;
	if (open( FH ,">",$hlam1))
	{
		foreach (@$temp)
		{						
			print FH $_;
		}
		close(FH);
	}	
	else
	{		
		print STDOUT "0\n";
		print STDERR "Can't write or create file\n";
	};
}
sub myExit
{
	exit;
}
1;
my $test_file_path = $ARGV[0];
open( FHI, "<", $test_file_path) or die "Can not open test file: $!";
while (<FHI>)
{
	s/[\n]//ig;
	MySh::printCall();
	
	if ($_)
	{
		print $_."\n";
		s/[\s]{2,}/ /ig;

		my @pipeDelim=split(/\|/,$_);
		my @result=();
		for (my $i=0;$i<scalar(@pipeDelim);$i++)
		{		
			if ($i==0)
			{
				@result=MySh::Run($pipeDelim[$i]);		
			}
			else
			{		
				@result= MySh::Run($pipeDelim[$i],\@result);			
			}
		}
		foreach (@result)
		{
			print;
		}
	}
	else
	{
		print "\n";
	}
}
close(FHI);
#TEST::test1();TEST_NEW::fuck('BLA');
