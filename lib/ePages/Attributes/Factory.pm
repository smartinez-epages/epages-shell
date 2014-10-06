package ePages::Attributes::Factory ;
use base qw ( Exporter );

use strict;

use Readonly;
use File::Basename;
 
our @EXPORT_OK = qw (
    NewObjectAttribute
) ;

Readonly my $MODULEPATH  => 'ePages::Attributes::' ;
Readonly my $TYPES_MAPPING  => {
    'Integer'           => 'Base',
    'Boolean'           => 'Base',
    'String'            => 'String',
    'LocalizedString'   => 'LocalizedString',
    'Hash'              => 'Hash',
    'Object'            => 'Object',
    'Date'              => 'DateTime',
    'DateTime'          => 'DateTime',
} ;

sub NewObjectAttribute {
    my ( $Object, $Attribute ) = @_ ;

    my $hAttributes = $Attribute->{'Attributes'} ;
    my $Type = $hAttributes->{'Type'} ;
    my $ModuleName = $TYPES_MAPPING->{$Type} ;
    
    if ( not defined $ModuleName ) {
        if ( $hAttributes->{'IsObject'} ) {
            $ModuleName = 'Object' ;
        } else {
            $ModuleName = 'Unknown' ;
        }
    }
    
    my $ModulePath = dirname( __FILE__ )."/$ModuleName.pm" ;
    require $ModulePath ;

    my $Module = $MODULEPATH.$ModuleName ;

    return $Module->new( $Object, $Attribute );
}

1;
