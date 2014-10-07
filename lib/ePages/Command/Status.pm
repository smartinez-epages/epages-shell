#======================================================================================================================
# Status
#======================================================================================================================
package ePages::Command::Status ;
use base Shell::Command ;

use strict ;

use DE_EPAGES::Object::API::Factory qw ( 
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

    return 'status' ;
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

    return [ 's' ] ;
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
    Show information about the current Store and Object

Usage: 
    $CmdName
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

    $self->{'Shell'}->getConsole()->debug( "Execute command STATUS\n" ) ;

    $self->_showStoreStatus() ;
    $self->_showObjectStatus() ;

    return;
}

#======================================================================================================================
# §function     _showStoreStatus
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Command->_showStoreStatus() 
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub _showStoreStatus {
    my $self = shift;

    my $Shell = $self->{'Shell'} ;
    my $Console = $Shell->getConsole() ;
    my $ePages = $Shell->{'ePages'} ;
    
    if ( $ePages->isStoreActive() ) {
        $Console->output("\n  %-20s%s\n", 'Store:', $ePages->getStore() ) ;
        $self->_showLanguageStatus( $ePages->getLanguageInfo() ) ;
    } else {
        $Console->output("\n  %-20s%s\n", 'Store:', 'none' ) ;
    }

    return;
}

#======================================================================================================================
# §function     _showLanguageStatus
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Command->_showLanguageStatus( $LanguageInfo ) 
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub _showLanguageStatus {
    my $self = shift;

    my ( $LanguageInfo ) = @_ ;
    
    if ( defined $LanguageInfo ) {
        my $Console = $self->{'Shell'}->getConsole() ;
        my $DefaultLang = $LanguageInfo->getDefaultCode() ;
        my $Languages = $LanguageInfo->getLanguages() ;
        my $LangLabel = 'Languages:' ;
        for my $LanguageCode ( keys %$Languages) {
            my $Language = $Languages->{$LanguageCode} ;
            $Console->output(
                "  %-20s%s >> %s %s\n",
                $LangLabel,
                $Language->{'Code'},
                $Language->{'Name'},
                ( $DefaultLang eq $LanguageCode )? '(default)' : ''
            ) ;
            $LangLabel = '' ;
        }
    }

    return;
}

#======================================================================================================================
# §function     _showObjectStatus
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Command->_showObjectStatus() 
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub _showObjectStatus {
    my $self = shift;

    my $Shell = $self->{'Shell'} ;
    my $Console = $Shell->getConsole() ;
    my $ePages = $Shell->{'ePages'} ;
    my $Object = $ePages->getObject() ;
    
    if ( $Object ) {
        $Console->output("  %-20s%s\n", 'Object:', $Object->alias ) ;
        $Console->output("  %-20s%s\n", 'ObjectID:', $Object->id ) ;
        $Console->output("  %-20s%s\n", 'Path:', $Object->get('Path') ) ;
        $Console->output("  %-20s%s\n", 'Class:', $Object->get('Class')->alias ) ;
    } else {
        $Console->output("  %-20s%s\n", 'Object', 'none' ) ;
    }

    return;
}

1;
