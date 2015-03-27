#======================================================================================================================
# CommandHelper
#
#   TODO
#======================================================================================================================
package Shell::Command::CommandHelper;

use strict;

#======================================================================================================================
# §function     new
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       $CommandHelper->new($hAttributes)
#======================================================================================================================
sub new {
    my $Class = shift;
    my ($CommandMetadata) = @_ ;
    
    my $hAttributes = {
        'Metadata'      => $CommandMetadata,
        'Identation'    => '    ',
        'Help'          => undef
    } ;
    
    return bless($hAttributes, $Class);
}

#======================================================================================================================
# §function     update
# §state        public
#======================================================================================================================
sub update {
    my ($self) = shift;
print "HELPER UPDATE !!!\n";
    $self->{'Help'} = undef;
}

#======================================================================================================================
# §function     getHelp
# §state        public
#======================================================================================================================
sub getHelp {
    my ($self) = shift;

    my $Help = $self->{'Help'};
    if (not defined $Help) {
        $Help = $self->_getList('Header');
        $Help .= $self->_getList('Usage', 'Usage:', $self->{'Identation'});
        $Help .= $self->_getSection('Flags', 'Flags:', '-', $self->{'Identation'});
        $Help .= $self->_getSection('Options', 'Options:', '-', $self->{'Identation'});
        $Help .= $self->_getSection('Arguments', 'Arguments:', '', $self->{'Identation'});
        $Help .= $self->_getList('Examples', 'Examples:', $self->{'Identation'});
        $Help .= $self->_getList('Extra');
        $Help .= "\n";
        $self->{'Help'} = $Help;
    }

    return $Help;
}

#======================================================================================================================
# §function     _getList
# §state        private
#======================================================================================================================
sub _getList{
    my ($self) = shift;
    my ($ListName, $Title, $Identation) = @_;

    my $Help = '';
    
    my $Metadata = $self->{'Metadata'};
    my $List = $Metadata->getMetadata($ListName);
    if (defined $List) {
        $Help = "\n";
        if (defined $Title) {
            $Help .= "$Title\n";
        }
        my $Name = $Metadata->getMetadata('Name');
        if (ref($List) eq 'ARRAY') {
            foreach my $Line (@$List) {
                $Line =~ s/{{NAME}}/$Name/g;
                $Help .= "$Identation$Line\n";
            }
        } else {
            $List =~ s/{{NAME}}/$Name/g;
            $Help .= "$Identation$List\n";
        }
    }

    return $Help;
}

#======================================================================================================================
# §function     _getSection
# §state        private
#======================================================================================================================
sub _getSection{
    my ($self) = shift;
    my ($SectionName, $Title, $Prefix, $Identation) = @_;

    my $Help ='';
    
    my $Metadata = $self->{'Metadata'};
    my $aSection = $Metadata->getMetadata($SectionName);
    if (defined $aSection) {
        $Help = "\n";
        if (defined $Title) {
            $Help .= "$Title\n";
        }
        my $Name = $Metadata->getMetadata('Name');
        foreach my $Section (@$aSection) {
            my $Key = $Prefix.($Section->{'Key'} // $Section->{'Name'});
            my $Text = $Section->{'Text'};
            my $Optional = $Section->{'Optional'}? ' (Optional)' : '';
            $Help .= sprintf("$Identation%-20s%s%s\n", $Key, $Text, $Optional);
        }
    }
    
    return $Help;
}

1;
