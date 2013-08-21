#!/usr/bin/perl -w 
use strict;
my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my ($string, $i, %res);
eval {
  while(<FH>){
    $i++; #просто решил сделать так
    if($i == 1){
      die "bad data string" if(/[^\w\s]/g);
      $string = $_;
      next;
    }
    if(m/^\s*?(['"]?)(\w*)(\1)\s*?=>?\s*?(["']?)(\w*)(\4)\s*?(\#(.)*?)*?$/){ #проверяем правельность вхождения хэша с ковычками и без
	$res{$2} = $5;
    }else{
      next if(m/^#/); #если есть коментарии переходим к следующему циклу
      $_ =~ s/\s//g;
      next if($_ eq "");
      die "bad data in array string - $i"; #если не перешли к следующему циклу то ошибка
    }
  }
};
for(reverse sort keys %res){
  if($string =~ /(?!\<\.*?)$_(?!\.*?\>)/){
   $string = $`."<".$res{$_}.">".$';#ставим метки чтобы больше не заменять
   redo; #проверяем ещё раз на наличие
  };
}
  $string =~ s/<|>//g;#убираем метки
if( $@ ){ 
  print "0\n";
  warn("$@\n");
  exit -1; 
}else{
  print STDOUT $string;
  exit 0;
};