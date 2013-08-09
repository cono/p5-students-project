#!/usr/bin/perl -w 

eval {
  my $test_file_path = $ARGV[0];
  open( FH, "<", "$test_file_path") or die "нет такого файла\n";
  my $name;
  my $i = <FH>;
  $i =~ s/\n//g;
  my $do;
  my $res;
  my $n;
  my @check;
    die "net 1 stroki \n" if($i !~ /(\s*\w+\s*)/g);
    $n    = "\$$i";
    $name = "my \$$i;";
  while(<FH>){ 
    $do .= $_;
  }
  eval($name.$do." dum($n)");
  #основная функция запуска на проверку
  sub dum {
    my $a     = ref($_[0]);
    my $arr   = $_[0];
    my $prob1 = '';
    if($_[1]){
      $prob1 = $_[1];
    }
    if($a eq 'HASH'){
      my $i     = keys($arr)-1;
      my $j     = 0;
      print "{\n";
      for (sort keys $arr){
	my $prob2 = $prob1."\t";
	print $prob2;
	print "'".$_."' => ";
	my $ref   = ref($arr->{$_});
	my $znach = $arr->{$_};
	valid($znach, $ref, $arr, $prob2);
	if($i != $j){
	  print ",";
	}
	print"\n";
	$j++;
      };
      print "$prob1}";
    }elsif($a eq 'ARRAY'){
      my $i     = keys($arr)-1;
      my $j     = 0;
    print "[\n";
    for (sort keys $arr){
	my $prob2  = $prob1." ";
	  print $prob2;
	my $znach = $arr->[$_];
	my $ref   = ref($arr->[$_]);
	valid($znach, $ref, $arr, $prob2);
	if($i != $j){
	  print ",";
	}
	print"\n";
	$j++;
      }
      print "$prob1]";
    }elsif($a eq 'SCALAR'){
      print "'$$arr'";
    }elsif($a eq 'REF'){
      dum($$arr, $prob1);
    }elsif($a eq 'Regexp'){
      print $a;
    }elsif($a eq 'CODE'){
      print $a;
    }elsif($a eq ''){
      print $arr;
    }
  }
  #проверка вложеностей
  sub valid {
    my($znach, $ref, $arr, $prob) = (@_);
    if($ref eq 'HASH' ){
    
      if($arr eq $znach){
	print " $ref";
      }else{
	  dum($znach, $prob);
      }
    }elsif($ref eq ''){
      print "'".$znach."'";
    }elsif($ref eq 'REF'){
      print $ref.":";
      dum($znach, $prob);
    }elsif($ref eq 'SCALAR'){
      print "'$znach'";
    }elsif($ref eq 'ARRAY'){
    
      dum($znach, $prob);
    }elsif($ref eq 'CODE'){
    eval($znach);
      print $ref;
    }elsif($ref eq 'Regexp'){
      print $ref;
    }else{
      my $p = eval { $ref->can('get_struct')};
      print &$p;
    }
  }
  print "\n";
};

if($@){
  print STDERR "$@";
}