package ePages::Attributes::String ;
use base ePages::Attributes::Base ;

use strict;

sub _get {
    my $self = shift;

    my ( $LanguageID ) = @_ ;

    my $Value = $self->{'Object'}->get( $self->getName(), $LanguageID ) ;
    if ( defined $Value and length( $Value ) > 100 ) {
        $Value = substr( $Value, 0, 100 ).' ...' ;
    }

    return $Value ;
}

1;
