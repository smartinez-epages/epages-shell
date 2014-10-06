package ePages::Attributes::DateTime ;
use base ePages::Attributes::Base ;

use strict;

use DE_EPAGES::Core::API::Object::DateTimeFormatter;

my $DateFormats = {
    'Date'      => '%d/%m/%Y',
    'DateTime'  => '%d/%m/%Y %H:%M:%S'
} ;

sub _get {
    my $self = shift;

    my ( $LanguageID ) = @_ ;

    my $Formatter = DE_EPAGES::Core::API::Object::DateTimeFormatter->new();

    my $Value = $self->{'Object'}->get( $self->getName() ) ;
    if ( defined $Value ) {
        $Value = 
            $Formatter->format_datetime( 
                $Value, 
                'date', 
                $DateFormats->{$self->getType()}
            );
    }
    
    return $Value ;
}

1;
