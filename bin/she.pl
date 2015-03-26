#======================================================================================================================
# §package      she
#----------------------------------------------------------------------------------------------------------------------
# §description  ePages shell launcher
#======================================================================================================================
package she;

use strict;

use ePages::Shell;

use DE_EPAGES::Core::API::Script qw (
    RunScript
);

sub Main {

    my $shell = ePages::Shell->new({ 'Arguments' => \@ARGV });

    $shell->run();

    return;
}

RunScript( Sub => \&Main );

1;
