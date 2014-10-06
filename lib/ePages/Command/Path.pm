#======================================================================================================================
# Path
#======================================================================================================================
package ePages::Command::Path ;
use base Shell::Command ;

use strict ;

use DE_EPAGES::Object::API::Factory qw ( 
    ExistsObjectByPath 
    LoadObjectByPath 
    ExistsObject 
    LoadObject 
);

#======================================================================================================================
# §function     getName
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $CommandName = $Command->getName() ;
#----------------------------------------------------------------------------------------------------------------------
# §description  Returns the name of the command
#----------------------------------------------------------------------------------------------------------------------
# §return       $Name | the command name | string
#======================================================================================================================
sub getName {
    my $self = shift;

    return 'path' ;
}

#======================================================================================================================
# §function     getAlias
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $CommandAlias = $Command->getAlias() ;
#----------------------------------------------------------------------------------------------------------------------
# §description  Returns an array with all the alias for this command
#----------------------------------------------------------------------------------------------------------------------
# §return       $AliasList | All the alias for this command | array.ref
#======================================================================================================================
sub getAlias {
    my $self = shift;

    return [ 'cd' ] ;
}

#======================================================================================================================
# §function     getDescription
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $aDescription = $Command->getDescription() ;
#----------------------------------------------------------------------------------------------------------------------
# §description  Returns a list of text lines with the short description for the command.
#----------------------------------------------------------------------------------------------------------------------
# §return       $aDescription | Description for the command | array.ref
#======================================================================================================================
sub getDescription {
    my $self = shift;

    return [ 'Show the current status (store, object, ...)' ] ;
}

#======================================================================================================================
# §function     getHelp
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Help = $Command->getHelp()
#----------------------------------------------------------------------------------------------------------------------
# §description  Returns the detailed help of the command
#----------------------------------------------------------------------------------------------------------------------
# §return       $Help | The detailed command help | string
#======================================================================================================================
sub getHelp {
    my $self = shift;

    my $CmdName = $self->getName() ;
 
    return <<HELP_TEXT
Description:
    Change/Show the current object

Usage: 
    $CmdName [ ObjectPath | ObjectID ]

Arguments:
    ObjectPath          A valid path to an object in the current Store.
                        The path could be absolute (starting with /) like /Shops/DemoShop
                        or relative to the current object, like Customers/1000
                        The last element in the path could be a child or a valid object attribute. 

    ObjectID            A valid Object ID, like 10234
    
                        Without arguments you will get basic info about the current object ( Store, ID, Path ).

Examples:
                        $CmdName
                        $CmdName /
                        $CmdName /Shops/DemoShop
                        $CmdName Customers
                        $CmdName 1000/BillingAddress
                        $CmdName /Shops/DemoShop/Customers/1000/BillingAddress
HELP_TEXT

}

#======================================================================================================================
# §function     run
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Command->run( $hArguments ) 
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $hArguments | Arguments provided in the shell for this command | hash.ref
#======================================================================================================================
sub run {
    my $self = shift;

    my ( $hArguments ) = @_ ;

    my $Shell = $self->{'Shell'} ;
    my $Console = $Shell->getConsole() ;
    my $ePages = $Shell->{'ePages'} ;

    $Console->debug( "Run Command PATH\n" ) ;

    if ( not $ePages->isStoreActive() ) {
        $Console->output( "\n  Sorry. No Store selected !!!\n" ) ;
        return ;
    }
    
    my $aArgs = $hArguments->{'@'} ;
    my $CountArgs = scalar @$aArgs ;

    if ( $CountArgs < 2 ) {
        
        my $PathInfo = {
            'CurrentObject' => $ePages->getObject(),
            'TargetObject'  => undef,
            'Path'          => undef,
            'ObjectPath'    => undef,
            'ErrorMessage'  => 'No object selected'
        } ;
    
        if ( $CountArgs == 1 ) {
            $PathInfo->{'Path'} = $aArgs->[0] ;
            $self->_lookupObject( $PathInfo ) ;
        } else {
            $PathInfo->{'TargetObject'} = $PathInfo->{'CurrentObject'} ;
        }
        
        $self->_setTargetObject( $PathInfo ) ;
        
    } else {
        $Console->output( "\n  Too much arguments !\n" ) ;
    }

    return;
}

#======================================================================================================================
# §function     _lookupObject
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Command->_lookupObject( $PathInfo ) 
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $PathInfo | TODO | hash.ref
#======================================================================================================================
sub _lookupObject() {
    my $self = shift;

    my ( $PathInfo ) = @_ ;

    $self->_renderObjectPath( $PathInfo ) ;
    if ( not $self->_lookupByObjectPath( $PathInfo ) ) {
        if ( not $self->_lookupByObjectID( $PathInfo ) ) {
            if ( not $self->_lookupByObjectAttribute( $PathInfo ) ) {
                $PathInfo->{'ErrorMessage'} = 'Object not found' ;
            }
        }
    }

    return ;
}

#======================================================================================================================
# §function     _renderObjectPath
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Command->_renderObjectPath( $PathInfo ) 
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $PathInfo | TODO | hash.ref
#======================================================================================================================
sub _renderObjectPath() {
    my $self = shift;

    my ( $PathInfo ) = @_ ;
        
    my $Path = $PathInfo->{'Path'} ;
    if ( substr( $Path, 0, 1 ) ne '/' ) {
        my $CurrentObject = $PathInfo->{'CurrentObject'} ;
        if ( defined $CurrentObject ) {
            if ( $CurrentObject->id != 1 ) {
                $PathInfo->{'ObjectPath'} = $CurrentObject->get('Path')."/$Path" ;
                return ;
            }
        }
        $Path = "/$Path" ;
    }
    $PathInfo->{'ObjectPath'} = "$Path" ;
    
    return ;
}

#======================================================================================================================
# §function     _lookupByObjectPath
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Command->_lookupByObjectPath( $PathInfo ) 
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $PathInfo | TODO | hash.ref
#======================================================================================================================
sub _lookupByObjectPath() {
    my $self = shift;

    my ( $PathInfo ) = @_ ;

    my $ObjectPath = $PathInfo->{'ObjectPath'} ;
    
    $PathInfo->{'TargetObject'} = ( ExistsObjectByPath( $ObjectPath ) )? LoadObjectByPath( $ObjectPath ) : undef ;
     
    return defined $PathInfo->{'TargetObject'} ;
}

#======================================================================================================================
# §function     _lookupByObjectID
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Command->_lookupByObjectID( $PathInfo ) 
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $PathInfo | TODO | hash.ref
#======================================================================================================================
sub _lookupByObjectID() {
    my $self = shift;

    my ( $PathInfo ) = @_ ;

    my $ObjectID = $PathInfo->{'Path'} ;
    if ( $ObjectID =~ m/^\d*$/ and ExistsObject( $ObjectID ) ) {
        $PathInfo->{'TargetObject'} = LoadObject( $ObjectID ) ;
    }

    return  defined $PathInfo->{'TargetObject'} ;
}

#======================================================================================================================
# §function     _lookupByObjectAttribute
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Command->_lookupByObjectAttribute( $PathInfo ) 
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $PathInfo | TODO | hash.ref
#======================================================================================================================
sub _lookupByObjectAttribute() {
    my $self = shift;

    my ( $PathInfo ) = @_ ;

    my $Path = $PathInfo->{'ObjectPath'} ;

    if ( $Path =~ /(.*)\/(.*)/ ) {
        my $ObjectPath = $1 ;
        my $AttributeName = $2 ;
        if ( ExistsObjectByPath( $ObjectPath ) ) {
            my $Object = LoadObjectByPath( $ObjectPath ) ;
            if ( $Object->class->existsAttribute( $AttributeName ) ) {
                $PathInfo->{'TargetObject'} = $Object->get( $AttributeName ) ;
            }
        }
    }

    return defined $PathInfo->{'TargetObject'} ;
}

#======================================================================================================================
# §function     _setTargetObject
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Command->_setTargetObject( $PathInfo ) 
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $PathInfo | TODO | hash.ref
#======================================================================================================================
sub _setTargetObject() {
    my $self = shift;

    my ( $PathInfo ) = @_ ;

    my $Shell = $self->{'Shell'} ;
    my $Console = $Shell->getConsole() ;
    my $ePages = $Shell->{'ePages'} ;

    my $TargetObject = $PathInfo->{'TargetObject'} ;
    if ( defined $TargetObject ) {
        $ePages->setObject( $TargetObject ) ;
        $Console->output(
            "\n  You are now in:\n\n\tStore        %s\n\tObjectID     %s\n\tObjectPath   %s\n",
            $ePages->getStore(),
            $TargetObject->id,
            $TargetObject->get('Path')
        ) ;
    } else {
        $Console->output( "\n  %s !!!\n", $PathInfo->{'ErrorMessage'} );
    }
        
    return ;
}

1;
