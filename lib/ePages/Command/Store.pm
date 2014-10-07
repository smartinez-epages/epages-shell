#======================================================================================================================
# Store
#======================================================================================================================
package ePages::Command::Store ;
use base Shell::Command ;

use strict ;

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

    return 'store' ;
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

    return [ 'use' ] ;
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

    return [ 'Change/Show the current Store (database)' ] ;
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
    Open a session in the specified epages Store (database)

Usage: 
    $CmdName [ StoreName ]

Arguments:
    StoreName       A valid Store name to connect with
    
                    Without arguments you will get the current store

Examples:
    $CmdName
    $CmdName Store
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
    
    $Console->debug( "Execute command STORE\n" ) ;

    my $aArgs = $hArguments->{'@'} ;
    my $CountArgs = scalar @$aArgs ;
    if ( $CountArgs == 0 ) {
        if ( $Shell->{'ePages'}->isStoreActive() ) {
            my $Store = $Shell->{'ePages'}->getStore() ;
            $Console->output( "\nCurrent store: $Store\n" );
        } else {
            $Console->output( "\nNo store connected !\n" );
        }
    } elsif ( $CountArgs == 1 ) {
        $Shell->{'ePages'}->setStore( $aArgs->[0] ) ;
        $Shell->{'ResetStore'} = 1 ;
        $Shell->exit() ;
    } else {
        $Console->output( "\nToo much arguments !\n" );
    }

    return ;
}

1;
