#! /usr/bin/perl -w
use strict;

my $test_file_path = $ARGV[0];
open( FH, "<", "$test_file_path") or die "Can not open test file: $!";
my $lines;

if ( -z "$test_file_path" ) {
   print STDOUT "0\n";
   print STDERR "File is empty\n";
   exit(1);
}

my %hash = ();
my @main_str;
while (my $str = <FH> ) {
    
    $str =~ s/#.*//; 
    next if $str =~ /^(\s)*$/;    
     
    
        
    if ($str =~ m/\s*\"[\d\w]+\"\s*\=\>?\s*\"[\w\d]+\"\s*/) {
        chomp($str);
        $str =~ s/^\s*//g;
        $str =~ s/\s*$//g;
        
        $str =~ s/\=\>/\=/g;
        
        $str =~ s/\"//g;
        $str =~ s/\s*\=\s*/\=/;
        
        $str =~ s/\s*\=\s*/\=/g;                
        %hash = (%hash,split(/=/,$str));
        
    }
    elsif ($str =~ m/\s*\'[\d\w]+\'\s*\=\>?\s*\'[\w\d]+\'\s*/) {
        chomp($str);
        $str =~ s/^\s*//g;
        $str =~ s/\s*$//g;
    
        $str =~ s/\=\>/\=/g;
        $str =~ s/\'//g;
        
        $str =~ s/\s*\=\s*/\=/g;
        %hash = (%hash,split(/=/,$str));
    }
    elsif ($str =~ m/\s*[\d\w]+\s*\=\>?\s*[\w\d]+\s*/) {
        chomp($str);
        $str =~ s/^\s*//g;
        $str =~ s/\s*$//g;
        
        $str =~ s/\=\>/\=/g;
        $str =~ s/\s*\=\s*/\=/g;
        %hash = (%hash,split(/=/,$str));
    }
    elsif ($str =~ m/\s*[\d\w]+\s*\=\>?\s*\"[\w\d]+\"\s*/) {
        chomp($str);
        #print STDOUT "$str\n";
        $str =~ s/^\s*//g;
        $str =~ s/\s*$//g;
        
        $str =~ s/\=\>/\=/g;
        
        
        $str =~ s/\"//g;
        $str =~ s/\s*\=\s*/\=/g;
        %hash = (%hash,split(/=/,$_));
    }
    elsif ($str =~ /^[\d\w]+\s*$/) {
        chomp($str);
       push(@main_str,$str);
    }
    else {
        print STDOUT "0\n";
        exit(1);
    } 
}

my $stroka = "";
$stroka = $main_str[0];
foreach my $key(sort {$b cmp $a} keys %hash) {
    #print "$key\n";
   
    
    if ($stroka =~ m/\*|\w|\d$key\w|\d|\*/g) {
        
        #if ($& !~ m/\*$key\*/gc) {
            my $future = "*".join("*",split(//,$hash{$key}))."*";
            #print "$future\n";
            $stroka =~ s/$key/$future/g;      
        #}
    }
    #print "$stroka\n";
}


#foreach my $key(sort {$b cmp $a} keys %hash) {
#    print "$key\n";
#       
#        #print "before: $`\n";
#        #print "after: $'\n";
#        #while (not $stroka =~ m/\'$key\'/) {
#        #    my $future = "'".join("'",split(//,$hash{$key}))."'";
#        #    $stroka =~ s/$key/$future/;
#        #}
#        
#        #if ($' =~ m/^\-/ && $` =~ m/\-$/) {
#        #    ;
#        #}
#        #else {
#        #    my $future = "-".join("-",split(//,$hash{$key}))."-";
#        #    $stroka =~ s/$key/$future/g;
#        #}
#        #if ($' =~ m/^\*/g && $` =~ m/[\w\d]$/g) {
#        #    my $future = "*".join("*",split(//,$hash{$key}))."*";
#        #    $stroka =~ s/$key/$future/g;
#        #}
#        #if ($' =~ m/^[\w\d]/g && $` =~ m/\*$/g) {
#        #    my $future = "*".join("*",split(//,$hash{$key}))."*";
#        #    $stroka =~ s/$key/$future/g;
#        #}   
#    
#    print "$stroka\n";
#}


#print "\n";
$stroka =~ s/\*//g;
print $stroka;



#foreach my $key(sort {$b cmp $a} keys %hash) {
#    print STDOUT "$key -> $hash{$key}\n";
#}


close ( FH );




#my %hash = ( 15 => 'hhhap', # not found
#             zaza => 'at',
#             kkk => 'aa',
#             bb => 'b',
#             b => 'ERROR',
#             aa => 'S',          
#           );

#my $string = "bgkgzazazakkkbbaa"; # gkgKATzaAABSS
#


