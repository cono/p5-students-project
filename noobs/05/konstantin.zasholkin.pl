#!/usr/bin/perl -w
use strict;
use 5.010;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";

my $line;
my $redirect_file;
my $n = 0;

while ($line = <FH>) {
  $n = 1;
   
  chomp $line;
   
  print STDOUT "MySh::>$line\n";
  
  my $exe_redirect = 0;
  
  
  if ($line =~ /^\s+$/) { next }
  
  if ($line =~ />.*\|/) {
    mypackage::printError("Incorrect output redirection");
    next;
  }
  else{
    
    if($line =~ s/>\s*(\w+(?:\.\w+)?)\s*$//){
      $redirect_file = $1;
      $exe_redirect = 1;
    }
  }

  my @arr = split(/\s*\|\s*/, $line);
  my $command;
  my $arr_length = scalar(@arr);

  #single command in line
  if ($arr_length == 1) {
    $command = $arr[0];
    
    if ($exe_redirect == 1){
      if ($command =~ /(?:copy|move|delete)[^\.]/)
      {
        mypackage::RunCommand($command);
        mypackage::Redirect($redirect_file, "empty");
      }
      else
      {
        $command = "$command PIPEOUT";
        mypackage::RunCommand($command);
        mypackage::Redirect($redirect_file, "normal");
      }
    }
    else{
        mypackage::RunCommand($command);
    }
    next;
  }

  while(scalar(@arr) > 0) {
    $command = shift(@arr);
    $arr_length--;
    if ($command =~ /(?:copy|move|delete)[^\.]/) {
      if( !mypackage::RunCommand($command) ) { last }
      if ($exe_redirect == 1){ mypackage::Redirect($redirect_file, "empty") }
      next;
    }
    
    if($command =~ /^\s*sort\s*$|^\s*search\s*\w+\s*$/) {
      $command = "$command PIPEIN";
    }
        
    #command not last result go PIPEOUT
    if ($arr_length != 0) {
      $command = "$command PIPEOUT";
      if( !mypackage::RunCommand($command) ) { last }
    }
    else{
      if ($exe_redirect == 1){
        $command = "$command PIPEOUT";
        if( !mypackage::RunCommand($command) ) { last }
        mypackage::Redirect($redirect_file, "normal");
      }
      else{
        if( !mypackage::RunCommand($command) ) { last }
      }
    }
  }
}
close(FH);
if ($n == 0) { print STDOUT "MySh::>\n"; }




package mypackage;
use File::Copy;

sub RunCommand
{
my $comm = $_[0];

  given($comm){
    
    when(/^\s*(?:copy)\s+(\w+(?:\.\w+)?)\s+(\w+(?:\.\w+)?)\s*$/){
      if(!Copy($1, $2)) { return 0 }
      return 1;
    }
    
    when(/^\s*(?:move)\s+(\w+(?:\.\w+)?)\s+(\w+(?:\.\w+)?)\s*$/){
      if(!Move($1, $2)) { return 0 }
      return 1;
    }
    
    when(/^\s*(?:delete)\s+(\w+(?:\.\w+)?)\s*$/){
      if(!Delete($1)) { return 0 }
      return 1;
    }
    
    when(/^\s*print\s+(\w+(?:\.\w+)?)(?:\s+(\w+))?\s*$/){
      if (!defined($2)) { if(!Print($1, 0)) { return 0 }; return 1; }
      else { if(!Print($1, 1)) { return 0 }; return 1; }
    }
    
    when(/^\s*sort\s+(\w+(?:\.\w+)?)(?:\s+(\w+))?\s*$/){
      if (!defined($2) and ($1 ne "PIPEIN"))    { if(!Sort($1, 0, 0)) { return 0 }; return 1; }
      elsif (defined($2) and ($1 ne "PIPEIN"))  { if(!Sort($1, 0, 1)) { return 0 }; return 1; }
      elsif (!defined($2) and ($1 eq "PIPEIN")) { if(!Sort("", 1, 0)) { return 0 }; return 1; }
      elsif (defined($2) and ($1 eq "PIPEIN"))  { if(!Sort("", 1, 1)) { return 0 }; return 1; }
    }

    when(/^\s*search\s+(\w+)(?:\s+(\w+(?:\.\w+)?))?(?:\s+(\w+))?\s*$/){
      if (!defined($3) and ($2 ne "PIPEIN"))    { if(!Search($1, $2, 0, 0)) { return 0 }; return 1; }
      elsif (defined($3) and ($2 ne "PIPEIN"))  { if(!Search($1, $2, 0, 1)) { return 0 }; return 1; }
      elsif (!defined($3) and ($2 eq "PIPEIN")) { if(!Search($1, "", 1, 0)) { return 0 }; return 1; }
      elsif (defined($3) and ($2 eq "PIPEIN"))  { if(!Search($1, "", 1, 1)) { return 0 }; return 1; }
    }
    
    when(/^\s*exit\s*$/){
      return 1;
    }
      
    default { printError("Bad command format");
             return 0}
  }
}


sub Copy
{
  my ($from, $to) = @_;
  
  if (-e "Pipefile") { unlink "Pipefile";}
  
  if (-e $from) {
    copy($from, $to);
  }
  else{
    printError("Copy Error. Source file not found");
    return 0;
  }
  return 1;
}

sub Move
{
  my ($from, $to) = @_;
  
  if (-e "Pipefile") { unlink "Pipefile";}
  
  if (-e $from) {
    if (-e $to) { unlink $to; }
    
    rename($from, $to);
  }
  else{
    printError("Move Error. Source file not found");
    return 0;
  }
  return 1;
}

sub Delete
{
  if (-e "Pipefile") { unlink "Pipefile";}
  
  if (-e $_[0]) {
    unlink $_[0];
  }
  else{
    printError("Deleted file not found");
    return 0;
  }
  return 1;
}

sub Print
{
  my ($filename, $direction) = @_;
  
  if(!(-e $filename)) {
    printError("Print file not found");
    return 0;
  }
  
  my $fhandle;
  
  if ($direction == 0) { $fhandle = *STDOUT; }
  else{
    open(FWRITE, ">", "Pipefile");
    $fhandle = *FWRITE;
  }
  
  open(FREAD, "<", "$filename");
  
  while (<FREAD>) {
    print $fhandle $_;
  }
  
  close(FREAD);
  close(FWRITE);
  return 1;
}

sub Sort
{
  my ($filename, $indirection, $outdirection) = @_;
  
  my $out_fhandle;
  
  if    ( ($indirection == 0) and ($outdirection == 0) ) { open(FREAD, "<", "$filename"); $out_fhandle = *STDOUT;  }
  
  elsif ( ($indirection == 0) and ($outdirection == 1) ) { open(FREAD, "<", "$filename"); $out_fhandle = *FWRITE; }
  
  elsif ( ($indirection == 1) and ($outdirection == 0) ) {
    if(!(-e "Pipefile")) { printError("Bad command format"); return 0; }
    open(FREAD, "<", "Pipefile");  $out_fhandle = *STDOUT;
  }
  
  elsif ( ($indirection == 1) and ($outdirection == 1) ) {
    if(!(-e "Pipefile")) { printError("Bad command format"); return 0; }
    open(FREAD, "<", "Pipefile");  $out_fhandle = *FWRITE;
  }
  
  my @arr;

  while (<FREAD>) {
    push(@arr, $_);
  }
  close(FREAD);
  
  open(FWRITE, ">", "Pipefile");
  
  @arr = sort {$a cmp $b} @arr;
  
  print $out_fhandle @arr;
  
  close(FWRITE);
  
  if ( ($outdirection != 1) and (-e "Pipefile") ) { unlink "Pipefile";}
  
  return 1;
}


sub Search
{
  my ($search_str, $filename, $indirection, $outdirection) = @_;
  
  my $out_fhandle;
  
  if    ( ($indirection == 0) and ($outdirection == 0) ) { open(FREAD, "<", "$filename"); $out_fhandle = *STDOUT; }
  
  elsif ( ($indirection == 0) and ($outdirection == 1) ) { open(FREAD, "<", "$filename"); $out_fhandle = *FWRITE; }
  
  elsif ( ($indirection == 1) and ($outdirection == 0) ) {
    if(!(-e "Pipefile")) { printError("Bad command format"); return 0; }
    open(FREAD, "<", "Pipefile");  $out_fhandle = *STDOUT;
  }
  
  elsif ( ($indirection == 1) and ($outdirection == 1) ) {
    if(!(-e "Pipefile")) { printError("Bad command format"); return 0; }
    open(FREAD, "<", "Pipefile");  $out_fhandle = *FWRITE;
  }
  
  my @arr;

  while (<FREAD>) {
    push(@arr, $_);
  }
  close(FREAD);
  
  open(FWRITE, ">", "Pipefile");
  
  foreach my $val(@arr)
  {
    if ($val =~ /$search_str/)
    { print $out_fhandle $val; } 
  }
  
  close(FWRITE);
  
  if ( ($outdirection != 1) and (-e "Pipefile") ) { unlink "Pipefile";}
  
  return 1;
}


sub Redirect
{
  my ($filename, $mode) = @_;
  
  open(FWRITE, ">", "$filename");
  
  if ($mode eq "normal") {
    open(FREAD, "<", "Pipefile");
  
    while (<FREAD>) {
      print FWRITE $_;
    }
    close(FREAD);
  }
  
    close(FWRITE);

  if (-e "Pipefile") { unlink "Pipefile";}
  
  return 1;
}

sub printError
{
  print STDOUT "0\n";
  print STDERR "$_[0]\n";            
}
