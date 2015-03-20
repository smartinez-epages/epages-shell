#======================================================================================================================
# Delete
#======================================================================================================================
package ePages::Command::Delete ;
use base Shell::Command::Command;

use strict ;

use DE_EPAGES::Object::API::Factory qw ( 
    LoadRootObject 
    ExistsObject
    ExistsObjectByPath
    LoadObject 
    LoadObjectByPath 
);
use DE_EPAGES::WebInterface::API::MessageCenter qw (
    SynchronizeCache
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

    return 'delete' ;
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

    return [ 'rm' ] ;
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

    return [ 'Delete the current object (Dangerous !!!)' ] ;
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
Usage: $CmdName

Deletes the current object (dangerous !!!)

HELP_TEXT

}

#======================================================================================================================
# §function     execute
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Command->execute( $CommandArgs ) 
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $CommandArgs | Arguments provided for the command execution | string
#======================================================================================================================
sub execute {
    my $self = shift;

    my ( $CommandArgs ) = @_ ;

    my $hArguments = $self->_parseArguments( $CommandArgs ) ;

    my $Shell = $self->{'Shell'} ;
    my $Console = $Shell->getConsole() ;
    
    $Console->debug( "Execute command DELETE\n" ) ;

    my $Object = $Shell->{'ePages'}->getObject() ;

    if ( defined $Object ) {
        my $ObjectID = $Object->id ; 
        if ( $ObjectID != 1 ) {
            $Console->info( "\nCurrent object is\n  ID    %s\n  PATH  %s\n", $Object->id, $Object->pathString() );
            my $Response = lc( $Console->prompt( "\nDo you really want to delete it (Y/N)? : " ) ) ;
            if ( $Response eq 'y' ) {
                $Console->output( "Real delete NOT implemented yet.\n" );
            } else {
                $Console->output( "Delete cancelled.\n" );
            }
            SynchronizeCache() ;
        } else {
            $Console->output( 
                "\nmmmm ... Do you feel ok ? You are trying to delete the System object !!!\nI can't do that !!!\n\n"
            ) ;   
        }
    } else {
        $Console->output( "\nNo object !!!\n" );
    }

    return;
}


1;
