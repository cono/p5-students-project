#!/usr/bin/perl
package MySh;

sub myCopy {
	if ( scalar(@_) == 2 ) { 
		my ($from, $to) = @_;
		use File::Copy;
		#print "MySh::>copy $from $to\n";
		if ( $from eq $to ) {
			print "0\n";
			print STDERR  "File $from cannot be copied to itself.\n";
			return 0;
		}
		else {
			if  ( copy($from, $to) ) {
				return 1;
			}
			else {
				print "0\n";
				print STDERR  "File $from cannot be copied to $to.\n";
				return 0;
			}
		}
	}
	else {
		print "0\n";
		print STDERR "Wrong number of parameters in copy command\n";
		return 0;
	}
}
sub myDelete {
	if ( scalar(@_) == 1 ) { 
		my ($file) = @_;
		#print "MySh::>delete $file\n";
		if ( unlink($file) == 0 ) {
			print "0\n";
			print STDERR  "File $file cannot be deleted.\n";
			return 0;
		}
		else {
			return 1;
		}
	}
	else {
		print "0\n";
		print STDERR "Wrong number of parameters in delete command\n";
		return 0;
	}
}
sub myMove {
	if ( scalar(@_) == 2 ) { 
		my ($from, $to) = @_;
		use File::Copy qw(move);
		#print "MySh::>move $from $to\n";
		if ( $from eq $to ) {
			print "0\n";
			print STDERR  "File $from cannot be moved to itself.\n";
			return 0;
		}
		else {
			if  ( move($from, $to) ) {
					return 1;
			}
			else {
				print "0\n";
				print STDERR  "File $from cannot be moved to $to.\n";
				return 0;
			}
		}
	}
	else {
		print "0\n";
		print STDERR "Wrong number of parameters in move command\n";
		return 0;
	}
}
sub myPrint {
	if ( (scalar(@_) == 1) || (scalar(@_) == 2) ) {
		$f = *STDOUT;
		my ($file, $fileOut) = @_;
		if ( !$fileOut eq '' ) {
			if ( open(F_OUT, '>', $fileOut) ) {
				$f = *F_OUT;
			}
			else {
				print "0\n";
				print STDERR  "FileOut $file cannot be opened.\n";
				return 0;
			}			
		}
		#print "MySh::>print $file\n";
		if  ( open(F_IN, $file) ) {
			@file = <F_IN>;
			if ( close(F_IN) ) { 
				print $f @file;
				if ( !$fileOut eq '' ) {
					if ( !close($f) ) {
						print "0\n";
						print STDERR  "FileOut $file cannot be closed.\n";
						return 0;
					}
				}
				return 1;
			}
			else {
				print "0\n";
				print STDERR  "File $file cannot be closed.\n";
				return 0;
			}
		}
		else {
			print "0\n";
			print STDERR  "File $file cannot be printed.\n";
			return 0;
		}
	}
	else {
		print "0\n";
		print STDERR "Wrong number of parameters in print command\n";
		return 0;
	}
}
sub checkFileName {
	if ( scalar(@_) == 1 ) {
		my ($s) = @_;
		$result = $s =~ m/^([a-z_0-9]+\.[a-z_0-9]+)$/i;
		if ( $result ) {
			return $1;
		}
		#else {
		#	print "0\n";
		#	print STDERR "Name of the file is not alphanumeric_ \n";
		#	return 0;
		#}
	}
	else {
		print "0\n";
		print STDERR "Wrong number of parameters in checkFileName \n";
		return 0;
	}
}
sub mySort {
	if ( (scalar(@_) == 1) || (scalar(@_) == 2) || (scalar(@_) == 3) ) {
		$f = *STDOUT;	
		my ($file, $fileOut, $pipe) = @_;
		if ( $pipe ) {
			@file = split /\n/, $file;
			for ( my $i = 0; $i < scalar(@file); $i++ ) {
				$file[$i] = "$file[$i]\n"; 
			}
		}
		else {
			if ( open(F_IN, $file) ) {
				@file = <F_IN>;
				if ( !close(F_IN) ) { 
					print "0\n";
					print STDERR  "File $file cannot be closed.\n";
					return 0;
				}
			}
			else {
				print "0\n";
				print STDERR  "File $file cannot be sorted.\n";
				return 0;
			}
		}
		#print "[@file]\n";
		if ( !$fileOut eq '' ) {
			if ( open(F_OUT, '>', $fileOut) ) {
				$f = *F_OUT;
			}
			else {
				print "0\n";
				print STDERR  "FileOut $file cannot be opened.\n";
				return 0;
			}			
		}
		#print "MySh::>sort $file\n";
		#print "[@file]\n";
		if ( scalar(@file) == 0 ) { 
			print "\n";
		}
		else {
			@file = sort @file;
			print $f @file;
		}
		if ( !$fileOut eq '' ) {
			if ( !close($f) ) {
				print "0\n";
				print STDERR  "FileOut $file cannot be closed.\n";
				return 0;
			}
		}
		return 1;
	}
	else {
		print "0\n";
		print STDERR "Wrong number of parameters in sort command\n";
		return 0;
	}
}
sub mySearch {
	if ( (scalar(@_) == 2) || (scalar(@_) == 3) || (scalar(@_) == 4)) { 
		$f = *STDOUT;
		my ($text, $file, $fileOut, $pipe) = @_;
		if ( $pipe ) {
			@file = split /\n/, $file;
			for ( my $i = 0; $i < scalar(@file); $i++ ) {
				$file[$i] = "$file[$i]\n"; 
			}
		}
		else {
			if ( open(F_IN, $file) ) {
				@file = <F_IN>;
				if ( !close(F_IN) ) { 
					print "0\n";
					print STDERR  "File $file cannot be closed.\n";
					return 0;
				}
			}
			else {
				print "0\n";
				print STDERR  "File $file cannot be sorted.\n";
				return 0;
			}
		}
		#print "[@file]\n";
		if ( !$fileOut eq '' ) {
			if ( open(F_OUT, '>', $fileOut) ) {
				$f = *F_OUT;
			}
			else {
				print "0\n";
				print STDERR  "FileOut $file cannot be opened.\n";
				return 0;
			}			
		}
		#print "MySh::>sort $file\n";
		$countPrint = 0;
		foreach $m (@file) {
			if ( (index $m, $text) > -1 ) {
				print $f $m;
				$countPrint++;
			}
		}
		if ( $countPrint == 0 ) {
			print $f "\n";
		}
		if ( !$fileOut eq '' ) {
			if ( !close($f) ) {
				print "0\n";
				print STDERR  "FileOut $file cannot be closed.\n";
				return 0;
			}
		}
		return 1;				
	}
	else {
		print "0\n";
		print STDERR "Wrong number of parameters in search command\n";
		return 0;
	}	
}
1;
package main;
sub spaceNormalizeStr {
	if ( scalar(@_) == 1 ) {
		my ($s) = @_;
		$s =~ s/^[\r\n\s]+//;
		$s =~ s/[\r\n\s]+$//;
		$s =~ s/\s{2,}|\n/ /g;
		return $s;
	}
	else {
		print "0\n";
		print STDERR "Wrong number of parameters in spaceNormalizeStr \n";
		return 0;
	}
}
sub splitStrByPipe {
	if ( scalar(@_) == 1 ) {
		my ($s) = @_;
		@result = split /\s*\|\s*/, $s;
		$resultLength = scalar(@result);
		for ( my $i = 0; $i < $resultLength; $i++ ) {
			$result[$i] = spaceNormalizeStr($result[$i]);
		}
		return @result;
	}
	else {
		print "0\n";
		print STDERR "Wrong number of parameters in splitStrByPipe \n";
		return 0;
	}
}
sub pipeCommandsAnalyzer (@) {
	my $v;
	# save STDOUT
	open(STDOUT_SAVE, ">&STDOUT");
	close STDOUT;
	# redirect STDOUT into variable $v
	open(STDOUT, '>', \$v);
	my @pipeArray = @_;
	$isCommandError = 0;
	for ( my $i = 0; $i < scalar(@pipeArray); $i++ ) {
		$pipeCommand = $pipeArray[$i];
		if ( $i == $#pipeArray ) {
			close(STDOUT);
			open(STDOUT, ">&STDOUT_SAVE");
		}
		$l = length $oldV;
		#print STDERR "$i)$v\n$l\n";
		$oldV = $v;		
		$v = substr $v, $l;
		if ( !getShellCommand($pipeCommand, 1, $v) ) {
			$isCommandError = 1;
			last;
		}
		
	}
	close(STDOUT);
	open(STDOUT, ">&STDOUT_SAVE");
	if ( $isCommandError ) {
		@lastSTDOUT = split /\n/, $v;
		for ( $i = 0; $i < scalar(@lastSTDOUT); $i++ ) {
			if ( $lastSTDOUT[$i] eq 0 ) {
				print "0\n";
				last;
			}
		}
	}
}

sub getShellCommand {
	if ( scalar(@_) == 1 || scalar(@_) == 2 || scalar(@_) == 3) {
		my ($s, $pipe, $v) = @_;
		$result = $s =~ m/^(copy|delete|move|print|sort|search|exit)\s*(.*)\s*$/;
		if ( $result ) {
			$command = $1;
			$params = $2;
			if ( $command eq 'copy' ) {
				$varParams = $params =~ m/^(.+?)\s+(.+)$/i;
				if ( $varParams ) {
					$param1 = $1;
					$param2 = $2;
					if ( MySh::checkFileName($param1) && MySh::checkFileName($param2) ) {
						return MySh::myCopy($param1, $param2);
					}
				}
				#else {
					if ( $pipe ) {
						close(STDOUT);
						open(STDOUT, ">&STDOUT_SAVE");					
					}
					print "0\n";
					print STDERR "Can not recognize $command params \n";
					return 0;
				#}
			}
			elsif ( $command eq 'delete' ) {
				$param1 = $params;
				if ( MySh::checkFileName($param1) ) {
					return MySh::myDelete($param1);
				}
			}
			elsif ( $command eq 'move' ) {
				$varParams = $params =~ m/^(.+?)\s+(.+)$/i;
				if ( $varParams ) {
					$param1 = $1;
					$param2 = $2;
					if ( MySh::checkFileName($param1) && MySh::checkFileName($param2) ) {
						return MySh::myMove($param1, $param2);
					}
				}
				#else {
					if ( $pipe ) {
						close(STDOUT);
						open(STDOUT, ">&STDOUT_SAVE");					
					}
					print "0\n";
					print STDERR "Can not recognize $command params \n";
					return 0;
				#}
			}
			elsif ( $command eq 'print' ) {
				$varParams = $params =~ m/^(.+?)\s*(?:>\s*(.+))*$/i;
				if ( $varParams ) {
					$param1 = $1;
					$param2 = $2;
					if ( MySh::checkFileName($param1) ) {
						if ( $param2 eq '' ) {
							return MySh::myPrint($param1);
						}
						elsif ( MySh::checkFileName($param2) ) {
							return MySh::myPrint($param1, $param2);
						}
					}
				}
				#else {
					if ( $pipe ) {
						close(STDOUT);
						open(STDOUT, ">&STDOUT_SAVE");					
					}
					print "0\n";
					print STDERR "Can not recognize $command params \n";
					return 0;
				#}
			}
			elsif ( $command eq 'sort' ) {
				if ( $params eq '' ) {
					$varParams = 1;
					$param1 = '';
					$param2 = '';
				}
				else {
					$varParams = $params =~ m/^([a-z_0-9]+\.[a-z_0-9]+)*\s*(?:>\s*([a-z_0-9]+\.[a-z_0-9]+)\s*)*$/i;
					if ( $varParams ) {
						$param1 = $1;
						$param2 = $2;
					}
				}
				if ( $varParams ) {
					if ( $param1 eq '' ) {
						if ( $v eq '' ) {
							if ( $pipe ) {
								close(STDOUT);
								open(STDOUT, ">&STDOUT_SAVE");					
							}
							print "0\n";
							print STDERR "Params of $command is empty \n";
							return 0;						
						}
						else {
							if ( $param2 eq '' ) {
								return MySh::mySort($v, '', $pipe);
							}
							#elsif ( MySh::checkFileName($param2) ) {
							else {
								return MySh::mySort($v, $param2, $pipe);
							}
						}
					}
					else {
						#if ( $pipe ) {
						#	close(STDOUT);
						#	open(STDOUT, ">&STDOUT_SAVE");					
						#}
						if ( MySh::checkFileName($param1) ) {
							if ( $param2 eq '' ) {
								return MySh::mySort($param1);
							}
							#elsif ( MySh::checkFileName($param2) ) {
							else {
								return MySh::mySort($param1, $param2);
							}
						}
					}
				}
				#else {
					if ( $pipe ) {
						close(STDOUT);
						open(STDOUT, ">&STDOUT_SAVE");					
					}
					print "0\n";
					print STDERR "Can not recognize $command params \n";
					return 0;
				#}
			}
			elsif ( $command eq 'search' ) {
				$varParams = $params =~ m/^([^\s]+)\s*([a-z_0-9]+\.[a-z_0-9]+)*\s*(?:>\s*([a-z_0-9]+\.[a-z_0-9]+)*\s*)*$/i; #word file1 file2
				if ( $varParams ) {
					$param1 = $1;
					$param2 = $2;
					$param3 = $3;
					if ( $param2 eq '' ) {
						if ( $v eq '' ) {
							if ( $pipe ) {
								close(STDOUT);
								open(STDOUT, ">&STDOUT_SAVE");					
							}
							print "0\n";
							print STDERR "Params of $command is empty \n";
							return 0;						
						}
						else {
							if ( $param3 eq '' ) {
								#print STDERR "1) $param1,  2) $param2, 3) $param3";
								return MySh::mySearch($param1, $v, '', $pipe);
							}
							#elsif ( MySh::checkFileName($param3) ) {
							else {
								return MySh::mySearch($param1, $v, $param3, $pipe);
							}
						}
					}
					else {
						#if ( $pipe ) {
						#	close(STDOUT);
						#	open(STDOUT, ">&STDOUT_SAVE");					
						#}
						#if ( MySh::checkFileName($param2) ) {
						#print STDERR "1) $param1,  2) $param2, 3) $param3";
							if ( $param3 eq '' ) {
								return MySh::mySearch($param1, $param2);
							}
							#elsif ( MySh::checkFileName($param3) ) {
							else {
								return MySh::mySearch($param1, $param2, $param3);
							}
						#}
					}
				}
				#else {
					if ( $pipe ) {
						close(STDOUT);
						open(STDOUT, ">&STDOUT_SAVE");					
					}
					print "0\n";
					print STDERR "Can not recognize $command params \n";
					return 0;
				#}
			}
			elsif ( $command eq 'exit' ) {
				last;
				return 1;
			}			
		}
		else {
			if ( $pipe ) {
				close(STDOUT);
				open(STDOUT, ">&STDOUT_SAVE");					
			}
			print "0\n";
			print STDERR "Can not recognize shell command \n";
			return 0;
		}
	}
	else {
		if ( $pipe ) {
			close(STDOUT);
			open(STDOUT, ">&STDOUT_SAVE");					
		}	
		print "0\n";
		print STDERR "Wrong number of parameters in getShellCommand \n";
		return 0;
	}	
}
#file shell commands analyzer
die "No data file" unless @ARGV;
open(F_IN, $ARGV[0]) or die "Open file data error\n $!";
@file = <F_IN>;
close(F_IN) or die $!;
foreach $fileStr (@file) {
	$s = spaceNormalizeStr($fileStr);
	@redirectOutCheck = split /\s*>\s*/, $s;
	if ( scalar(@redirectOutCheck) > 2 ) {
		print "MySh::>$s\n";
		print "0\n";
		print STDERR "More than one file output redirection \n";
		last;
	} elsif ( scalar(@redirectOutCheck) == 2 ) {
		if ( ! MySh::checkFileName($redirectOutCheck[1]) ) {
			print "MySh::>$s\n";
			print "0\n";
			print STDERR "File output redirection error\n";
			last;
		}
	}
	
	
	@pipeCommandsArray = splitStrByPipe($s);
	if ( scalar(@pipeCommandsArray) == 1 ) {
		print "MySh::>$s\n";
		getShellCommand($s);
	}
	else {
		print "MySh::>$s\n";
		pipeCommandsAnalyzer (@pipeCommandsArray);
	}
}
if ( !($s eq 'exit') ) {
	print "MySh::>\n";
}
