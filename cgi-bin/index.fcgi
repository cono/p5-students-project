#! /usr/bin/perl

use strict;
use warnings;

use CGI::Fast;
use JSON;
use File::Spec;
use MIME::Lite;
use FindBin qw($Bin);

#use lib File::Spec->catdir($Bin, qw(.. lib));

my $_stop = 0;
my $request;
$SIG{'PIPE'} = 'IGNORE';

$SIG{'INT'} = $SIG{'TERM'} = sub {
    $_stop = 1;

    exit(0) unless defined($request);
};

unless ($ENV{'SERVER_SOFTWARE'}) { # for nginx external fcgi
    $CGI::Fast::Ext_Request = FCGI::Request(
        \*STDIN, \*STDOUT, \*STDERR,
        \%ENV, int($ARGV[0] || 0), 1
    );
}

sub USERDB() { 'user.db' }

my $root_dir = File::Spec->catdir($Bin, '..');
my $conf_dir = File::Spec->catdir($root_dir, 'conf');
my $data_dir = File::Spec->catdir($root_dir, 'data');

open(my $log, '>>', File::Spec->catfile($root_dir, qw|log error.log|)) or die "Can't open log file: $!";

my $json = JSON->new->utf8;
my %users;
my %handlers = (
    user_list    => \&_user_list,
    get_password => \&_get_password,
    upload       => \&_upload,
);

{
    my $filename = File::Spec->catfile($conf_dir, USERDB);
    my $line;
    open(my $fh, '<', $filename) or die "Can't open file $filename: $!";

    while (defined($line = <$fh>)) {
        chomp($line);
        my ($name, $email) = split(/\|/, $line);
        my ($first, $last) = map {ucfirst} split(/\./, $name);

        $users{$name} = {
            name         => $name,
            first_name   => $first,
            last_name    => $last,
            email        => $email,
            password     => '',
            new_password => ''
        };
    }
}

while (1) {
    eval {
        $request = CGI::Fast->new();
        unless ($request) {
            $_stop = 1;

            return;
        }

        my $uri = $request->url(-absolute => 1);
        my ($action) = $uri =~ m|^/([a-z_0-9]+)|;

        if ($action && exists $handlers{$action}) {
            my $result = $handlers{$action}->($request, $uri);

            print qq(Content-type:application/json;charset=utf-8\r\n\r\n);
            print $json->encode($result);
        } else {
            print qq(Status: 301\r\nLocation: /index.html\r\n\r\n);
        }
    };

    if ($@) {
        print qq(Content-type:application/json;charset=utf-8\r\n\r\n);
        print $log "${\(scalar localtime)} [error] $@";
        print $json->encode({ error => 'oops' });
    }

    $request = undef;
    last if $_stop;

    if (-M $0 < 0) {
        unless ($ENV{'SERVER_SOFTWARE'}) { # for nginx external fcgi
            system("$0 ". int($ARGV[0] || 0).' &');
        }
        last;
    }
}

sub _user_list {
    my ($r, $u) = @_;
    my @result;

    for my $k (sort keys %users) {
        push @result, {
            name       => $k,
            first_name => $users{$k}->{'first_name'},
            last_name  => $users{$k}->{'last_name'}
        };
    }

    return \@result;
}

sub _generate_random_string {
    my @arr = ('a' .. 'z', 'A' .. 'Z', 0 .. 9);

    return join('', map { $arr[rand @arr] } 1 .. 10 );
}

sub _get_password {
    my ($r, $u) = @_;

    my $p_user = $r->param('user');
    die "unknown user" unless exists($users{$p_user});

    $users{$p_user}->{'new_password'} = _generate_random_string;

    my $msg = MIME::Lite->new(
        From    => 'mail@tazik.org.ua',
        To      => $users{$p_user}->{'email'},
        Subject => 'Password recovery',
        Data    => <<"        EOT" =~ s/^        //mgr
        If you haven't asked for new password, just use your old one.
        Your new password is: $users{$p_user}->{'new_password'}

        -- 
        http://students.cono.org.ua/index.html
        EOT
    );
    $msg->send('smtp', '127.0.0.1', Timeout => 1);

    return {status => 'ok'};
}

sub _upload {
    my ($r, $u) = @_;

    my $p_user = $r->param('user');
    die "unknown user" unless exists($users{$p_user});

    my $password = $r->param('password') || 'wrong';
    if ($password eq $users{$p_user}->{'new_password'}) {
        $users{$p_user}->{'password'} = $users{$p_user}->{'new_password'};
    }
    if ($password ne $users{$p_user}->{'password'}) {
        return { error => 'wrong password' };
    }

    my $task = $r->param('task');
    die "wrong task" unless $task =~ /^0[0-9]$/;

    my $dir  = File::Spec->catdir($data_dir, $task);
    my $lock = File::Spec->catfile($dir, '.unlock');
    my $file = File::Spec->catfile($dir, "$p_user.pl");

    unless (-e $dir) {
        mkdir($dir);
        open(my $fh, '>', $lock) or die "Can't open lock file: $!";
    }

    if (-e $file && !(-e $lock)) {
        return { error => 'file already loaded' };
    }

    open(my $fh_write, '>', $file) or die "Can't open file: $!";
    my $fh_script = $r->upload('script');
    while (defined(my $line = <$fh_script>)) {
        $line =~ s/\r\n$/\n/;
        print $fh_write $line;
    }

    return { status => "ok" };
}

exit(0);
