#!/usr/bin/perl -w
use strict;

# online calculator:
# http://numsys.ru/

use constant PALETTE_CONVERSION => [ qw(
    0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
) ];
use constant MAX_NUMERAL_SYSTEM => scalar( @{+PALETTE_CONVERSION} );

main();


sub is_valid_input_number {
    my %args = (
        'base' => 35,
        'number' => 330,
        @_,
    );

    return 0 unless ( $args{'number'} =~ m/^[A-Za-z\d]+$/ );
    return 0 unless ( defined $args{'base'} && $args{'base'} =~ /^\d+$/
        && $args{'base'} > 1 && $args{'base'} < 37 );

    grep{
        my $char = uc($_);
        grep
        {
          ( PALETTE_CONVERSION->[$_] eq $char && $_ >= $args{'base'} ) ? return 0 : ()
        } 0..$#{+PALETTE_CONVERSION};

    } split( //, $args{'number'} );
    return 1;
}

sub is_valid_input_base {
    my %args = (
        'base' => 0,
        @_,
    );

    $args{'base'} =~ m/^(\d+)$/;

    ( $1 && $1 > 1 && $1 <= MAX_NUMERAL_SYSTEM ) ?
        return 1
        : return 0;

}

sub count_positions {
    my $base = shift;
    my $e = shift;
    my $digits = 1;

    for ( ; $e > 0; $e-- ) {
        $digits *= $base;
    }
    return $digits;
}


sub dec2basen {
    my %args = (
        'base' => 2,
        'number' => 0,
        @_,
    );
    my $dec = $args{'number'};
    my $base =  $args{'base'};
    my ( $result, $description ) = ( '', 'OK');

    return ( 'Error', 'Wrong input parameters' )
        unless ( is_valid_input_number( base => 10,  number => $dec ) );
    return ( 'Error', 'Unsupported numeral system' )
        unless ( is_valid_input_base( base => $base ) );
    return ( 0, 'OK' ) if ( $dec eq 0 );

    my $positions = 0;

    for ( ; ( count_positions( $base, ++$positions ) <= $dec ) ; ) { }

    for ( my $j = 1; $j <= $positions; $j++ ) {
        my $char_index = int( $dec / count_positions( $base, $positions - $j ) );
        $result .= PALETTE_CONVERSION->[ $char_index ];
        $dec %= count_positions( $base, $positions - $j );
    }

    return ( $result, $description );
}


sub basen2dec {
    my %args = (
        'base' => 2,
        'number' => 0,
        @_,
    );
    my $num = $args{'number'};
    my $base =  $args{'base'};
    my ( $result, $description ) = ( 0, 'OK');

    return ( 'Error', 'Wrong input parameters' )
        unless ( is_valid_input_number( %args ) );
    return ( 'Error', 'Unsupported numeral system' )
        unless ( is_valid_input_base(  base => $base ) );
    return ( 0, 'OK' ) if ( $num eq 0 );

    for ( my $i = 0; $i < length( $num ); $i++ ) {
        $result += get_arr_index( substr( $num, $i, 1 ) ) * count_positions( $base, length( $num ) - $i - 1 );
    }

    return ( $result, $description );
}

sub get_arr_index {
    my $char = shift;
    grep { PALETTE_CONVERSION->[$_] eq uc( $char ) ? return $_ : '' } 0..$#{+PALETTE_CONVERSION};
}

sub bidirectional_numeral_system_converter {
    my %args = (
        'direction' => 1,
        'base' => 2,
        'number' => 0,
        @_,
    );

    return
        $args{ 'direction' } == 1 ? dec2basen( %args )
            : $args{ 'direction' } == 2 ? basen2dec( %args )
                : ( 'Error', 'Unsupported direction' );
}


sub main {

    my $file_path = $ARGV[0];

    open( FH, "<", "$file_path") or die "Can not open test file: $!";

    while ( <FH> ) {

        unless ( $_ =~ m/^\s*([a-z0-9]+)\s*,\s*([a-z0-9]+)\s*,\s*([a-z0-9]+)\s*$/i ) {
            $_ =~ s/\n*$/\n/;
            print STDOUT 'Error' . "\n"; print STDERR "Wrong input parameters for string: $_";
            next;
        }
        # $1 - direction ('1' - from decimal to any, '2' - from any to decimal)
        # $2 - number
        # $3 - base

        my ( $res, $desc ) = bidirectional_numeral_system_converter(
            direction => $1,
            number => $2,
            base => $3,
        );

        print STDOUT "$res\n";
        print STDERR "$desc\n" if ( $res eq 'Error' );
    }
    close ( FH );

    return 1;
}

