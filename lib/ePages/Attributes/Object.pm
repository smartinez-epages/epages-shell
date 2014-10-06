package ePages::Attributes::Object ;
use base ePages::Attributes::Base ;


use strict;

sub _get {
    my $self = shift;
 
    my ( $LanguageID ) = @_ ;
 
    my $Alias = $self->getName() ;
    my $Value = $self->{'Object'}->get( $Alias, $LanguageID ) ;
    if ( defined $Value ) {
        $Value = $Value->alias.' [ID = '.$Value->id.']' ;
    }
 
    return $Value ;
}

1;
