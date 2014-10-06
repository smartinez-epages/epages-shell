#======================================================================================================================
# Test
#======================================================================================================================
package Shell::Command::Test ;
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

    return 'test' ;
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

    return [ 't', 'tst' ] ;
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
        'flag'  => [ 'f', 0 ],
        'one'   => [ 'one=i', 1 ],
        'two'   => [ 'two=s', undef ],
    } ;
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

    return [ 'Test command' ] ;
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
# §function     run
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Command->run( $hArguments ) 
#----------------------------------------------------------------------------------------------------------------------
# §description  Executes the command with the specified arguments
#----------------------------------------------------------------------------------------------------------------------
# §input        $hArguments | Arguments provided in the shell for this command | hash.ref
#======================================================================================================================
sub run {
    my $self = shift;

    my ( $hArguments) = @_ ;

    my $Console = $self->{'Shell'}->getConsole() ;
    
    $Console->debug( "Run Command TEST\n" ) ;

    $Console->output( "\nExample of a shell command with arguments.\n\n" ) ;
    $Console->output( 
        "flag  %s\none   %s\ntwo   '%s'\n", 
        $hArguments->{'flag'},
        $hArguments->{'one'},
        $hArguments->{'two'}
    ) ;

    my $aArgs = $hArguments->{'@'} ;
    if ( scalar @$aArgs ) {
        $Console->output( "\nargs:\n" ) ;
        foreach my $Arg ( @$aArgs ) {
            $Console->output( "%10s%s\n", '', $Arg ) ;
        }
    } else {
        $Console->output( "%-10s%s\n", 'args', 'none' ) ;
    }

    return;
}

1;
