package ePages::Attributes::Hash ;
use base ePages::Attributes::Base ;


use strict;

sub _get {
     my $self = shift;
 
    return '{...}';
}

1;
