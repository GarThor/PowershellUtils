$SearchTerms = 
		# @("Firefox",	"442", 			"Oldsmobile",	"Oldsmobile 442",	"Blue oldsmobile 442",
		  # "Opera",		"Mustang", 		"Ford",			"Ford Mustang",		"2016 Ford Mustang",
		  # "XMen",		"Wolverine",	"Avengers",		"Superman",			"Batman",
		  # "Cyclops",	"Jean Grey",	"Rogue",		"Mazda",			"Mazda 3",
		  # "Mazda 626",	"Mazda Miata",	"Mazda Rx8",	"Mazda Rx7",		"Mazda 3 Hatchback",
		  # "Gambit",		"Harison Ford",	"The Cap'n",	"Wookie",			"Scruffy Nerfherder")

Function Read-Dictionary {  
    <#  
    .Synopsis  
        Gets A random search term from the array.  
          
    .Description  
        Gets A random search term from the array.  
          
    .Notes  
        Author	: Garret B. Hoffman <garret.hoffman@hotmail.com>  
        Blog	:   
        Source  : ME!
		Version : 0.0 - 2015/11/12 - Initial release
        #Requires -Version 2.0  
          
    .Inputs  
        System.String  
          
    .Outputs  
        System.String  
          
    .Parameter FilePath  
        Specifies the path to the input file.  
          
    .Example  
        $MySearch = Get-SearchTerm 0  
        -----------  
        Description  
        Saves the content of the SearchTerms[0] in a string called $MySearch
          
    .Link  
        None suggestions for other functions.
    #>  
      
    [CmdletBinding()]  
    Param(  
        [ValidateNotNullOrEmpty()]  
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".txt")})]  
        #[Parameter(ValueFromPipeline=$True,Mandatory=$True)]  
        [string]$FilePath  = ".\ComicBookHeros.txt"
    )  
      
    Begin  
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"}  
          
    Process  
    {  
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Processing file: $Filepath"  
        
		$Dict = @()
		
        switch -regex -file $FilePath  
        {
            "(.*)" # Word
			{
				$Dict += $matches[1]
			}
		}

		Write-Verbose "$($MyInvocation.MyCommand.Name):: Finished Processing file: $FilePath"  
        Return $Dict  
    }  
          
    End  
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"}  
}

Function Get-SearchTerm {  
    <#  
    .Synopsis  
        Gets A random search term from the array.  
          
    .Description  
        Gets A random search term from the array.  
          
    .Notes  
        Author	: Garret B. Hoffman <garret.hoffman@hotmail.com>  
        Blog	:   
        Source  : ME!
		Version : 0.0 - 2015/11/12 - Initial release
        #Requires -Version 2.0  
          
    .Inputs  
        System.String  
          
    .Outputs  
        System.String  
          
    .Parameter FilePath  
        Specifies the path to the input file.  
          
    .Example  
        $MySearch = Get-SearchTerm 0  
        -----------  
        Description  
        Saves the content of the SearchTerms[0] in a string called $MySearch
          
    .Link  
        None suggestions for other functions.
    #>  
      
    [CmdletBinding()]  
    Param(  
		[parameter(Mandatory=$true, ValueFromPipeline=$true)]
		$Dict,
		
        [int]$SearchTermIndex  = -1
    )  
      
    Begin  
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"}  
          
    Process  
    {  
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Processing file: $Filepath"

		# if the SearchTermIndex is negative, randomize it.
		if ($SearchTermIndex -lt 0)
		{
			$SearchTermIndex = Get-Random 
			$SearchTermIndex = $SearchTermIndex % $Dict.Count
		}
		
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Finished Processing file: $FilePath"  
        
		Return $Dict[$SearchTermIndex]  
    }  
          
    End  
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"}  
}
		  
Export-ModuleMember Get-SearchTerm, Read-Dictionary