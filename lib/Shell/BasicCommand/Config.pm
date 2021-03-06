#======================================================================================================================
# Config
#======================================================================================================================
package Shell::BasicCommand::Config;
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

    return 'config' ;
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

    return [ 'Set/Get the shell configuration properties' ] ;
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
Usage:
    $CmdName -i
    $CmdName [ PropertyName [ NewPropertyValue ]]

Description:
    Lists the configuration properties (without arguments)
    Shows a property value (one argument) 
    Change a property value (two arguments)

Options:
    -i                      List configuration properties information
    
Arguments:
    PropertyName            Name of an existing configuration property
    NewPropertyValue        New value for the property
    
Examples:
       $CmdName
       $CmdName prompt
       $CmdName verbose 1
       $CmdName prompt '# '

HELP_TEXT

}

#======================================================================================================================
# §function     getArguments
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $aArguments = $Command->getArguments() ;
#----------------------------------------------------------------------------------------------------------------------
# §description  Returns a hash with the arguments to use with the command. The hash will be use with the Getopt lib.
#----------------------------------------------------------------------------------------------------------------------
# §return       $hArgumens | Arguments specification for the command | hash.ref
#======================================================================================================================
sub getArguments {
    my $self = shift;

    return {
        'info'  => [ 'i', 0 ],
    } ;
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
    my ($CommandArgs) = @_;

    my $Shell = $self->{'Shell'};
    $Shell->getConsole()->debug( "Execute command CONFIG\n" );

    my $hArguments = $self->_parseArguments($CommandArgs);
    if ($hArguments->{'info'}) {
        $self->_listConfigPropertiesInfo();
    } else {
        my $Args = $hArguments->{'@'} ;
        my $numArgs = scalar @$Args;
        if ($numArgs == 0) {
            $self->_listConfigProperties();
        } elsif ($numArgs == 1) {
            $self->_doConfigProperty($Args->[0]);
        } elsif ($numArgs == 2) {
            $self->_doConfigProperty($Args->[0], $Args->[1]);
        } else {
            $Shell->getConsole()->error( "Wrong number of arguments%n" );
        }
    }

    return;
}

#======================================================================================================================
# §function     _listConfigPropertiesInfo
# §state        private
#======================================================================================================================
sub _listConfigPropertiesInfo {
    my $self = shift;

    my $Shell = $self->{'Shell'};
    my $Console = $Shell->getConsole();
    my $hConfigProperties = $Shell->getConfiguration()->getProperties();
    foreach my $PropertyName (sort(keys(%$hConfigProperties))) {
        my $Property = $hConfigProperties->{$PropertyName};
        $Console->output("  %-20s : %s\n", $PropertyName, $Property->getDescription());
    }
    return;
}

#======================================================================================================================
# §function     _listConfigProperties
# §state        private
#======================================================================================================================
sub _listConfigProperties {
    my $self = shift;

    my $Shell = $self->{'Shell'};
    my $Console = $Shell->getConsole();
    $Console->output("\n");
    my $hConfigProperties = $Shell->getConfiguration()->getProperties();
    foreach my $PropertyName (sort(keys(%$hConfigProperties))) {
        my $Property = $hConfigProperties->{$PropertyName};
        $Console->output("  %-20s : %s\n", $PropertyName, $Property->getValue());
    }
    $Console->output("\n");

    return;
}

#======================================================================================================================
# §function     _doConfigProperty
# §state        private
#======================================================================================================================
sub _doConfigProperty {
    my $self = shift;
    my ($PropertyName, $PropertyValue) = @_;
    
    my $Shell = $self->{'Shell'};
    my $Console = $Shell->getConsole();
    my $Property = $Shell->getConfiguration()->getProperty($PropertyName);
    if (defined $Property) {
        if (defined $PropertyValue) {
            eval {
                $Property->setValue($PropertyValue);
            };
            if ($@) {
                $Console->error($@->shortMessage());
            }
        }
        $Console->output("\n  %s : %s\n\n", $PropertyName, $Property->getValue());
    } else {
        $Console->error("Configuration attribute '$PropertyName' doesn't exist%n");
    }

    return;
}

1;
