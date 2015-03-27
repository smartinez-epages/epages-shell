#======================================================================================================================
# CommandMetadata
#
#   TODO
#======================================================================================================================
package Shell::Command::CommandMetadata;

use strict;

use Shell::Command::CommandParameters; 
use Shell::Command::CommandHelper; 

#======================================================================================================================
# §function     new
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $CommandMetadata->new($hAttributes)
#======================================================================================================================
sub new {
    my $Class = shift;
    my ($Owner) = @_ ;
    
    my $hAttributes = {
        'Owner'         => $Owner,
        'Metadata'      => $Owner->getMetadata(),
        'Helper'        => undef, 
        'Parameters'    => undef
    } ;
    
    my $self = bless($hAttributes, $Class);

    $self->{'Helper'} = Shell::Command::CommandHelper->new($self);
    $self->{'Parameters'} = Shell::Command::CommandParameters->new($self);
    
    return $self;
}

#======================================================================================================================
# §function     getHelper
# §state        public
#======================================================================================================================
sub getHelper {
    my ($self) = shift;

    return $self->{'Helper'};
}

#======================================================================================================================
# §function     getParameters
# §state        public
#======================================================================================================================
sub getParameters {
    my ($self) = shift;

    return $self->{'Parameters'};
}

#======================================================================================================================
# §function     getAllMetadata
# §state        public
#======================================================================================================================
sub getAllMetadata {
    my ($self) = shift;

    return $self->{'Metadata'};
}

#======================================================================================================================
# §function     getMetadata
# §state        public
#======================================================================================================================
sub getMetadata {
    my ($self) = shift;
    my ($Name) = @_;

    return $self->{'Metadata'}->{$Name};
}

#======================================================================================================================
# §function     addMetadata
# §state        public
#======================================================================================================================
sub addMetadata {
    my ($self) = shift;
    my ($Name, $NewData) = @_;

    my $Metadata = $self->getAllMetadata();
    my $OldData = $Metadata->{$Name};
    if (defined $OldData) {
        if (ref($OldData) eq 'ARRAY') {
            if (ref($NewData) eq 'ARRAY') {
                $Metadata->{$Name} = [ @$OldData, @$NewData ];
            } else {
                $Metadata->{$Name} = [ @$OldData, $NewData ];
            }
        } else {
            if (ref($NewData) eq 'ARRAY') {
                $Metadata->{$Name} = [ $OldData, @$NewData ];
            } else {
                $Metadata->{$Name} = [ $OldData, $NewData ];
            }
        }
    } else {
        $Metadata->{$Name} = $NewData;
    }
    
    $self->getHelper()->update();
    $self->getParameters()->update();

    return;
}

1;
