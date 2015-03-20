#======================================================================================================================
# Get
#======================================================================================================================
package ePages::Command::Get ;
use base Shell::Command::Command;

use strict ;

use DE_EPAGES::Object::API::Factory qw ( 
    LoadRootObject 
    LoadObjectByPath 
);
use ePages::Attributes::Factory qw ( 
   NewObjectAttribute 
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

    return 'get' ;
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
        'details'       => [ 'd', 0 ],
        'ignore_case'   => [ 'i', 0 ],
        'filter_type'   => [ 't=s', undef ],
        'filter_attr'   => [ 'n=s', undef ],
        'filter_val'    => [ 'v=s', undef ],
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

    return [ 'List attributes of the current object' ] ;
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
    Lists the attributes for the current object, optionally filtered by Type, Alias or Value.
    
Usage: 
    $CmdName [Flags] [Options] Alias ...

Flags:
    -d          Print attribute details 
    -i          Ignore Case in the pattern filters (default: No)

Options:
    -t          Filter by Type using the Pattern (RegExp)
    -n          Filter by Attribute name using the Pattern (RegExp) (DEFAULT)
    -v          Filter by Value using the Pattern (RegExp)

Arguments:
    Alias       You can provide a list of exact attributes names to list
    
Examples:       
    $CmdName
    $CmdName -d Alias
    $CmdName '^Shop'
    $CmdName -i -n 'Shipping'

UNDER CONSTRUCTION !!!
    There are some attribute types not supported yet and the details option is provisional.
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
    
    $Console->debug( "Execute command GET\n" ) ;

    my $Object = $Shell->{'ePages'}->getObject() ;

    if ( defined $Object ) {

        $Console->output( "\n" );

        my $aArgs = $hArguments->{'@'} ;

        if ( (scalar @$aArgs) == 0 ) {
            $aArgs = undef ;
        }

        my $ShowDetails = ($hArguments->{'details'})? 'd' : '' ;
        my $IgnoreCase = ($hArguments->{'ignore_case'})? 'i' : '' ;
        my $FilterByType = $hArguments->{'filter_type'} ;
        my $FilterByAlias = $hArguments->{'filter_attr'} ;
        my $FilterByValue = $hArguments->{'filter_val'} ;

        if ( $IgnoreCase ) {
            $aArgs = map { lc } @$aArgs ;
        }
        
        if ( not $ShowDetails ) {
            $Console->output( 
                "   %-20s %-30s   %s\n",
                'TYPE',
                'NAME',
                'VALUE'
            ) ;
        }

        my $Class = $Object->class ;
        my $Attributes = $Class->get('Attributes') ;

        foreach my $Attribute ( @$Attributes ) {
            my $ObjectAttribute = NewObjectAttribute( $Object, $Attribute ) ;
            my $Name = $ObjectAttribute->getName() ;
            
            if ( $aArgs ) {
                my $SearchName = ( $IgnoreCase )? lc( $Name ) : $Name ;
                if ( not ( $SearchName ~~ $aArgs ) ) {
                    next ;
                }
            }

            if ( $FilterByAlias ) {
                my $RegExp = ( $IgnoreCase )? qr/$FilterByAlias/i : qr/$FilterByAlias/ ;
                if ( not ( $Name =~ $RegExp ) ) {
                    next ;
                }
            }
            my $Type  = $ObjectAttribute->getType() ;
            if ( $FilterByType ) {
                my $RegExp = ( $IgnoreCase )? qr/$FilterByType/i : qr/$FilterByType/ ;
                if ( not ( $Type =~ $RegExp ) ) {
                    next ;
                }
            }

            my $Value = $ObjectAttribute->getValueShort( 2 ) ;
            if ( $FilterByValue ) {
                my $RegExp = ( $IgnoreCase )? qr/$FilterByValue/i : qr/$FilterByValue/ ;
                if ( not ( $Value =~ $RegExp ) ) {
                    next ;
                }
            }

            if ( $ShowDetails ) {
                $Console->output( 
                    "%s\n",
                    $ObjectAttribute->getValueLong( 2 ) 
                ) ;
            } else {
                my $ContinueOutput = 
                    $Console->output( 
                        " - %-20s %-30s : %s\n",
                        $Type,
                        $Name,
                        $Value
                    ) ;
                if ( not $ContinueOutput ) {
                    $Console->output( "OUTPUT CANCELED BY USER !!!\n" );
                    return ;
                }
            }
        }

    } else {
        $Console->output( "\nNo object !!!\n" );
    }

    return;
}

1;
