#!/software/perl/5.8.4/bin/perl

use strict;
use warnings;

use constant CANT_OPEN_FILE_ERR => "Cant open file\n";
use constant COMMAND_FAILED_ERR => "Command failed\n";
use constant CMD_SEPARATOR => qr/\s+\|/;
use constant ALLOWED_CMD => qr/^\s*(copy|move|delete|print|sort|search)(\s+.*)*$/;
use constant EXIT_CMD => qr/^\s*(exit|quit)\s*$/;

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
            $cmd =~ s/\s//g;
            print("Command '$cmd' not found!");
            $res  = 0;
            last;
        }
            $is_piped = 1;
            last if !$res;
    }

    if ($res) {
        foreach (@BUFFER) {
            print($_);
        }
    }
    print "MySh::>";
};

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
            print("Invalid arguments for command '$info->{cmd}' args '@args_arry'");
            $CmdProcessor::IS_READ_FROM_PREV = 0;
            return 0;
        }
        elsif ( scalar(@args_arry) == $cmd_map{$info->{cmd}}->{mand_args_cnt} ) {
            $CmdProcessor::IS_READ_FROM_PREV = 1;
        }
        elsif ( scalar(@args_arry) == $cmd_map{$info->{cmd}}->{args_cnt} ) {
            $CmdProcessor::IS_READ_FROM_PREV = 0;
            @BUFFER = ();
        }
        else {
            print("Invalid command processing");
            $CmdProcessor::IS_READ_FROM_PREV = 0;
            return 0;
        }
    }
    elsif ( scalar(@args_arry) != $cmd_map{$info->{cmd}}->{args_cnt} ) {
        print("Invalid arguments for command '$info->{cmd}' args '@args_arry'");
        $CmdProcessor::IS_READ_FROM_PREV = 0;
        return 0;
    }

    my $res = $cmd_map{$info->{cmd}}->{cmd}->(@args_arry);
    
    if ($info->{redirect} && $info->{redirect} ne "") {
        $info->{redirect} =~ s/\s+//g;
        open(my $wfh, '>', $info->{redirect}) or (print(CANT_OPEN_FILE_ERR) && return 0);
        print $wfh @BUFFER;
        close($wfh);
        @BUFFER = ();
        return 1;
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
        CORE::print(main::COMMAND_FAILED_ERR);
    } else {
        @BUFFER = ();
    }
}

sub copy {
    move_copy('copy', @_);
    return 1;
}

sub move {
    move_copy('move', @_);
    return 1;
}

sub delete {
    $IS_READ_FROM_PREV = 0;
    unlink(shift) or (CORE::print(main::COMMAND_FAILED_ERR) && return 0);
    @BUFFER = ();
    return 1;
}

sub print {
    $IS_READ_FROM_PREV = 0;
    @BUFFER = ();
    my $file_name = shift;
    open(my $fh, '<', $file_name) or (CORE::print(main::CANT_OPEN_FILE_ERR) && return 0);
    while(<$fh>) {
        push(@BUFFER, $_);
    }
    close($fh);
    return 1;
}

sub sort {
    my ($file_name) = @_;
    my ($fh);
    if ($IS_READ_FROM_PREV) {
        $IS_READ_FROM_PREV = 0;
        @BUFFER = CORE::sort @BUFFER;
    } else {
        open($fh, '<', $file_name) or (CORE::print(main::CANT_OPEN_FILE_ERR) && return 0);
        @BUFFER = CORE::sort(<$fh>);
        close($fh);
    }
    return 1;
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
        open(my $fh, "<", $file_name) or (CORE::print(main::CANT_OPEN_FILE_ERR) && return 0);
        while (<$fh>) {
            if ($_ =~ $pattern) {
                push(@content, $_);
            }
        }
        close($fh);
    }
    @BUFFER = @content;
    return 1;
}

