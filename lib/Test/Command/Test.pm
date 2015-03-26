#======================================================================================================================
# Test
#======================================================================================================================
package Test::Command::Test;
use base Shell::Command::Command;

use strict;

#======================================================================================================================
# §function     getName
# §state        public
#======================================================================================================================
sub getName {
    my $self = shift;

    return 'test';
}

#======================================================================================================================
# §function     getAlias
# §state        public
#======================================================================================================================
sub getAlias {
    my $self = shift;

    return [ 't', 'tst' ];
}

#======================================================================================================================
# §function     getParameters
# §state        public
#======================================================================================================================
sub getParameters {
    my $self = shift;

    return {
        'flag'  => [ 'f', 0 ],
        'one'   => [ 'one=i', 1 ],
        'two'   => [ 'two=s', undef ],
    };
}

#======================================================================================================================
# §function     getDescription
# §state        public
#======================================================================================================================
sub getDescription {
    my $self = shift;

    return [ 'Test command' ];
}

#======================================================================================================================
# §function     getHelp
# §state        public
#======================================================================================================================
sub getHelp {
    my $self = shift;

    my $CmdName = $self->getName();

    return <<HELP_TEXT
Description:
    This is a test command which simply show the provided arguments ...

Usage:
    $CmdName [Flags] [Options] args ...

Flags:
    -f              Example of a flag (true/false). Default: false

Options:
    -one            Expected value is a number. Default: 1
    -two            Expected vlause is a string. Default: undef

Arguments:
    You can type a list of values ...

Examples:
    $CmdName alpha
    $CmdName -f -one 123 -two 'a simple string' alpha beta gamma
HELP_TEXT
}

#======================================================================================================================
# §function     execute
# §state        public
#======================================================================================================================
sub execute {
    my $self = shift;
    my ($CommandArgs) = @_;

    my $hArguments = $self->_parseArguments($CommandArgs);

    my $Console = $self->{'Shell'}->getConsole();
    $Console->debug("Execute command TEST\n");

    $Console->output("\nExample of a shell command with arguments.\n\n");
    $Console->output(
        "flag  %s\none   %s\ntwo   '%s'\n",
        $hArguments->{'flag'},
        $hArguments->{'one'},
        $hArguments->{'two'}
    );

    my $aArgs = $hArguments->{'@'};
    if (scalar @$aArgs) {
        $Console->output("\nargs:\n");
        foreach my $Arg (@$aArgs) {
            $Console->output("%10s%s\n", '', $Arg);
        }
    } else {
        $Console->output("%-10s%s\n", 'args', 'none');
    }

    return;
}

1;
