#======================================================================================================================
# §package      Shell::Shell
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
package Shell::Shell;

use strict;

use Shell::Configuration::Configuration;
use Shell::Command::CommandManager;
use Shell::Command::CommandMetadata; 
use Shell::Console::ConsoleManager;
use Shell::Console::TerminalConsole;

my $Version = '0.1';

my $aDefaulConfiguration = [
    {
        'Name'          => 'prompt',
        'Value'         => '> ',
        'Description'   => 'Shell prompt'
    },
];

my $aDefaultCommandList = [
    'Shell::BasicCommand::Alias',
    'Shell::BasicCommand::Clear',
    'Shell::BasicCommand::Config',
    'Shell::BasicCommand::Echo',
    'Shell::BasicCommand::Pause',
    'Shell::BasicCommand::Quit',
    'Shell::BasicCommand::Help'
];

my $hDefaultParameters = {
    'NoPager'           => [ 'nopager',     0 ],
    'ShowPrompt'        => [ 'prompt',      0 ],
    'NoHeader'          => [ 'noheader',    0 ],
    'Help'              => [ 'help',        0 ],
    'BatchFileName'     => [ 'batch=s',     undef ],
};

#======================================================================================================================
# §function     new
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       my $Shell = Shell::Shell->new( $hOptions );
#----------------------------------------------------------------------------------------------------------------------
# §description  Shell constructor
#----------------------------------------------------------------------------------------------------------------------
# §input        $hOptions | Construction options | hash.ref
#----------------------------------------------------------------------------------------------------------------------
# §return       $Shell | New object instance | object
#======================================================================================================================
sub new {
    my $class = shift;

    my $hOptions = $_[0] // {};

    my $hAttributes = {
        'Exit'                  => 0,
        'Name'                  => 'she',
        'Title'                 => "Simple shell v$Version",
        'HelpTxt'               => 'Type \'help\' or \'?\' for help\n',
        'PrintHeader'           => 1,
        'Configuration'         => Shell::Configuration::Configuration->new($aDefaulConfiguration),
        'Metadata'              => undef,
        'ConsoleManager'        => undef,
        'Console'               => undef,
        'CommandManager'        => undef,
        'Commands'              => $aDefaultCommandList,
    };

    # Append child configuration properties
    if (defined $hOptions->{'Configuration'}) {
        $hAttributes->{'Configuration'}->addProperties($hOptions->{'Configuration'});
        delete($hOptions->{'Configuration'});
    }

    # Mix all the commands lists (Base and Child object) in one
    if (defined $hOptions->{'Commands'}) {
        my $aChildCommands = $hOptions->{'Commands'};
        push(@$aDefaultCommandList, @$aChildCommands);
        delete($hOptions->{'Commands'});
    }

    my $self = bless({ %$hAttributes, %$hOptions }, $class);
    
    $self->{'Metadata'} = Shell::Command::CommandMetadata->new($self);
    $self->{'ConsoleManager'} = Shell::Console::ConsoleManager->new($self);
    $self->{'CommandManager'} = Shell::Command::CommandManager->new($self);
    
    return $self;
}

#======================================================================================================================
# §function     getMetadata
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Shell->getMetadata()
#======================================================================================================================
sub getMetadata {
    my ($self) = shift;
        
    return {
        'Name'      => $self->{'Name'},
        'Header'    => $self->{'Title'},
        'Usage'     => '{{NAME}} [ flags ] [ options ] [ StoreName [ ObjectPath ] ]',
        'Flags'     => [
                            {
                                'Name'      => 'ShowHelp',
                                'Key'       => 'help',
                                'Default'   => 0,
                                'Text'      => 'Show this help'
                            },
                            {
                                'Name'      => 'NoHeader',
                                'Key'       => 'noheader',
                                'Default'   => 0,
                                'Text'      => 'Don\'t print the starter heaader'
                            },
#                            {
#                                'Name'      => 'NoPager',
#                                'Key'       => 'nopager',
#                                'Default'   => 0,
#                                'Text'      => 'Disable pager'
#                            },
#                            {
#                                'Name'      => 'BatchPrompt',
#                                'Key'       => 'prompt',
#                                'Default'   => 0,
#                                'Text'      => 'Enable print prompt in Batch mode'
#                            },
                       ],
        'Options'   => [
                            {
                                'Name'      => 'BatchFile',
                                'Key'       => 'batch',
                                'Type'      => 'string',
                                'Default'   => undef,
                                'Text'      => 'Execute batch file and exit'
                            },
                       ],
        'Arguments' => [
                            {
                                'Name'      => 'StoreName',
                                'Type'      => 'string',
                                'Optional'  => 1,
                                'Text'      => 'Connect to the StoreName'
                            },
                            {
                                'Name'      => 'ObjectPath',
                                'Type'      => 'string',
                                'Optional'  => 1,
                                'Text'      => 'And select the object by path'
                            },
                       ],
        'Examples'  => [
                            '{{NAME}} ',
                            '{{NAME}} Store /Shops/DemoShop',
                            '{{NAME}} -nopager -noheader Site',
                            '{{NAME}} -prompt -batch script.txt'
                       ],
        'xExtra'     => [ 
                            'Extra info for {{NAME}}',
                            'JURL'
                        ]
    };
}

#======================================================================================================================
# §function     getConfiguration
# §state        public
#======================================================================================================================
sub getConfiguration {
    my $self = shift;

    return $self->{'Configuration'};
}

#======================================================================================================================
# §function     getConsoleManager
# §state        public
#======================================================================================================================
sub getConsoleManager {
    my $self = shift;

    return $self->{'ConsoleManager'};
}

#======================================================================================================================
# §function     getConsole
# §state        public
#======================================================================================================================
sub getConsole {
    my $self = shift;

    return $self->{'Console'};
}

#======================================================================================================================
# §function     getCommandManager
# §state        public
#======================================================================================================================
sub getCommandManager {
    my $self = shift;

    return $self->{'CommandManager'};
}

#======================================================================================================================
# §function     getParameters
# §state        public
#======================================================================================================================
sub getParameters {
    my $self = shift;

    return $self->{'Parameters'};
}

#======================================================================================================================
# §function     getArguments
# §state        public
#======================================================================================================================
sub getArguments {
    my $self = shift;

    return $self->getParameters()->getArguments();
}

#======================================================================================================================
# §function     getHeaderText
# §state        protected
#======================================================================================================================
sub getHeaderText {
    my $self = shift;

    return '';
}

#======================================================================================================================
# §function     getHelpText
# §state        protected
#======================================================================================================================
sub getHelpText {
    my $self = shift;

    return "Type 'help' or '?' for help\n";
}

#======================================================================================================================
# §function     run
# §state        public
#======================================================================================================================
sub run {
    my $self = shift;

    $self->_begin();
    $self->_run();
    $self->_end();

    return;
}

#======================================================================================================================
# §function     _begin
# §state        private
#======================================================================================================================
sub _begin {
    my $self = shift;

    $self->_parseArguments();
    $self->_openConsole();
    $self->_loadCommands();
    $self->_printHeader();

#$self->getConsole()->dump($self->getParameters());
    return;
}

#======================================================================================================================
# §function     _parseArguments
# §state        private
#======================================================================================================================
sub _parseArguments {
    my $self = shift;

$self->help();
    my $Arguments = $self->getParameters();
    $Arguments->parseFromArray($self->{'Arguments'});
    if ($Arguments->getArguments()->{'Help'}) {
        $self->help();
    }

    return;
}

#======================================================================================================================
# §function     _openConsole
# §state        private
#======================================================================================================================
sub _openConsole {
    my $self = shift;

    $self->{'Console'} = $self->getConsoleManager()->getConsole({ type => 'terminal'});
    $self->getConsole()->open();

    return;
}

#======================================================================================================================
# §function     _loadCommands
# §state        private
#======================================================================================================================
sub _loadCommands {
    my $self = shift;

    $self->getCommandManager()->loadCommands($self->{'Commands'});

    return;
}

#======================================================================================================================
# §function     _printHeader
# §state        public
#======================================================================================================================
sub _printHeader {
    my $self = shift;

    if ($self->{'PrintHeader'}) {
        my $Console = $self->getConsole();
        $Console->reset();
        $Console->output(
            "\n%s\n%s%s\n",
            $self->{'Title'},
            $self->getHeaderText(),
            $self->getHelpText()
        );
    }
    
    return;
}

#======================================================================================================================
# §function     _run
# §state        protected
#======================================================================================================================
sub _run {
    my $self = shift;

    my $Configuration = $self->getConfiguration();
    my $Console = $self->getConsole();
    $self->{'Exit'} = 0;
    while (not $self->{'Exit'}) {
        my $UserInput = $Console->prompt("%s", $Configuration->getPropertyValue('prompt'));
        $UserInput =~ m/^\s*(\S*)\s*(.*)/;
        my $CommandName = $1;
        my $CommandArgs = $2;
        $Console->reset();
        $self->executeCommand($CommandName, $CommandArgs);
    }

    return;
}

#======================================================================================================================
# §function     _end
# §state        private
#======================================================================================================================
sub _end {
    my $self = shift;

    $self->getConsole()->close();

    return;
}

#======================================================================================================================
# §function     executeCommand
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Shell->executeCommand($CommandName, $CommandArgs);
#======================================================================================================================
sub executeCommand {
    my $self = shift;
    my ($CommandName, $CommandArgs) = @_;

    if (length($CommandName) && $CommandName !~ /^\s*#/) {
        my $Command = $self->getCommandManager()->getCommand(lc($CommandName));
        if (defined $Command) {
            eval { $Command->execute($CommandArgs); };
            if ( $@ ) {
                $self->error($@);
            }
        } else {
            $self->getConsole()->output(
                "ERROR: Unknown command '%s'.\n%s\n",
                $CommandName,
                $self->{'HelpTxt'}
            );
        }
    }

    return;
}

#======================================================================================================================
# §function     exit
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Shell->exit( $ShowByeText )
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $ShowByeText | TODO | boolean
#======================================================================================================================
sub exit {
    my $self = shift;
    my ($ShowByeText) = @_;
    
    if ($ShowByeText) {
        $self->getConsole()->output("\nExit shell. Bye !\n\n");
    }

    $self->{'Exit'} = 1;

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

    $self->getConsole()->error( @_ );

    return;
}

#======================================================================================================================
# §function     help
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Shell->help()
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
sub help {
    my ($self) = shift;

    print $self->{'Metadata'}->getHelper()->getHelp();
    exit(2);
}

1;
