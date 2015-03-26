#======================================================================================================================
# Alias
#======================================================================================================================
package Shell::BasicCommand::Alias;
use base Shell::Command::Command;

use strict;

#======================================================================================================================
# §function     getName
# §state        public
#======================================================================================================================
sub getName {
    my $self = shift;

    return 'alias';
}

#======================================================================================================================
# §function     getAlias
# §state        public
#======================================================================================================================
sub getAlias {
    my $self = shift;

    return [ 'al' ];
}

#======================================================================================================================
# §function     getDescription
# §state        public
#======================================================================================================================
sub getDescription {
    my $self = shift;

    return [
        'Show the alias for the available commands.',
    ];
}

#======================================================================================================================
# §function     execute
# §state        public
#======================================================================================================================
sub execute {
    my $self = shift;
    my ($CommandArgs) = @_;

    my $Shell = $self->{'Shell'};
    my $Console = $Shell->getConsole();

    $Console->debug("Execute command ALIAS\n");
    $Console->output("\nAvailable commands and their alias ( - means no alias ) :\n\n");

    my $CommandManager = $Shell->getCommandManager();
    my $CmdNames = $CommandManager->getCommandNames();
    foreach my $CommandName (@$CmdNames) {
        $self->_showComandAlias( $CommandManager->getCommand($CommandName ));
    }

    $Console->output("\n");

    return;
}

#======================================================================================================================
# §function     _showComandAlias
# §state        private
#======================================================================================================================
sub _showComandAlias {
    my $self = shift;
    my ($Command) = @_;

    my $Console = $self->{'Shell'}->getConsole();
    my $Aliases = $Command->getAlias();
    if ((scalar @$Aliases) == 0) {
        $Aliases = [ '-'];
    }

    $Console->output("  - %-20s", $Command->getName());

    my $Separator = '';
    foreach my $Alias (@$Aliases) {
        $Console->output("%s%s", $Separator, $Alias);
        $Separator = ', ';
    }

    $Console->output("\n");

    return;
}

1;
