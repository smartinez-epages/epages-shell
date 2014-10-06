package ePages::Attributes::Base ;
use base qw ( Exporter );

use strict;

sub new {
    my $class = shift;

    my ( $Object, $Attribute ) = @_;

    my $hAttributes = $Attribute->{'Attributes'};
    my $Type = $hAttributes->{'Type'};
    my $IsArray = $hAttributes->{'IsArray'};
    
    return 
        bless( 
            { 
                'Object'    => $Object, 
                'Attribute' => $Attribute,
                'Name'      => $Attribute->alias,
                'IsArray'   => $IsArray,
                'IsObject'  => $hAttributes->{'IsObject'},
                'ReadOnly'  => $hAttributes->{'IsReadOnly'},
                'Type'      => ( $IsArray )? $Type.'[]' : $Type,
            },  
            $class 
        ) ;
}

sub getName {
    my $self = shift;

    return $self->{'Name'};
}

sub getType {
    my $self = shift;
 
    return $self->{'Type'};
}

sub isArray {
    my $self = shift;
 
    return $self->{'IsArray'};
}

sub isObject {
    my $self = shift;
 
    return $self->{'IsObject'};
}

sub isReadOnly {
    my $self = shift;
 
    return $self->{'ReadOnly'};
}

sub getValueShort {
    my $self = shift;

    my ( $LanguageID ) = @_ ;
    
    if ( $self->{'IsArray'} ) {
        return '[...]' ;
    } 
    
    my $Value = $self->_get( $LanguageID ) ;
    
    return ( defined $Value )? $Value : '(null)';
}

sub _get {
    my $self = shift;
    
    my ( $LanguageID ) = @_ ;

    my $Alias = $self->getName() ;

    return $self->{'Object'}->get( $Alias, $LanguageID );
}

sub setValue {
    my $self = shift;

    my ( $Value, $LanguageID ) = @_ ;

    $self->_set( $Value, $LanguageID, ) ;
    
    return ;
}

sub _set {
    my $self = shift;

    my ( $Value, $LanguageID ) = @_ ;
    
    $self->{'Object'}->get({ $self->getName() => $Value }, $LanguageID );
}

sub getValueLong {
    my $self = shift;
    
    my $Flags = sprintf( 
        "%s%s",
        ($self->{'IsArray'})? 'IsArray' : '',
        ''
    ) ;
    
    return sprintf(
        "\n - %-30s %s\n - %-30s %s\n - %-30s %s\n - %-30s %s\n - %-30s %s",
        'Name', $self->getName(),
        'Type', $self->getType(),
        'Array', ( $self->isArray() )? 'Yes' : 'No',
        'Object', ( $self->isObject() )? 'Yes' : 'No',
        'ReadOnly', ( $self->isReadOnly() )? 'Yes' : 'No',
    )
}

1;
