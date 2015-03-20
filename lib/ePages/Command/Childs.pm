#======================================================================================================================
# Childs
#======================================================================================================================
package ePages::Command::Childs ;
use base Shell::Command::Command;

use strict ;

use DE_EPAGES::Object::API::Factory qw ( 
    LoadObjectByPath 
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

    return 'childs' ;
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

    return [ 'ls' ] ;
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
        'ignore_case'   => [ 'i', 0 ],
        'filter_class'  => [ 'c', 0 ],
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

    return [ 'List childs of the current object' ] ;
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
    Lists the childs for the current object, optionally filtered by Class o Alias.
    
Usage: 
    $CmdName [Flags] [Pattern]

Flags:
    -i              Ignore Case in the pattern filter (default: No)
    -c              Filter by Class (default: Alias)

Arguments:
    Pattern         You can provide a regular expression to filter the output

Examples:       
    $CmdName
    $CmdName '^Shop'
    $CmdName -i -c Object
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
    
    $Console->debug( "Execute command CHILDS\n" ) ;

    my $Object = $Shell->{'ePages'}->getObject() ;

    if ( defined $Object ) {

        my $Filter = undef ;
        my $FilterIgnoreCase = undef ;
        my $FilterByClass = undef ;

        my $aArgs = $hArguments->{'@'} ;

        my $CountArgs = scalar @$aArgs ;

        if ( $CountArgs == 1 ) {
            $Filter = $aArgs->[0] ;
            $FilterIgnoreCase = ($hArguments->{'ignore_case'})? 'i' : '' ;
            $FilterByClass = $hArguments->{'filter_class'} ;
        }

        $Console->output(
            "\n   %-10s%-30s%s\n",
            'ID',
            'CLASS',
            'ALIAS'
        ) ;

        my $ChildObjects = $Object->childrenIterator;

        while( my $Child = $ChildObjects->next ) {
            my $Alias = $Child->alias ;
            my $Class = $Child->get('Class')->alias ;
            if ( $Filter ) {
                my $FilterValue = ( $FilterByClass )? $Class : $Alias ;
                my $RegExp = ( $FilterIgnoreCase )? qr/$Filter/i : qr/$Filter/ ;
                if ( not ( $FilterValue =~ $RegExp ) ) {
                    next ;
                }
            }

            $Console->output(
                "   %-10s%-30s%s\n",
                $Child->id,
                $Class,
                $Alias
            );
        }

    } else {
        $Console->output( "\nNo object !!!\n" );
    }

    return;
}

1;
