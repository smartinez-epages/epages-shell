#======================================================================================================================
# Help
#======================================================================================================================
package Shell::BasicCommand::Help;
use base Shell::Command::Command;

use strict;

#======================================================================================================================
# §function     getName
# §state        public
#======================================================================================================================
sub getName {
    my $self = shift;

    return 'help';
}

#======================================================================================================================
# §function     getAlias
# §state        public
#======================================================================================================================
sub getAlias {
    my $self = shift;

    return [ 'h', '?' ];
}

#======================================================================================================================
# §function     getDescription
# §state        public
#======================================================================================================================
sub getDescription {
    my $self = shift;

    return [
        'Show this help.',
        'Enter \'help <command>\' for detailed help.'
    ];
}

#======================================================================================================================
# §function     execute
# §state        public
#======================================================================================================================
sub execute {
    my $self = shift;
    my ($CommandArgs) = @_;

    my $Console = $self->{'Shell'}->getConsole();
    $Console->debug("Execute command HELP\n");

    my $hArguments = $self->_parseArguments($CommandArgs);
    my $Args = $hArguments->{'@'};
    if (scalar @$Args) {
        $self->_showCommandHelp($Args->[0]);
    } else {
        $self->_showHelp();
    }
    $Console->output("\n");

    return;
}

#======================================================================================================================
# §function     _showCommandHelp
# §state        private
#======================================================================================================================
sub _showCommandHelp {
    my $self = shift;
    my ($CommandName) = @_;

    my $Shell = $self->{'Shell'};
    my $Console = $Shell->getConsole();

    my $Command = $Shell->getCommandManager()->getCommand($CommandName);
    if (defined $Command) {
        $Console->output("\nCommand : %s", $Command->getName());
        my $AliasList = $self->_formatCommandAliasList($Command);
        if (defined $AliasList) {
            $Console->output("\nAliases : %s\n", $AliasList);
        } else {
            $Console->output("\n");
        }
        $Console->output("\n%s", $Command->getHelp());
    } else {
        $Console->output("ERROR: Unknown command '$CommandName'\n");
    }

    return;
}

#======================================================================================================================
# §function     _formatCommandAliasList
# §state        private
#======================================================================================================================
sub _formatCommandAliasList {
    my $self = shift;
    my ($Command) = @_;

    my $AliasList = undef;
    my $Aliases = $Command->getAlias();
    if (scalar @$Aliases) {
        my $Separator = '';
        foreach my $Alias (@$Aliases) {
            $AliasList .= $Separator.$Alias;
            $Separator = ', ';
        }
    }

    return $AliasList;
}

#======================================================================================================================
# §function     _showHelp
# §state        private
#======================================================================================================================
sub _showHelp {
    my $self = shift;

    my $Shell = $self->{'Shell'};

    my $CommandManager = $Shell->getCommandManager();
    my $CmdNames = $CommandManager->getCommandNames();
    foreach my $CommandName (@$CmdNames) {
        my $Command = $CommandManager->getCommand($CommandName);
        if ($Command->getName() ne $self->getName()) {
            $self->_showCommandDescription($Command);
        }
    }

    my $Console = $Shell->getConsole();
    $Console->output("\n");
    $self->_showCommandDescription($self);
    $Console->output("\n");

    return;
}

#======================================================================================================================
# §function     _showCommandDescription
# §state        private
#======================================================================================================================
sub _showCommandDescription {
    my $self = shift;
    my ($Command) = @_;

    my $Console = $self->{'Shell'}->getConsole();

    my $Name = $Command->getName();
    my $Help = $Command->getDescription();
    foreach my $HelpLine (@$Help) {
        $Console->output(
            "\n  %-15s%s",
            $Name,
            $HelpLine
        );
        $Name = '';
    }

    return;
}

1;
