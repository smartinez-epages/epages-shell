
ePages shell, Beta 2

Simple command-line tool to work with the epages objects.

This experimental tool aims to include in one shell all the operations you need to work with 
epages at low level: manage objects (create, read, update, delete) and more... 

epages already includes a lot of scripts to do almost everything, but it would be nice to 
have those utilities in one tool. 

INSTALL

    Simply set the execution rights to the launcher script
    
        # cd epages-shell
        # chmod 755 she    

USAGE

    she [ flags ] [ options ] [ StoreName [ ObjectPath ] ]
    she [ -prompt ] -batch BatchFile

    Flags (optional):
        -help           Shows this help
        -noheader       Don't print the starting help header
        -nopager        Disable pager
        -prompt         Enable print prompt in Batch mode 
        
    Options:
        -batch          Batch mode: execute specified text file (optional)

    Arguments:
        Storename       Connect to the StoreName (optional)
        ObjectPath      And select the object by path (optional)

    Examples:
        she 
        she Store /Shops/DemoShop
        she -nopager -noheader Site
        she -prompt -batch script.txt

RUN

    Try 
    
        # she --help
        
    for command-line options  
    
    Simple execution
    
        # she

    Or you can start she with arguments to connect a store:
        
        # she Store
    
        # she Store /Shops/DemoShop

BATCH MODE

  You can run she with a batch file, no user interaction !
  
  Try the sample batch file:
  
    # she sample.batch
    
FIRSTS STEPS

    0. List of available commands and help for a specific one:
        
        [she] help
        [she] ? set
        
    1. Connect to a Store or BusinessUnit (database):
    
        [she] use Store
        
    2. Browse the objects tree
    
        [she] cd /Shops/DemoShop
        [she] cd Users
        
    3. Information about the current object
    
        [she] status
        
    4. List the childs of the current object
     
        [she] ls
        
    5. List all the attributes of the current object
    
        [she] get
        
    6. Change the Birth date of a customer
     
        [she] cd /Shops/DemoShop/Customers/1000/BillingAddress
        [she] set Birthday='21/08/1989 09:30:00'

TO DO

  Uf !!! Lots of things ...

