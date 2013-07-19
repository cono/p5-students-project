#!/bin/env perl

use strict;
use warnings;

use constant CMD_SEPARATOR => qr/\s+\|/;
use constant ALLOWED_CMD => qr/^\s*(copy|move|delete|print|sort|search)(\s+.*)*$/;
use constant EXIT_CMD => qr/^\s*(exit|quit)\s*$/;
use constant {
    RESULT_FAIL => 0,
    RESULT_OK => 1,
    RESULT_OK_QUIET => 2,
};

my $IS_INTERACTIVE_MODE = !defined(@ARGV) ? 1 : 0;
my @BUFFER = ();

my %cmd_map = (
    'copy'  => { 
        'cmd' => \&CmdProcessor::copy,
        'mand_args_cnt' => 2,
        'args_cnt' => 2,
    },
    'move'  => {
        'cmd' => \&CmdProcessor::move,
        'mand_args_cnt' => 2,
        'args_cnt' => 2,
    },
    'delete'=> {
        'cmd' => \&CmdProcessor::delete,
        'mand_args_cnt' => 1,
        'args_cnt' => 1,
    },
    'print' => {
        'cmd' => \&CmdProcessor::print,
        'mand_args_cnt' => 1,
        'args_cnt' => 1,
    },
    'sort'  => {
        'cmd' => \&CmdProcessor::sort,
        'mand_args_cnt' => 0,
        'args_cnt' => 1,
    },
    'search'=> {
        'cmd' => \&CmdProcessor::search,
        'mand_args_cnt' => 1,
        'args_cnt' => 2,
    },
);

print "MySh::>";
while (<>) {
    chomp;
    if ( !$IS_INTERACTIVE_MODE && defined($_) ) {
        print "$_\n";
    }

    @BUFFER = ();
    if ($_ =~ EXIT_CMD) {
        last;
    }
    my @cmd_list = split(CMD_SEPARATOR, $_);
    my $is_piped = 0;
    my $res = 0;

    foreach my $cmd (@cmd_list) {
        if ($cmd =~ ALLOWED_CMD) {
            $res = _dispatch({
                'cmd'  => $1,
                'args' => $2,
                'is_piped' => $is_piped });
        } else {
            print_err("Command '$cmd' not found!");
            $res  = 0;
            last;
        }
            $is_piped = 1;
            last if !$res;
    }

    if ($res == RESULT_OK) {
        foreach (@BUFFER) {
            print($_);
        }
    } 
    print "MySh::>";
};

sub print_err {
    my $err = shift;
    $err =~ s/\n*$//;
    $err .= "\n";
    if ( $IS_INTERACTIVE_MODE ) {
        print $err;
    } else {
        print STDOUT "0\n";
        print STDERR $err;
    }
}

sub _dispatch {
    my ($info) = @_;
    my @args_arry = ();
    if ($info->{args} && $info->{args} =~ /[^\s]+/) {
        $info->{args} =~ s/^\s+//;
        $info->{args} =~ s/\s+$//;
        ($info->{args}, $info->{redirect}) = split(/\s*>\s*/, $info->{args});
        
        if ($cmd_map{$info->{cmd}}->{args_cnt} > 1) {
            @args_arry = split(/\s+/, $info->{args});
        } elsif ($cmd_map{$info->{cmd}}->{args_cnt}) {
            push(@args_arry, $info->{args});
        }
    }

    #Validate input
    if ( $info->{is_piped} ) {
        if ( scalar(@args_arry) < $cmd_map{$info->{cmd}}->{mand_args_cnt} ) {
            print_err("Invalid arguments for command '$info->{cmd}' args '@args_arry'");
            $CmdProcessor::IS_READ_FROM_PREV = 0;
            return RESULT_OK;
        }
        elsif ( scalar(@args_arry) == $cmd_map{$info->{cmd}}->{mand_args_cnt} ) {
            $CmdProcessor::IS_READ_FROM_PREV = 1;
        }
        elsif ( scalar(@args_arry) == $cmd_map{$info->{cmd}}->{args_cnt} ) {
            $CmdProcessor::IS_READ_FROM_PREV = 0;
            @BUFFER = ();
        }
        else {
            print_err("Invalid command processing");
            $CmdProcessor::IS_READ_FROM_PREV = 0;
            return RESULT_OK;
        }
    }
    elsif ( scalar(@args_arry) != $cmd_map{$info->{cmd}}->{args_cnt} ) {
        print_err("Invalid arguments for command '$info->{cmd}' args '@args_arry'");
        $CmdProcessor::IS_READ_FROM_PREV = 0;
        return RESULT_OK;
    }

    my $res = $cmd_map{$info->{cmd}}->{cmd}->(@args_arry);
    
    if ($info->{redirect} && $info->{redirect} ne "") {
        $info->{redirect} =~ s/\s+//g;
        open(my $wfh, '>', $info->{redirect}) or (print_err($!) && return RESULT_FAIL);
        print $wfh @BUFFER;
        close($wfh);
        @BUFFER = ();
        return RESULT_OK_QUIET;
    }

    return $res;
}

package CmdProcessor;

our $IS_READ_FROM_PREV = 0;

sub move_copy {
    $IS_READ_FROM_PREV = 0;
    @BUFFER = ();
    my ($action, $file_from, $file_to) = @_;
    require File::Copy;
    eval "File::Copy::$action('$file_from', '$file_to') or die;";
    if ($@) {
        main::print_err($!);
        return main::RESULT_FAIL;
    } else {
        @BUFFER = ();
    }
    return main::RESULT_OK_QUIET;
}

sub copy {
    return move_copy('copy', @_);
}

sub move {
    return move_copy('move', @_);
}

sub delete {
    $IS_READ_FROM_PREV = 0;
    unlink(shift) or (main::print_err($!) && return main::RESULT_FAIL);
    @BUFFER = ();
    return main::RESULT_OK_QUIET;
}

sub print {
    $IS_READ_FROM_PREV = 0;
    @BUFFER = ();
    my $file_name = shift;
    open(my $fh, '<', $file_name) or (main::print_err($!) && return main::RESULT_FAIL);
    while(<$fh>) {
        push(@BUFFER, $_);
    }
    close($fh);
    return main::RESULT_OK;
}

sub sort {
    my ($file_name) = @_;
    my ($fh);
    if ($IS_READ_FROM_PREV) {
        $IS_READ_FROM_PREV = 0;
        @BUFFER = CORE::sort @BUFFER;
    } else {
        open($fh, '<', $file_name) or (main::print_err($!) && return main::RESULT_FAIL);
        @BUFFER = CORE::sort(<$fh>);
        close($fh);
    }
    return main::RESULT_OK;
}

sub search {
    my ($line_to_search, $file_name) = @_;
    my $pattern = qr/$line_to_search/;
    my ($fh, @content);
    if ($IS_READ_FROM_PREV) {
        $IS_READ_FROM_PREV = 0;
        foreach (@BUFFER) {
            if ($_ =~ $pattern) {
                push(@content, $_);
            }
        }
    } else {
        open(my $fh, "<", $file_name) or (main::print_err($!) && return main::RESULT_FAIL);
        while (<$fh>) {
            if ($_ =~ $pattern) {
                push(@content, $_);
            }
        }
        close($fh);
    }
    @BUFFER = @content;
    return main::RESULT_OK;
}

1;
