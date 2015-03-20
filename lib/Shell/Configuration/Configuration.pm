#======================================================================================================================
# §package      Shell::Configuration::Configuration
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#======================================================================================================================
package Shell::Configuration::Configuration;

use strict;

use Shell::Configuration::ConfigurationProperty;

#======================================================================================================================
# §function     new
# §state        public
#======================================================================================================================
sub new {
    my $class = shift;
    my ($aConfigProperties) = @_;

    my $hAttributes = {
        'Properties' => {},
    };
    my $self = bless($hAttributes, $class);
    $self->addProperties($aConfigProperties);

    return $self;
}

#======================================================================================================================
# §function     addProperties
# §state        public
#======================================================================================================================
sub addProperties {
    my $self = shift;
    my ($aConfigProperties) = @_;

    foreach my $hProperty (@$aConfigProperties) {
        $self->addProperty($hProperty);
    }

    return;
}

#======================================================================================================================
# §function     addProperty
# §state        public
#======================================================================================================================
sub addProperty {
    my $self = shift;
    my ($hPropertyInfo) = @_;

    if($hPropertyInfo) {
        my $Property = Shell::Configuration::ConfigurationProperty->new($hPropertyInfo);
        my $Properties = $self->getProperties();
        $Properties->{$Property->getName()} = $Property; 
    }
    
    return;
}

#======================================================================================================================
# §function     getProperties
# §state        public
#======================================================================================================================
sub getProperties {
    my $self = shift;

    return $self->{'Properties'};
}

#======================================================================================================================
# §function     getProperty
# §state        public
#======================================================================================================================
sub getProperty {
    my $self = shift;
    my ($PropertyName) = @_;

    return $self->getProperties()->{$PropertyName};
}

#======================================================================================================================
# §function     getPropertyValue
# §state        public
#======================================================================================================================
sub getPropertyValue {
    my $self = shift;
    my ($PropertyName) = @_;
    
    my $Property = $self->getProperty($PropertyName);
    return (defined $Property)? $Property->getValue() : undef;
}

#======================================================================================================================
# §function     setPropertyValue
# §state        public
#======================================================================================================================
sub setPropertyValue {
    my $self = shift;
    my ($PropertyName, $PropertyValue) = @_;
    
    my $Property = $self->getProperty($PropertyName);
    if (defined $Property) {
        return $Property->setValue($PropertyValue);
    };

    return undef;
}

1;
