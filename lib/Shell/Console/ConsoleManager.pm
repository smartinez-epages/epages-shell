#======================================================================================================================
# §package      Shell::Console::ConsoleManager
#======================================================================================================================
package Shell::Console::ConsoleManager;

use strict;

use Module::Load;

my $hConsoleModules = {
    'terminal'  => 'Shell::Console::TerminalConsole',
    'batch'     => 'Shell::Console::BatchConsole'
};

#======================================================================================================================
# §function     new
# §state        public
#======================================================================================================================
sub new {
    my $class = shift;
    my ($Shell) = @_;

    my $hAttributes = {
        'Shell'         => $Shell,  # Reference to Shell object parent
        'Consoles'      => {}       # Pool of consoles
    };

    return bless($hAttributes, $class);
}

#======================================================================================================================
# §function     getConsole
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Console = $ConsoleManager->getConsole($hOptions);
#======================================================================================================================
sub getConsole {
    my ($self) = shift;
    my ($hOptions) = @_;

    my $ConsoleType = $hOptions->{'type'} // 'terminal';
    my $ConsoleName = $hOptions->{'name'} // $ConsoleType;
    my $Consoles = $self->{'Consoles'};
    my $Console = $Consoles->{$ConsoleName};
    if (not defined $Console) {
        $Console = $self->_loadConsole($ConsoleName, $ConsoleType, $hOptions);
    }

    return $Console;
}

#======================================================================================================================
# §function     _loadConsole
# §state        private
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $Console = $ConsoleManager->_loadConsole($ConsoleName, $ConsoleType, $hOptions);
#======================================================================================================================
sub _loadConsole {
    my ($self) = shift;
    my ($ConsoleName, $ConsoleType, $hOptions) = @_;

    my $Console = undef;
    my $ConsoleModulePath = $hConsoleModules->{$ConsoleType};
    if (defined $ConsoleModulePath) {
        eval {
            load $ConsoleModulePath;
            $Console = $ConsoleModulePath->new({
                'Shell' => $self->{'Shell'},
                'Name'  => $ConsoleName,
                %$hOptions
            });
            $self->{'Consoles'}->{$ConsoleName} = $Console;
        };
        if ($@) {
            die("EXCEPTION: Unable to load Console module > $@");
        }
    } else {
        die("EXCEPTION: Console type '$ConsoleType' doesn't exist");
    } 

    return $Console;
}

1;
