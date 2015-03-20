#======================================================================================================================
# §package      Shell::Configuration::ConfigurationProperty
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
package Shell::Configuration::ConfigurationProperty;

use strict;

#======================================================================================================================
# §function     new
# §state        public
#======================================================================================================================
sub new {
    my $class = shift;
    my ($hOptions) = @_;

    my $hAttributes = {
        'Listeners' => [],
    } ;
    
    return bless( { %$hAttributes, %$hOptions }, $class );
}

#======================================================================================================================
# §function     getDescription
# §state        public
#======================================================================================================================
sub getDescription {
    my $self = shift;

    return $self->{'Description'} ;
}

#======================================================================================================================
# §function     getName
# §state        public
#======================================================================================================================
sub getName {
    my $self = shift;

    return $self->{'Name'} ;
}

#======================================================================================================================
# §function     getValue
# §state        public
#======================================================================================================================
sub getValue {
    my $self = shift;

    return $self->{'Value'} ;
}

#======================================================================================================================
# §function     setValue
# §state        public
#======================================================================================================================
sub setValue {
    my $self = shift;
    my ($Value) = @_;
    
    if ($self->_checkValue($Value)) {
        $self->{'Value'} = $self->_filterValue($Value);
        $self->_notifyListeners();
    } else {
        die "Try to assign invalid value to configuration property: ".$self->{'Name'};
    }
        
    return $self->{'Value'};
}

#======================================================================================================================
# §function     _filterValue
# §state        private
#======================================================================================================================
sub _filterValue {
    my $self = shift;
    my ($Value) = @_;
    
    my $Filter = $self->{'Filter'};
    return (defined $Filter)? $Filter->($Value) : $Value;
}

#======================================================================================================================
# §function     _checkValue
# §state        private
#======================================================================================================================
sub _checkValue {
    my $self = shift;
    my ($Value) = @_;
    
    my $Validator = $self->{'Validator'};
    return (defined $Validator)? $Validator->($Value) : 1;
}

#======================================================================================================================
# §function     addListener
# §state        public
#======================================================================================================================
sub addListener {
    my $self = shift;
    my ($ListenerToAdd) = @_;
    
    if (defined $ListenerToAdd and $ListenerToAdd->can('notifyConfigChange')) {
        my $Listeners = $self->{'Listeners'};
        foreach my $Listener (@$Listeners) {
            if ($Listener == $ListenerToAdd) {
                return;
            }
        }
        push(@$Listeners, $ListenerToAdd);
    }

    return;
}

#======================================================================================================================
# §function     delListener
# §state        public
#======================================================================================================================
sub delListener {
    my $self = shift;
    my ($ListenerToRemove) = @_;

    if (defined $ListenerToRemove) {
        my $Listeners = $self->{'Listeners'};
        foreach my $index (@$Listeners) {
            if ($Listeners->[$index] == $ListenerToRemove) {
                delete($Listeners->[$index]);
                return;
            }
        }
    }

    return;
}

#======================================================================================================================
# §function     _notifyListeners
# §state        public
#======================================================================================================================
sub _notifyListeners {
    my $self = shift;

    my $Listeners = $self->{'Listeners'};
    if ((scalar @$Listeners) > 0) {
        my $PropName = $self->{'Name'}; 
        my $PropValue = $self->{'Value'}; 
        foreach my $Listener (@$Listeners) {
            $Listener->notifyConfigChange($PropName, $PropValue);
        }
    }

    return;
}

1;
