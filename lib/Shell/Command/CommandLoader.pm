#======================================================================================================================
# CommandLoader
#======================================================================================================================
package Shell::Command::CommandLoader;

use strict;

use Module::Load;

#======================================================================================================================
# §function     new
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       CommandLoader->new( $Shell );
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $Name | Description | type
#----------------------------------------------------------------------------------------------------------------------
# §return       $Name | Description | type
#======================================================================================================================
sub new {
    my $Class = shift;

    my ($Shell) = @_;

    my $hAttributes = {
        'Shell'     => $Shell,
    };

    return bless( $hAttributes, $Class );
}

#======================================================================================================================
# §function     loadCommand
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       pending
# §example      pending
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $CommandModule | Description | string
#----------------------------------------------------------------------------------------------------------------------
# §return       $Command | Loads dynamically a command object by its ModuleName | object
#======================================================================================================================
sub loadCommand {
    my $self = shift;

    my ( $CommandModule, $CommandOptions ) = @_;

    my $Shell = $self->{'Shell'};
    my $Console = $Shell->getConsole();

    my $CommandInstance = undef;
    eval {
        $Console->debug("Loading command module '%s'\n", $CommandModule);
        load $CommandModule;
        $Console->debug("Creating command '%s'\n", $CommandModule);
        $CommandInstance = $CommandModule->new($Shell, $CommandOptions);
    };
    if ($@) {
        $Console->output("ERROR: %s\n\n", $@);
    }
    if (not defined $CommandInstance) {
        $Console->output("Module '%s' not found !!!\n", $CommandModule);
    }

    return $CommandInstance;
}

1;