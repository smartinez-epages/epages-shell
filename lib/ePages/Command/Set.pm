#======================================================================================================================
# Set
#======================================================================================================================
package ePages::Command::Set ;
use base Shell::Command ;

use strict ;

use DE_EPAGES::Object::API::Factory qw ( 
    LoadRootObject 
    ExistsObject
    ExistsObjectByPath
    LoadObject 
    LoadObjectByPath 
);
use DE_EPAGES::WebInterface::API::MessageCenter qw (
    SynchronizeCache
);
use ePages::Attributes::Factory qw ( 
    NewObjectAttribute 
);
use DE_EPAGES::Core::API::Object::DateTimeFormatter;

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

    return 'set' ;
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
        'language'      => [ 'l=s', undef ],
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

    return [ 'Set value to attributes in the current object' ] ;
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
Usage: $CmdName [ -l lang ] Attribute=Value ...

Set values to the specified attributes in the current object

options:

    -l          Language code (Ex: en, de, fr, es, ...). Default: /System/LanguageID

examples:       $CmdName IsClosed=0
                $CmdName -l en Name='Name of Object' IsVisible=1
                
UNDER CONSTRUCTION !!!
    There are some attribute types not supported yet and the language is forced to English.
    Supported types (for the moment):
    
        Integer         set DefaultPageSize=20
        Boolean         set IsClosed=1
        String          set Name='This is a text'
        Object          set DefaultStyle=/Shops/DemoShop/Styles/Diamonds
        Date            set GrantServiceAccessUntil='31/12/2015'
        DateTime        set LastMerchantLogin='25/08/2014 12:30:00'
        
    Other types will be set without checking ... It means, the provided value will be set as is:
    
        Unknown         set EMail='whatever'
        
    You can unset an attribute using the null value:
    
        set GrantServiceAccessUntil=null
    
HELP_TEXT

}

#======================================================================================================================
# §function     run
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       pending
# §example      pending
#----------------------------------------------------------------------------------------------------------------------
# §description  pending
#----------------------------------------------------------------------------------------------------------------------
# §input        $Name | Description | type
#----------------------------------------------------------------------------------------------------------------------
# §return       $Name | Description | type
#======================================================================================================================
sub run {
    my $self = shift;

    my ( $hArguments) = @_ ;

    my $Shell = $self->{'Shell'} ;
    my $Console = $Shell->getConsole() ;
    
    $Console->debug( "Run Command SET\n" ) ;

    my $Object = $Shell->{'ePages'}->getObject() ;

    if ( defined $Object ) {

        $Console->output( "\n" );

#        my $Language = $Shell->{'Language'} ;
#        $Shell->dump( $hArguments ) ;
#        $Shell->dump( $Language ) ;
#        my $LanguageCode = $hArguments->{'language'} // $Language->{'Default'} ;
#        if ( not defined ( $Language->{'Languages'}->{$LanguageCode} ) ) {
#            $Shell->output( "  Language '%s' not found\n", $LanguageCode ) ;
#            return ;
#        }
#        my $LanguageID = $Language->{'Languages'}->{$LanguageCode}->{'ID'};
        my $LanguageID = 2 ;

        my $Class = $Object->class ;
        my $aArgs = $hArguments->{'@'} ;
        for my $Arg ( @$aArgs ) {
            if ( $Arg =~ /(.+)=(.*)/ ) {
                my $Attribute = $1 ;
                my $Value = $2 ;
                my $PrintValue = $Value ;
                if ( $Class->existsAttribute( $Attribute ) ) {
                    my $ObjectAttribute = $Class->attribute( $Attribute ) ;
                    my $hAttributes = $ObjectAttribute->{'Attributes'} ;
                    if ( $hAttributes->{'IsReadOnly'} ) {
                        $Console->output( "  Attribute '%s' is READ ONLY !!!\n", $Attribute ) ;
                    } else {
                        if ( $Value eq 'null' ) {
                            $Value = undef ;
                            $PrintValue = '(null)' ;
                        }
                        if ( defined $Value and $hAttributes->{'IsObject'} ) {
                            if ( $Value =~ /\d+/ ) {
                                if ( ExistsObject( $Value ) ) {
                                    $Value = LoadObject( $Value ) ;
                                }
                            } else {
                                if ( ExistsObjectByPath( $Value ) ) {
                                    $Value = LoadObjectByPath( $Value ) ;
                                }
                            }
                            if ( defined $Value  ) {
                                $PrintValue = '[ObjectID : '.$Value->id.' ]' ;
                            } else {
                                $Console->output( "  Object '%s' not found\n", $Value ) ;
                                next ;
                            }
                        }
                        if ( defined $Value and $hAttributes->{'Type'} eq 'DateTime' ) {
                            my $Formatter = DE_EPAGES::Core::API::Object::DateTimeFormatter->new();
                            $Value = $Formatter->parse_datetime( $Value, 'datetime', '%d/%m/%Y %H:%M:%S' );
                        }
                        if ( defined $Value and $hAttributes->{'Type'} eq 'Date' ) {
                            my $Formatter = DE_EPAGES::Core::API::Object::DateTimeFormatter->new();
                            $Value = $Formatter->parse_datetime( $Value, 'date', '%d/%m/%Y' );
                        }
                        $Console->output( "  %s = %s\n", $Attribute, $PrintValue ) ;
                        $Object->set({ $Attribute => $Value }, $LanguageID ) ;
                    }
                } else {
                    $Console->output( "  Attribute '%s' doesn't exist\n", $Attribute ) ;
                }
            } else {
                $Console->output( "  Sintax error\n" ) ;
            }
        }
        SynchronizeCache() ;
        
    } else {
        $Console->output( "\nNo object !!!\n" );
    }

    return;
}


1;
