#======================================================================================================================
# Shell
#======================================================================================================================
package ePages::Shell;
use base Shell::Shell;

use strict;

use DE_EPAGES::Database::API::Connection qw ( 
    RunOnStore 
);
use DE_EPAGES::Core::API::Error qw (
        ExistsError
        GetError
    );

use ePages::ePages;

#======================================================================================================================
# §function     new
# §state        public
#======================================================================================================================
sub new {
    my $class = shift;

    my $hOptions = $_[0] // {};

    my $hAttributes  = {
        'Name'              => 'she',
        'Title'             => 'SHE: Shell ePages (Beta 3)',
        'ResetStore'        => 0,
        'ePages'            => ePages::ePages->new(), 
        'Configuration'     => [
                                    {
                                        'Name'          => 'prompt',
                                        'Value'         => '[she] ',
                                        'Description'   => 'ePages shell prompt'
                                    },
                                    {
                                        'Name'          => 'fmtdatetime',
                                        'Value'         => '%d/%m/%Y %H:%M:%S',
                                        'Description'   => 'epages datetime objects format'
                                    },
                                    {
                                        'Name'          => 'fmtdate',
                                        'Value'         => '%d/%m/%Y',
                                        'Description'   => 'epages date objects format'
                                    },
                               ],
        'Commands'          => [
                                    'ePages::Command::Store',
                                    'ePages::Command::Path',
                                    'ePages::Command::Status',
                                    'ePages::Command::Childs',
                                    'ePages::Command::Cache',
                                    'ePages::Command::Get',
                                    'ePages::Command::Set',
                                    'ePages::Command::Delete',
                               ],
        'Parameters'        => {
            'Store' => [ 'storename=s', undef ],
            'Path'  => [ 'path=s',      undef ],
        },
    };

    return $class->SUPER::new({ %$hAttributes, %$hOptions });
}

#======================================================================================================================
# §function     getHeaderText
# §state        public
#======================================================================================================================
sub getHeaderText {
    my $self = shift;

    return <<HELP_TEXT

Wellcome to the ePages shell, a simple command-line tool to ease the interaction with the epages objects.

This is an experimental tool (Beta version) which intends to include in one shell all the operations you need
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
# §function     _run
# §state        protected
#======================================================================================================================
sub _run {
    my $self = shift;

    $self->{'ePages'}->open();

    my $Arguments = $self->getArguments();
    my $StoreName = $Arguments->{'@'}->[0]; 
    if ( defined $StoreName ) {
        $self->executeCommand( 'use', $StoreName );
    }
        
    do {
        $self->{'ResetStore'} = 0;
        if ( defined $self->{'ePages'}->getStore() ) {
            $self->_runOnStore();
        } else {
            $self->SUPER::_run();
        }
    } while ( $self->{'ResetStore'} );

    $self->{'ePages'}->close();

    return;
}

#======================================================================================================================
# §function     _runOnStore
# §state        private
#======================================================================================================================
sub _runOnStore {
    my $self = shift;

    my $Console = $self->getConsole();
    my $Store = $self->{'ePages'}->getStore();
    $Console->info( "  Connecting to store '$Store' ...\n" );
    eval {
        my $Arguments = $self->getArguments();
        my $ObjectPath = $Arguments->{'@'}->[1] // '/'; 
        RunOnStore(
          'Store' => $Store,
          'Sub'   => sub {
            $self->{'ePages'}->connect();
            $self->executeCommand( 'cd', $ObjectPath );
            $self->SUPER::_run();
          }
        );
    };
    if ( $@ ) {
        $self->error( $@ );
        $Console->output( "\n" );
        $self->{'ePages'}->reset();
        $self->SUPER::_run();
    }

    return;
}

#======================================================================================================================
# §function     error
# §state        public
#======================================================================================================================
sub error {
    my $self = shift;

    my $Error = @_;
    
    if ( ExistsError() ) {
        $Error = GetError();
        $Error = sprintf( "[%s] '%s'", $Error->{'Code'}, $Error->{'Message'} );
    }

    $self->getConsole()->error( $Error );

    return;
}

1;
