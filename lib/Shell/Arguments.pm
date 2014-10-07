#======================================================================================================================
# Arguments
#
#   TODO
#
#======================================================================================================================
package Shell::Arguments ;

use strict;

use Getopt::Long qw ( 
    GetOptionsFromArray 
    GetOptionsFromString 
) ;

#======================================================================================================================
# §function     new
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       Command->new( $Shell, $Options )
#----------------------------------------------------------------------------------------------------------------------
# §description  Constructor
#----------------------------------------------------------------------------------------------------------------------
# §input        $hArgumentsMetaData |TODO | object
#----------------------------------------------------------------------------------------------------------------------
# §return       $Object | The new object instance | Object
#======================================================================================================================
sub new {
    my $Class = shift;

    my ( $hArgumentsMetaData ) = @_ ;
    
    my $hAttributes = {
        'ArgumentsMetaData' => $hArgumentsMetaData ,
        'Arguments' => {}
    } ;
    
    return bless( $hAttributes, $Class );
}

#======================================================================================================================
# §function     Arguments
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Arguments->getArguments()
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §return       $Arguments | TODO | hash.ref
#======================================================================================================================
sub getArguments {
    my $self = shift;

    return $self->{'Arguments'} ;
}

#======================================================================================================================
# §function     parseFromString
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Arguments->parseFromString( $InputString )
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $Arguments | TODO | string
#======================================================================================================================
sub parseFromString {
    my $self = shift;

    my ( $InputString ) = @_ ;

    my $hGetOptionsData = $self->_prepareGetOptionsData()  ;
    my $hArguments  = $hGetOptionsData->{'Arguments'} ;
    my $aGetOptList = $hGetOptionsData->{'GetOptList'} ;
    
    my ( $ret, $args ) =    GetOptionsFromString( 
                                $InputString, 
                                @$aGetOptList 
                            ) ;

    $hArguments->{'@'} = $args ;
    $self->{'Arguments'} = $hArguments ;
     
    return $hArguments ;
}

#======================================================================================================================
# §function     parseFromArray
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Arguments->parseFromArray( $aInputArray )
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $Arguments | TODO | string
#======================================================================================================================
sub parseFromArray {
    my $self = shift;

    my ( $aInputArray ) = @_ ;

    my $hGetOptionsData = $self->_prepareGetOptionsData()  ;
    my $hArguments  = $hGetOptionsData->{'Arguments'} ;
    my $aGetOptList = $hGetOptionsData->{'GetOptList'} ;
    
    GetOptionsFromArray(
        $aInputArray,
        @$aGetOptList 
    ) ;

    $hArguments->{'@'} = $aInputArray ;
    $self->{'Arguments'} = $hArguments ;

    return $hArguments ;
}

#======================================================================================================================
# §function     _prepareGetOptionsData
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Arguments->_prepareGetOptionsData()
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $Arguments | TODO | string
#======================================================================================================================
sub _prepareGetOptionsData {
    my $self = shift;

    my $hArguments = { '@' => [] }  ;
    my $GetOptsList = [] ;
    my $ArgumentsMetaData = $self->{'ArgumentsMetaData'} ;

    foreach my $ArgumentName ( keys %$ArgumentsMetaData ) {
        my $ArgumentItem = $ArgumentsMetaData->{$ArgumentName} ;
        $hArguments->{$ArgumentName} = $ArgumentItem->[1] ;
        push (
            @$GetOptsList , 
            $ArgumentItem->[0] => \$hArguments->{$ArgumentName} 
        );
    }

    return {
        'Arguments'     => $hArguments,
        'GetOptList'    => $GetOptsList
    }
}

1;
