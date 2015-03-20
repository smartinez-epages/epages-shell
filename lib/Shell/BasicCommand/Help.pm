#======================================================================================================================
# Help
#======================================================================================================================
package Shell::BasicCommand::Help;
use base Shell::Command::Command;

use strict;

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

    return 'help' ;
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

    return [ 'h', '?' ] ;
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

    return [
        'Show this help.',
        'Enter \'help <command>\' for detailed help.'
    ] ;
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

    my $Console = $self->{'Shell'}->getConsole() ;
    $Console->debug( "Execute command HELP\n" ) ;
    
    my $hArguments = $self->_parseArguments( $CommandArgs ) ;
    my $Args = $hArguments->{'@'} ;
    if ( scalar @$Args ) {
        $self->_showCommandHelp( $Args->[0] ) ;
    } else {
        $self->_showHelp() ;
    }
    $Console->output( "\n" ) ;

    return;
}

#======================================================================================================================
# §function     _showCommandHelp
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $HelpCommand->_showCommandHelp( $CommandName )
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $CommandName | Command name to request its help | string
#======================================================================================================================
sub _showCommandHelp {
    my $self = shift;

    my ( $CommandName ) = @_ ;

    my $Shell = $self->{'Shell'} ;
    my $Console = $Shell->getConsole() ;

    my $Command = $Shell->getCommand( $CommandName ) ;
    if ( defined $Command ) {
        $Console->output( "\nCommand : %s", $Command->getName() ) ;
        my $AliasList = $self->_formatCommandAliasList( $Command ) ;
        if ( defined $AliasList ) {
            $Console->output( "\nAliases : %s\n", $AliasList ) ;
        } else {
            $Console->output( "\n" ) ;
        }
        $Console->output( "\n%s", $Command->getHelp() ) ;
    } else {
        $Console->output( "ERROR: Unknown command '$CommandName'\n" ) ;
    }

    return ;
}

#======================================================================================================================
# §function     _formatCommandAliasList
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $AliasList = $HelpCommand->_formatCommandAliasList( $Command )
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $Command | Command to request its help | object
#----------------------------------------------------------------------------------------------------------------------
# §return       $AliasList | The list of alias for the command | string
#======================================================================================================================
sub _formatCommandAliasList {
    my $self = shift;

    my ( $Command ) = @_ ;

    my $AliasList = undef ;
    
    my $Aliases = $Command->getAlias() ;
    if ( scalar @$Aliases ) {
        my $Separator = '' ;
        foreach my $Alias ( @$Aliases ) {
            $AliasList .= $Separator.$Alias ;
            $Separator = ', ' ;
        }
    }

    return $AliasList ;
}

#======================================================================================================================
# §function     _showHelp
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $HelpCommand->_showHelp()
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub _showHelp {
    my $self = shift;

    my $Shell = $self->{'Shell'} ;

    my $CmdNames = $Shell->getCommandNames() ;
    foreach my $CommandName ( @$CmdNames ) {
        my $Command = $Shell->getCommand( $CommandName ) ;
        if ( $Command->getName() ne $self->getName() ) {
            $self->_showCommandDescription( $Command ) ;
        }
    }

    my $Console = $Shell->getConsole() ;
    $Console->output("\n") ;
    $self->_showCommandDescription( $self ) ;
    $Console->output("\n") ;

    return ;
}

#======================================================================================================================
# §function     _showCommandDescription
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $HelpCommand->_showCommandDescription( $Command )
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $Command | Command to request its help | object
#======================================================================================================================
sub _showCommandDescription {
    my $self = shift;

    my ( $Command ) = @_ ;

    my $Console = $self->{'Shell'}->getConsole() ;

    my $Name = $Command->getName() ;
    my $Help = $Command->getDescription() ;

    foreach my $HelpLine ( @$Help ) {
        $Console->output(
            "\n  %-15s%s",
            $Name,
            $HelpLine
        ) ;

        $Name = '' ;
    }

    return ;
}

1;
