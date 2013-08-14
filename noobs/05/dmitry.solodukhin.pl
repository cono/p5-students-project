#!/usr/bin/perl -w 
use strict;
my $test_file_path = $ARGV[0];

#создаём пакет управления файлами
package Shell{
  my @fh;
  eval{
    #копирование файлов
    sub Copy{
      Printer($_[0]) or return "0";
      Writen($_[1]) or return "0";
      return 1;
    };

    #перемещение файлов
    sub move{
      Copy($_[0],$_[1]) or return 0;
      Delete($_[0]) or return 0;
      return 1;
    };

    #удаление файлов
    sub Delete{ 
      if(!unlink ($_[0])){
      print STDERR "система не может удалить такой файл $_[0]\n";
      return "0";
      }
      @fh = ();
      return 1;
    };

    #чтение файла
    sub Printer{
      return 0 if ($_[0] eq '');
      if(!open( FH, "<", $_[0])){
       print STDERR "система не может прочитать такой файл\n";
       return "0";
      }
      @fh = <FH>;
      return 1;
    };
    
    #вывод на зкран
    sub DO{
      eval($_[0]) or return 0;
      return 1;
    };

    #сортировка данных
    sub Sort{
      unless($_[0] eq ''){
	Printer($_[0]);
      }  
      my @f = @fh;
      @fh = ();
      @fh = sort {$a cmp $b} values @f;
      return 1;
    };

    #поиск строк
    sub search{
      my $finder = $_[0];
      return "0" if($finder eq '');
      my @array;
      unless($_[1] eq ''){
	Printer($_[1]);
      }  
      @array = @fh; 
      return "0" unless(@array);
      @fh = ();
      @fh = grep /$finder/, @array; 
      return 1;
    };
    
    #записываем в файл
    sub Writen{
      return "0" if($_[0] eq '');
      unless(open(FT, ">", $_[0])){
	print STDERR "система не может создать такой файл\n";
	return "0";
      }
      print(FT @fh);
      close(FT);
      @fh = ();
      return 1;
    };
    
    #вывод результатов на экран
    sub Viv{
      print @fh;
    };
    
    #выход
    sub Exit{
      print "\n";
      exit;
    };
  }
}
eval{
  open( GH, "<", "$test_file_path");
  while(<GH>){
    if($_=~ m/\|$/g){print "0\n"; next;};
    $_ =~ s/\n//g;
    print "MySh::>$_";
    next if($_ eq ';');
    $_ =~ s/\|/; /g;
    $_ =~ s/\s(>)/ ; Writen /g;
    $_ =~ s/(\w+\s*)([\w.\s]*)(;|$)/$1 ($2)$3/g;
    $_ =~ s/\(([\w.]*)\s*([\w.]*)\s*\)/("$1", "$2")/g;
    $_ =~ s/print\s*/Printer /g;
    $_ =~ s/sort\s*/Sort /g;
    $_ =~ s/delete\s*/Delete /g;
    $_ =~ s/exit/Exit();/g;
    $_ =~ s/copy\s*/Copy /g;
    my @a = split(";");
    foreach(@a){
      my $res = Shell::DO($_);
       if($res == 0){
	print "0\n";
	  last;
       }
    }
      Shell::Viv;
  }
};

if($@){ 
  print "0\n";
  warn("$@\n");
}else{
 print "MySh::>\n";
 exit;
};
