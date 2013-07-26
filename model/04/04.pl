#!/usr/bin/perl 

use strict;
use warnings;
package ACA;

sub new {
    my $class = shift;
    my %param = @_;

    return bless(\%param, $class);
}

sub _open {
    my $self = shift;
    if ($self->{'file'}){
        open($self->{'_fh'}, '<', $self->{'file'}) or die "Cannot open file: $!\n";
    }
    else {
        die "No filename given\n";
    }
}

sub _read_file {
    my $self = shift;
    my $fh = $self->{'_fh'};

    chomp($self->{'str'} = <$fh>);
	die "Error reading string" if !$self->{'str'} || $self->{'str'} =~ /[=>]/;
    my %replaces;
    while (defined (my $tmp = <$fh>)){
        chomp($tmp);
        next if $tmp =~ /^#/ || !$tmp;
        my @val = map {
            s/^\s+//;
            s/\s+$//;
            s/^(["'])(\w+)\1$/$2/;
            $_
        } split (/(?:=>|=)/, $tmp);

        if (grep { /["']/ } @val) {
            die "Quote symbol found";
        }
        die "No key or value" unless $val[0] && $val[1];

        $replaces{$val[0]} = $val[1];
    }
    $self->{'replaces'} = \%replaces;

}

sub _process {
    my $self = shift;
    
    $self->_open;
    $self->_read_file;
    my $replaces = $self->{'replaces'};
    my $string = $self->{'str'};
    my $re = join("|", sort {$b cmp $a} keys %$replaces);
    $re = qr/$re/;
    $string =~ s/($re)/$replaces->{$1}/g;
    $self->{'str_replaced'} = $string;
    print $self->{'str_replaced'}."\n";

}

sub _log_error {
    my ($self, $err) = @_;

    print STDERR $err;
    print "0\n";
}

sub DESTROY {
    my $self = shift;
    close $self->{'_fh'} if $self->{'_fh'};
}

package main;
my $test = ACA->new(
    file => shift
);

eval {
    $test->_process();
};

if ($@) {
    $test->_log_error($@);
}
