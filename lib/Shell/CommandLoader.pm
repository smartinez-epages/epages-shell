#======================================================================================================================
# CommandLoader
#======================================================================================================================
package Shell::CommandLoader ;
use strict;

#======================================================================================================================
# §function     new
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       CommandLoader->new( $Shell );
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $Name | Description | type
#----------------------------------------------------------------------------------------------------------------------
# §return       $Name | Description | type
#======================================================================================================================
sub new {
    my $Class = shift;

    my ( $Shell ) = @_ ;
    
    my $MyRelativePath = __PACKAGE__ ;
    $MyRelativePath =~ s/::/\//g ;
    $MyRelativePath .= '.pm' ;
     
    my $ModulesBasePath = __FILE__ ;
    $ModulesBasePath =~ s/$MyRelativePath//g ;

    my $hAttributes = {
        'Shell'     => $Shell,
        'BasePath'  => $ModulesBasePath 
    } ;
    
    return bless( $hAttributes, $Class );
}

#======================================================================================================================
# §function     loadCommand
# §state        public
#----------------------------------------------------------------------------------------------------------------------
# §syntax       pending
# §example      pending
#----------------------------------------------------------------------------------------------------------------------
# §description  TODO
#----------------------------------------------------------------------------------------------------------------------
# §input        $CommandModule | Description | string
#----------------------------------------------------------------------------------------------------------------------
# §return       $Command | Loads dynamically a command object by its ModuleName | object
#======================================================================================================================
sub loadCommand {
    my $self = shift;

    my ( $CommandModule, $CommandOptions ) = @_ ;

    my $Shell = $self->{'Shell'} ;
    my $Console = $Shell->getConsole() ;
    
    my $CommandModulePath = $self->{'BasePath'}.$CommandModule.'.pm' ;
    $CommandModule =~ s/\//::/g ;
     
    if ( -f $CommandModulePath ) {
        $Console->debug( "Loading module %s...\n", $CommandModulePath ) ;
        require $CommandModulePath ;
        $Console->debug( "Creating command %s...\n", $CommandModule ) ;
        return $CommandModule->new( $Shell, $CommandOptions ) ;
    } else {
        $Console->output( "ERROR: Module '%s' not found !!!\n", $CommandModule ) ;
    }
    
    return undef ;
}


1;
