#======================================================================================================================
# Shell
#======================================================================================================================
package ePages::Shell ;
use base Shell::Shell ;

use strict ;

use DE_EPAGES::Database::API::Connection qw ( 
    RunOnStore 
) ;
use DE_EPAGES::Core::API::Error qw (
        ExistsError
        GetError
    ) ;
use ePages::ePages ;

#======================================================================================================================
# §function     new
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       Shell->new() ;
#----------------------------------------------------------------------------------------------------------------------
# §description  Constructor
#----------------------------------------------------------------------------------------------------------------------
# §return       $Object | The new object instance | Object
#======================================================================================================================
sub new {
    my $class = shift;

    my $self  = $class->SUPER::new({
        'Title'             => 'SHE: Shell ePages (Alpha version !!!)',
        'Prompt'            => '[she] ',
        'ResetStore'        => 0,
        'Commands'          => [
            'ePages/Command/Store',
            'ePages/Command/Path',
            'ePages/Command/Status',
            'ePages/Command/Childs',
            'ePages/Command/Get',
            'ePages/Command/Set',
            'ePages/Command/Delete',
            'Shell/Command/Test',
        ]
    }) ;

    $self->{'ePages'} = ePages::ePages->new() ;

    return $self;
}

#======================================================================================================================
# §function     getHeaderText
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       pending
#----------------------------------------------------------------------------------------------------------------------
# §description  pending
#======================================================================================================================
sub getHeaderText {
    my $self = shift;

    return <<HELP_TEXT

Wellcome to the ePages shell, a simple command-line tool to ease the interaction with the epages objects.

This is an experimental tool (Alpha version) which intends to include in one shell all the operations you need
to work with epages at low level: manage objects (create, read, update, delete) and more... Yes, epages includes
a lot os scripts to do almost everything, but it would be nice to have those utilities in one tool, isn't ? 

First steps:
    0. List of available commands and help for a specific one:
        >> help
        >> ? set
    1. Connect to a Store or BusinessUnit (database):
        >> use Store
    2. Browse the objects tree
        >> cd /Shops/DemoShop
        >> cd Users
    3. Information about the current object
        >> status
    4. List the childs of the current object 
        >> ls
    5. List all the attributes of the current object
        >> get
    6. Change the Birth date of a customer 
        >> cd /Shops/DemoShop/Customers/1000/BillingAddress
        >> set Birthday='21/08/1989 09:30:00'

Command-line arguments: she [ StoreName ] [ ObjectPath ]
    
    You can start she with arguments to connect a store:
        # she Store
    and select an object:
        # she Store /Shops/DemoShop
        
HELP_TEXT
}

#======================================================================================================================
# §function     run
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Shell->run()
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub run {
    my $self = shift ;

    if ( defined $ARGV[0] ) {
        $self->_runCommand( 'use', $ARGV[0] ) ;
    }
    
    do {
        $self->{'ResetStore'} = 0 ;
        if ( defined $self->{'ePages'}->getStore() ) {
            $self->runStore() ;
        } else {
            $self->SUPER::run() ;
        }
    } while ( $self->{'ResetStore'} ) ;

    return ;
}

#======================================================================================================================
# §function     runStore
# §state        private
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
sub runStore {
    my $self = shift ;

    my $Console = $self->getConsole() ;
    my $Store = $self->{'ePages'}->getStore() ;
    $Console->output( "  Connecting to store '$Store' ...\n" ) ;
    eval {
        RunOnStore(
          'Store' => $Store,
          'Sub'   => sub {
            $self->{'ePages'}->connect() ;
            $self->_runCommand( 'cd', ($ARGV[1])? $ARGV[1] : '/' ) ;
            $self->SUPER::run() ;
          }
        ) ;
    };
    if ( $@ ) {
        $self->error( $@ ) ;
        $Console->output( "\n" ) ;
        $self->{'ePages'}->reset() ;
        $self->SUPER::run() ;
    }

    return;
}

#======================================================================================================================
# §function     error
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Shell->error( $@ )
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $ShowByeText | TODO | boolean
#======================================================================================================================
sub error {
    my $self = shift;

    my $Error = @_ ;
    
    if ( ExistsError() ) {
        $Error = GetError() ;
        $Error = sprintf( "[%s] '%s'", $Error->{'Code'}, $Error->{'Message'} ) ;
    }

    $self->getConsole()->error( $Error ) ;

    return ;
}

1;
