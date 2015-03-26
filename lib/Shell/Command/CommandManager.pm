#======================================================================================================================
# CommandManager
#======================================================================================================================
package Shell::Command::CommandManager;

use strict;

use Module::Load;

#======================================================================================================================
# §function     new
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       my $CommandManager = CommandManager->new($Shell);
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $Name | Description | type
#----------------------------------------------------------------------------------------------------------------------
# §return       $Name | Description | type
#======================================================================================================================
sub new {
    my $class = shift;
    my ($Shell) = @_;

    my $hAttributes = {
        'Shell'             => $Shell,  # Reference to Shell object parent
        'CommandsList'      => [],      # Array with all the available Command objects
        'CommandsHash'      => {},      # Hash table to lookup Commands by Name and Alias
        'CommandsNames'     => [],      # Array with the names of all available commands
    };

    return bless($hAttributes, $class);
}

#======================================================================================================================
# §function     getAllCommands
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       my $aCommands = $CommandManager->getAllCommands();
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub getAllCommands {
    my $self = shift;

    return $self->{'CommandsList'};
}

#======================================================================================================================
# §function     getCommandNames
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       my $aCommandNames = $CommandManager->getCommandNames();
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub getCommandNames {
    my $self = shift;

    return $self->{'CommandsNames'};
}

#======================================================================================================================
# §function     existsCommand
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       my $ExistsCommand = $CommandManager->existsCommand($CommandName);
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub existsCommand {
    my $self = shift;
    my ($CommandName) = @_;

    return defined $self->{'CommandsHash'}->{$CommandName};
}

#======================================================================================================================
# §function     getCommand
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       my $Command = $CommandManager->getCommand($CommandName);
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub getCommand {
    my $self = shift;
    my ($CommandName) = @_;

    return $self->{'CommandsHash'}->{$CommandName};
}

#======================================================================================================================
# §function     loadCommands
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       my $Command = $CommandManager->loadCommands($aCommandModuleList);
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub loadCommands {
    my $self = shift;
    my ($aCommandModuleList) = @_;
    
    $self->_loadCommands($aCommandModuleList);
    $self->_initCommandsHash();
    $self->_initNamesArray();

    return;
}

#======================================================================================================================
# §function     _loadCommands
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $CommandManager->_loadCommands($aCommandModuleList);
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub _loadCommands {
    my $self = shift;
    my ($aCommandModuleList) = @_;

    my $aCommandsList = $self->{'CommandsList'};
    foreach my $CommandModulePath (@$aCommandModuleList) {
        my $Command = $self->_loadCommandModule($CommandModulePath);
        if (defined $Command) {
            push(@$aCommandsList, $Command);
        }
    }

    return;
}

#======================================================================================================================
# §function     _loadCommandModule
# §state        private
#======================================================================================================================
sub _loadCommandModule {
    my $self = shift;
    my ($CommandModulePath) = @_;

    my $Shell = $self->{'Shell'};
    my $Console = $Shell->getConsole();
    my $CommandInstance = undef;
    eval {
        $Console->debug("Loading command module '%s'\n", $CommandModulePath);
        load $CommandModulePath;
        $Console->debug("Creating command '%s'\n", $CommandModulePath);
        $CommandInstance = $CommandModulePath->new($Shell);
    };
    if ($@) {
        $Console->output("ERROR: %s\n\n", $@);
    }
    if (not defined $CommandInstance) {
        $Console->output("Module '%s' not found !!!\n", $CommandModulePath);
    }

    return $CommandInstance;
}

#======================================================================================================================
# §function     _initCommandsHash
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $CommandManager->_initCommandsHash()
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub _initCommandsHash {
    my $self = shift;

    my $aCommandsList = $self->{'CommandsList'};
    my $hCommandsHash = $self->{'CommandsHash'};
    foreach my $Command (@$aCommandsList) {
        my $CommandName = lc($Command->getName());
        my $aCommandAlias = $Command->getAlias();
        $hCommandsHash->{$CommandName} = $Command;
        if (defined $aCommandAlias) {
            foreach my $Alias (@$aCommandAlias) {
                $hCommandsHash->{lc($Alias)} = $Command;
            }
        }
    }

    return;
}

#======================================================================================================================
# §function     _initNamesArray
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $CommandManager->_initNamesArray()
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub _initNamesArray {
    my $self = shift;

    my $aCommandsList = $self->{'CommandsList'};
    my @aUnsortedCommandsNames = ();
    foreach my $Command (@$aCommandsList) {
        my $CommandName = lc($Command->getName());
        push(@aUnsortedCommandsNames, $CommandName);
    }

    my $aCommandsNames = $self->{'CommandsNames'};
    foreach my $CommandName (sort @aUnsortedCommandsNames) {
        push(@$aCommandsNames, $CommandName);
    }

    return;
}

1;