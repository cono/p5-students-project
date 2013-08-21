#!/usr/bin/perl -w
use strict;
#use MyFunction;

my @arrEnteredCommands = ();


my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
while ( defined(my $file_string = <FH>)) {
	#проверка строки
	$file_string =~ s/\s*?$//;
	push(@arrEnteredCommands, $file_string);
}
close ( FH );

foreach my $enteredCommand (@arrEnteredCommands){
	my $errCheck = undef;
	#print STDOUT "--------------------------\n";
	print STDOUT "MySh::>".$enteredCommand;#"\n";
	#print STDOUT "--------------------------\n";
	
	#проверка пустой строки.		если пуста€, тогда вывести MySh::>
	if($enteredCommand =~ /^\s*?$/){$errCheck = "Empty command prompt."; print STDOUT "";}
	#проверка на наличие команд.	если нет, тогда ERROR
	if($enteredCommand !~ /copy|delete|move|print|sort|search|exit/){$errCheck = "No command(s) in command prompt."; print STDOUT "0\n";}
	
	if($errCheck){
		
		print STDERR "ERROR: $test_file_path : $errCheck\n";
		next;
	}
	my @arrSingleCommands = ();
	my $lenghtArr = -1;
	if($enteredCommand =~ /\|/){
		if(($enteredCommand =~ />/g)>1){
			$errCheck = "String contains more than 1 [>]";
			next;
		}
		@arrSingleCommands = split(/[|]/, $enteredCommand); #масив команд в 1 строке
		#проверка на наличие > в последней комманде
		for(my $i=0; $i<=(scalar(@arrSingleCommands)-1); $i++){
			if($arrSingleCommands[$i] =~ />/ && $i!=(scalar(@arrSingleCommands)-1)){
				$errCheck = "String contains [>] not as last command.";
				last;
			}
		}
	}
	else{
		#print "ELSE:\n";
		push(@arrSingleCommands, $enteredCommand);
	}
	if($errCheck){
		print STDOUT "0\n";
		print STDERR "ERROR: $test_file_path : $errCheck\n";
		next;
	}
	for(my $i=0; $i<=(scalar(@arrSingleCommands)-1); $i++){
		$lenghtArr += 1;
		#START check command
		if($arrSingleCommands[$i] =~ /copy/){
			if($arrSingleCommands[$i] !~ /^\s*?copy\s+?[\w\.]{1,255}\s+?[\w\.]{1,255}\s*?$/){
				$errCheck = "Command [copy] contains incorrect parameters\n"}
			else{$arrSingleCommands[$i] =~ s/^\s*?copy/myCopy/}
		}
		if($arrSingleCommands[$i] =~ /move/){
			if($arrSingleCommands[$i] !~ /^\s*?move\s+?[\w\.]{1,255}\s+?[\w\.]{1,255}\s*?$/){
				$errCheck = "Command [move] contains incorrect parameters\n"}
			else{$arrSingleCommands[$i] =~ s/^\s*?move/myMove/}
		}
		if($arrSingleCommands[$i] =~ /delete/){
			if($arrSingleCommands[$i] !~ /^\s*?delete\s+?[\w\.]{1,255}\s*?$/){
				$errCheck = "Command [delete] contains incorrect parameters\n"}
			else{$arrSingleCommands[$i] =~ s/^\s*?delete/myDelete/}
		}
		if($arrSingleCommands[$i] =~ /print/){
			if($arrSingleCommands[$i] !~ /^\s*?print\s*?(\s+?[\w\.]{1,255}){0,1}\s*?(>\s*?[\w\.]{1,255}\s*?){0,1}$/){
				$errCheck = "Command [print] contains incorrect parameters\n"}
			else{$arrSingleCommands[$i] =~ s/^\s*?print/myPrint/}
		}
		if($arrSingleCommands[$i] =~ /sort/){
			if($arrSingleCommands[$i] !~ /^\s*?sort\s*?(\s+?[\w\.]{1,255}){0,1}\s*?(>\s*?[\w\.]{1,255}\s*?){0,1}$/){
				$errCheck = "Command [sort] contains incorrect parameters\n"}
			else{$arrSingleCommands[$i] =~ s/^\s*?sort/mySort/}
		}
		if($arrSingleCommands[$i] =~ /search/){
			if($arrSingleCommands[$i] !~ /^\s*?search\s+?.+?\s+?([\w\.]{1,255}){0,1}\s*?(>\s*?[\w\.]{1,255}\s*?){0,1}$/){
				$errCheck = "Command [search] contains incorrect parameters\n"}
			else{$arrSingleCommands[$i] =~ s/^\s*?search/mySearch/}
		}
		if($arrSingleCommands[$i] =~ /exit/){
			if($arrSingleCommands[$i] !~ /^\s*?exit\s*?$/){
				$errCheck = "Command [exit] contains incorrect parameters\n"}
			else{$arrSingleCommands[$i] =~ s/^\s*?exit/myExit/}
		}
		#END check command
		#print "		errCheck: $errCheck\n";
		if(!$errCheck){
			#print "		ENTER CHECK\n";
			my $strSingleCommands = $arrSingleCommands[$i];
			my $functionName = undef;
			my $argument1 = undef;
			my $argument2 = undef;
			my $strOutputRedirection = undef;
			my %hashParameters = ();
			
			if($strSingleCommands =~ />/){
				$strSingleCommands = $`;
				$strOutputRedirection = $';
				$strOutputRedirection =~ s/\s*//g;
			};
			#$strSingleCommands =~ s/^\s*?//g;
			$strSingleCommands =~ s/\s+?/::/g;
			($functionName, $argument1, $argument2) = split(/::/, $strSingleCommands);
			
			if($functionName =~ /myCopy|myDelete|myMove|myExit/){
				%hashParameters = (	'functionName'=>$functionName,
									'key'=>3,
									'argument1'=>$argument1,
									'argument2'=>$argument2,
									'outputRedirection'=>$strOutputRedirection);
			}
			elsif( ($functionName =~ /myPrint|mySort/) && $argument1 ){
				%hashParameters = (	'functionName'=>$functionName,
									'key'=>1,
									'argument1'=>$argument1,
									'argument2'=>$argument2,
									'outputRedirection'=>$strOutputRedirection);
			}
			elsif( ($functionName =~ /mySearch/) && $argument1 && $argument2 ){
				%hashParameters = (	'functionName'=>$functionName,
									'key'=>1,
									'argument1'=>$argument1,
									'argument2'=>$argument2,
									'outputRedirection'=>$strOutputRedirection);
			}
			else{
				%hashParameters = (	'functionName'=>$functionName,
									'key'=>2,
									'argument1'=>$argument1,
									'argument2'=>$argument2,
									'outputRedirection'=>$strOutputRedirection);
			}
			$arrSingleCommands[$i] = {%hashParameters};
		}
		else{
			print STDOUT "0\n";
			print STDERR "ERROR: $test_file_path : $errCheck\n";
			last;
		}
	}
	# »того на выходе мы имеем масив команд в 1 строке, где кажда€ комманда размещена в хэше
	if(!$errCheck){
		my $temporaryFile = undef;
		for(my $i=0; $i<=$lenghtArr; $i++){
			#my ($functionName, $key, $argument1, $argument2) = (@arrSingleCommands->[$i]->{'functionName'}, @arrSingleCommands->[$i]->{'key'}, @arrSingleCommands->[$i]->{'argument1'}, @arrSingleCommands->[$i]->{'argument2'});
			#print "ArgumentsAfterCheck: [$functionName, $key, $argument1, $argument2]\n";
			#помен€ть местами аргументы функции search
			if(@arrSingleCommands->[$i]->{'functionName'} =~ /mySearch/){
				my $tmp = @arrSingleCommands->[$i]->{'argument1'};
				@arrSingleCommands->[$i]->{'argument1'} = @arrSingleCommands->[$i]->{'argument2'};
				@arrSingleCommands->[$i]->{'argument2'} = $tmp;
			};
			if(@arrSingleCommands->[$i]->{'key'} == 2){
				if($temporaryFile){@arrSingleCommands->[$i]->{'argument1'} = $temporaryFile}
				else{
					#сделать какойто выход из цикла с выводом ошибки "0"
					print STDOUT "0\n";
					print STDERR "ERROR: $test_file_path : command without arguments [@arrSingleCommands->[$i]->{'functionName'}]\n";
					last;
				};
			};
			#вызов управл€ющей функции
			#если вернетс€ 0 от print, search, sort тогда не сработали эти функции или myCreateFile
			#copy, move, delete возвращают: 1 - success, 0 - error
			$temporaryFile = executeFunctions(	@arrSingleCommands->[$i]->{'functionName'},
												@arrSingleCommands->[$i]->{'argument1'},
												@arrSingleCommands->[$i]->{'argument2'});
			#обработка результатов работы управл€ющей функции
			#print "OPERATION STATUS: [$temporaryFile]\n";
			if(!$temporaryFile){
				print STDOUT "0\n";
				print STDERR "ERROR: $test_file_path : Some truble in execute command [@arrSingleCommands->[$i]->{'functionName'}]\n";
				last;
			}
			if(@arrSingleCommands->[$i]->{'functionName'} =~ /myExit/){
				
			}
			#если 1 операци€ выдала 0, в следующей строке будет 0
			#обработать exit
			
			if(@arrSingleCommands->[$i+1]->{'key'}){
				if(@arrSingleCommands->[$i+1]->{'key'} == 1){
					MyFunction->myResultPrint($temporaryFile);
					$temporaryFile = undef;
				}
			}
			else{
				if(@arrSingleCommands->[$i]->{'outputRedirection'}){
					MyFunction->myMove($temporaryFile, @arrSingleCommands->[$i]->{'outputRedirection'});
					$temporaryFile = undef;
				}
				else{
					MyFunction->myResultPrint($temporaryFile);
					$temporaryFile = undef;
				}
			}
		}
	}
}

sub executeFunctions {
	my ($functionName, $argument1, $argument2) = @_;
	#print "ArgumentsBeforeExecute: $functionName, $argument1, $argument2\n";
	my @arguments = ($argument1, $argument2);
	my $tmp = MyFunction->$functionName(@arguments);
	return $tmp;
	
	#my @parametrs = qw/1.txt 2.txt/;
	#my $method = "copy";
	#MyPackage->$method(@parametrs);
	
	#my $pkg = 'MyPackage';
	#$pkg->$method(@parameters);
	
}



package MyFunction;
use File::Copy;

#COPY
sub myCopy {
	my ($file, $file2) = ($_[1], $_[2]);
	#print "COPY: $file | $file2\n";
	my $tmp = copy($file, $file2); # return 1 on success, 0 on failure. $! will be set if an error was encountered.
	return $tmp;
};
#DELETE
sub myDelete {
	my $file = $_[1];
	my $tmp;
	$! = 0; # бред какойто, но если не определить эту переменную, то он ее не перезаписывает.
	unlink($file);
	if($!){$tmp = 0}else{$tmp = 1};
	return $tmp;
};
#MOVE
sub myMove {
	my ($file, $file2) = ($_[1], $_[2]);
	#print "MOVE: $file | $file2\n";
	my $tmp = move($file, $file2); # return 1 on success, 0 on failure. $! will be set if an error was encountered.
	return $tmp;
};
#PRINT
sub myPrint {
	my $file = $_[1];
	my @arr = ();
	#print "FILE: $file\n";
	my $err;
	open( FH, "<", "$file") or return 0;
	while ( defined(my $file_string = <FH>)) {
		push(@arr, $file_string);
	}
	close ( FH );
	#print "Printing the file:\n";
	my $tmp = myCreateFile(@arr);
	return $tmp;
};
#SORT
sub mySort {
	my $file = $_[1];
	my @arr = ();
	my $err;
	open( FH, "<", "$file") or return 0;
	#print "The file [$file] sorted.\n";
	while ( defined(my $file_string = <FH>)) {
		push(@arr, $file_string);
	}
	close ( FH );
	@arr = sort @arr;
	my $tmp = myCreateFile(@arr);
	return $tmp;
};
#SEARCH
sub mySearch {
	my ($file, $subString) = ($_[1], $_[2]);
	my @arr = ();
	my $err;
	open( FH, "<", "$file") or return 0;
	#print "Search [$subString] in the file [$file]:\n";
	while ( defined(my $file_string = <FH>)) {
		if($file_string =~ /$subString/){
			push(@arr, $file_string);
		}
	}
	close ( FH );
	@arr = sort @arr;
	my $tmp = myCreateFile(@arr);
	return $tmp;
};
#EXIT
sub myExit {
	exit; #переделать
};


sub myCreateFile {
	my @stringsArrary = @_;
	my $tmpFile = '!__SomeRandomAlphanumeric_SixteenSymbols.txt';
	my $err;
	open( FH, ">", $tmpFile) or return 0;
	foreach my $string (@stringsArrary){
		print FH $string;
	};
	close ( FH );
	return $tmpFile;
}
sub myResultPrint {
	#печать 0
	my $file = $_[1];
	my $err;
	open( FH, "<", "$file") or return 0;
	#print "RESULTS:\n";
	while ( defined(my $file_string = <FH>)) {
		print STDOUT $file_string;
	}
	close ( FH );
	unlink($file);
}


#$temp = performCalc(10, 10);
#print("temp = $temp\n");
sub performCalc {
	my ($firstVar, $secondVar) = @_;
	my $square = sub {
		return($_[0] ** 2);
	};
	return(&$square($firstVar) + &$square($secondVar));
};