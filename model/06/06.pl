#!/usr/bin/perl 

use strict;
use warnings;

use DBI;

sub new {
    my $class = shift;
    my %param = @_;

    return bless(\%param, $class);
}

sub _open {
    my $self = shift;

    open($self->{'_fh'}, '<', $self->{'file'}) or die "Can't open file: $!";
}

sub _read_header {
    my $self = shift;
    my $fh   = $self->{'_fh'};

    for my $field ( qw|host port dbname user pass| ) {
        $self->{$field} = readline($fh);
        die "Can't read from file ($.): $!" unless defined $self->{$field};
        chomp($self->{$field});
    }
}

sub _connect {
    my $self = shift;

    my $dsn = "DBI:mysql:database=$self->{'dbname'};host=$self->{'host'};port=$self->{'port'}";
    $self->{'_dbh'} = DBI->connect($dsn, $self->{'user'}, $self->{'pass'},
        {
            RaiseError => 1,
            PrintError => 0
        }
    );
}

sub execute {
    my $self = shift;

    $self->_open;
    $self->_read_header;

    $self->_connect;

    while (my $chunk = $self->_read_sql) {
        $self->_exec_sql($chunk);
    }
}

sub _read_sql {
    my $self = shift;
    my $fh   = $self->{'_fh'};

    my $sql = {};
    my $key = 'wait';
    my %state_machine = (
        wait => sub {},
        sql  => sub {
            $sql->{'query'} .= "$_[0]\n";
        },
        param => sub {
            $sql->{'param'} = [] unless exists $sql->{'param'};

            push @{$sql->{'param'}}, [ split(/,/, $_[0]) ];
        },
        end => sub {
            chomp($sql->{'query'});
        }
    );

    while (!eof($fh) && $key ne 'end') {
        my $line = readline($fh);
        die "Can't read line (#$.): $!" unless defined $line;
        chomp($line);

        if ($line =~ /^--\s*(\w*)/) {
            next unless exists $state_machine{$1};

            $key = $1;
        } else {
            $state_machine{$key}->($line);
        }
    }

    if ($key eq 'wait') {
        # eof
        $key = 'end';
    }
    die "Not proper end of SQL chunk. Looks like corrupted file" if $key ne 'end';
    return $sql->{'query'} ? $sql : 0;
}

sub _exec_sql {
    my ($self, $data) = @_;
    my $dbh = $self->{'_dbh'};
    my $sth;
    local $" = '|';

    if (exists $data->{'param'}) {
        $sth = $dbh->prepare($data->{'query'});

        for my $p ( @{$data->{'param'}} ) {
            $sth->execute(@$p);

            if ($data->{'query'} =~ /^\s*select/) {
                while (my @row = $sth->fetchrow_array) {
                    print "@row\n";
                }
            }
        }

        $sth->finish;
    } else {
        if ($data->{'query'} =~ /^\s*select/i) {
            $sth = $dbh->prepare($data->{'query'});
            $sth->execute;

            while (my @row = $sth->fetchrow_array) {
                print "@row\n";
            }

            $sth->finish;
        } else {
            $dbh->do($data->{'query'});
        }
    }
}

sub _log_error {
    my ($self, $err_msg) = @_;

    print STDERR $err_msg;
    print "0\n";
}

sub DESTROY {
    my $self = shift;

    $self->{'_dbh'}->disconnect if $self->{'_dbh'};
}

my $test = main->new(
    file => shift
);

eval {
    $test->execute();
};

if ($@) {
    $test->_log_error($@);
}
