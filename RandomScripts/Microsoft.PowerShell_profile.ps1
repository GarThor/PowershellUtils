### Linux-ish
set-alias ifconfig	ipconfig
set-alias grep		MyGrep #select-string
set-alias wget		Invoke-WebRequest
set-alias open		ii

### Programs
$ProgramFiles = 'C:\Program Files\'
$ProgramFiles64 = 'C:\Program Files (x86)\'

$Steam	 = $ProgramFiles64 + 'Steam\Steam.exe'
$Pico 	 = $ProgramFiles64 + 'Notepad++\notepad++.exe'
$FireFox = $ProgramFiles64 + 'Mozilla Firefox\firefox.exe'
$Chrome  = $ProgramFiles64 + 'Google\Chrome\Application\chrome.exe'
$IE		 = $ProgramFiles64 + 'Internet Explorer\iexplore.exe'
$Python	 = 'C:\Python3_5\' + 'Python.exe'

set-alias steam		$Steam	 
set-alias pico 		$Pico 	 
set-alias firefox 	$FireFox 
set-alias chrome 	$Chrome  
set-alias IE		$IE		 
set-alias python	$Python	 

### AA Dirs/shortcuts:
$AAJR 			= 'D:\Projects_AA\UE3\Branches\AAJR\'
$AABin 			= $AAJR + 'Binaries\'
$AAGame 		= $AABin + 'Win32\AAGame.com'
$AALauncher 	= $AABin + 'Win32\AALauncher32.exe'
$AAGame64 		= $AABin + 'Win64\AAGame.com'
$AALauncher64 	= $AABin + 'Win64\AALauncher64.exe'
$AAGEditor   	= $AABin + 'Win32\AAGameEditor.exe'
$AAMEditor   	= $AABin + 'Win32\AAMissionEditor.exe'

set-alias AAGame		$AAGame
set-alias AALauncher	$AALauncher
set-alias AAGame64		$AAGame64
set-alias AALauncher64	$AALauncher64
set-alias AAGEditor     $AAGEditor
set-alias AAMEditor		$AAMEditor

### CMDLets

### Process-related functions:
function StartProcess
{
	[CmdletBinding()]
	Param
	(
	[string]$Process="notepad",
	$Count=10
	)
	for($i=0;$i -lt $Count;$i++)
	{
		&$Process
	}
}
function KillAll
{
	[CmdletBinding()]
	Param
	(
	[Parameter(
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$true)]
    [PSObject[]]
	$InputProcesses,
	[Parameter(
        Position=0, 
        Mandatory=$false, 
        ValueFromPipeline=$false)]
    $ProcessName,
	[switch]$WhatIf
	)
	
	Begin { }
    
	Process { 
		if ($InputProcesses -ne $Null)
		{
			[string]$Id = $InputProcesses.Id
			[string]$Name = $InputProcesses.Name 
			[string]$Priority = $InputProcesses.PriorityClass
			stop-process $InputProcesses -WhatIf:$WhatIf
		}
	}
	
	End {
		if ($ProcessName -ne $Null -and $ProcessName -ne "")
		{
			$process = get-process -name $ProcessName; 

			foreach ($p in $process) 
			{
				[string]$Id = $P.Id
				[string]$Name = $P.Name 
				[string]$Priority = $P.PriorityClass
				stop-process $p -WhatIf:$WhatIf
			}
		}
	}
}
function SetPriority
{
	[CmdletBinding()]
	Param
	(
	[Parameter(
        Position=10, 
        Mandatory=$false, 
        ValueFromPipeline=$true)]
    [PSObject[]]
	$InputProcesses,
	[Parameter(
        Position=0, 
        Mandatory=$false, 
        ValueFromPipeline=$false)]
    [string]$ProcessName,
	[Parameter(
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$false)]
	[string]$Priority='Realtime'#options are: Normal, Idle, High, RealTime, BelowNormal, AboveNormal
	)
	
	Begin { 
		$ProcessList = @();
		if ($ProcessName -ne $Null -and $ProcessName -ne "")
		{
			$ProcessList += get-process -name $ProcessName;
		}
		
		$ValidPriority = 'Normal','Idle','High','RealTime','BelowNormal','AboveNormal'	

		if ( $ValidPriority -NotContains $Priority )
		{
			write-error "-Priority flag must be one of: Idle, BelowNormal, Normal, AboveNormal, High, RealTime"
		}
		$MPriority = $Priority
	}
    
	Process { 
		if ($InputProcesses -ne $null)
		{
			$ProcessList += $InputProcesses
			
			[string]$Id = $P.Id
			[string]$Name = $P.Name 
			[string]$Priority = $P.PriorityClass
			write-verbose "SetPriority: $Id $Name = $Priority"
		}
	}
	
	End { 
		foreach ($p in $ProcessList)
		{ 
			$p.PriorityClass = $MPriority 
			$ProcessList += $p
			
			[string]$Id = $P.Id
			[string]$Name = $P.Name 
			[string]$Priority = $P.PriorityClass
			write-verbose "SetPriority: $Id $Name = $Priority"
		}

		return $ProcessList 
	}
}
function GetPriority
{
	[CmdletBinding()]
	Param
	(
	[Parameter(
        Position=1, 
        Mandatory=$false, 
        ValueFromPipeline=$true)]
    [PSObject[]]
	$InputProcesses,
	[Parameter(
        Position=0, 
        Mandatory=$false, 
        ValueFromPipeline=$false)]
    $ProcessName
	)
	
	Begin { $ProcessList = @() }
    
	Process { 
		if ($InputProcesses -ne $null)
		{
			$ProcessList += $InputProcesses
			
			[string]$Id = $P.Id
			[string]$Name = $P.Name 
			[string]$Priority = $P.PriorityClass
			write-verbose "GetPriority: $Id $Name = $Priority"
		}
	}
	
	End {
		if ($ProcessName -ne $Null -and $ProcessName -ne "")
		{
			write-verbose "GetPriority: Adding processes with Name $ProcessName"
			$process = get-process -name $ProcessName; 

			foreach ($p in $process) 
			{
				[string]$Id = $P.Id
				[string]$Name = $P.Name 
				[string]$Priority = $P.PriorityClass
				write-verbose "GetPriority: $Id $Name = $Priority"
				
				if (($ProcessList | Where-Object {$_.Id -eq $p.Id}) -ne $Null)
				{
					write-verbose "GetPriority: process was already contained in input.. Updating current priority"
					($ProcessList | Where-Object {$_.Id -eq $p.Id}).PriorityClass = $p.PriorityClass
				}
				else
				{
					$ProcessList += @($p)
				}
			}
		}
	
		return $ProcessList | format-table Id,Name,PriorityClass,BasePriority -AutoSize
	}
}
function SleepyTime
{
	Param
	(
		[Parameter(Mandatory=$True)]
		$SleepTime,
		[switch]$CountSeconds,
		[switch]$CountMinutes
	)
	
	if (-not $CountSeconds -and -not $CountMinutes)
	{
		write-verbose "Sleeping $SleepTime"
		sleep $SleepTime
		write-verbose "Done Sleeping"
	}
	else
	{
		function CountSleepSeconds
		{
			Param
			(
				[Parameter(Mandatory=$True)]
				$From,
				[Parameter(Mandatory=$False)]
				$To = 0
			)
			write-verbose "Sleeping: $SleepTime seconds"
			$Time = $From
			
			while($Time -gt $To)
			{
				write-host "Seconds Left: $Time"
				sleep 1
				$Time = $Time - 1
			}
		}

		if ($CountSeconds -and -not $CountMinutes)
		{
			CountSleepSeconds $SleepTime
		}
		if ($CountMinutes)
		{
			$Time = $SleepTime
			$Minutes = [math]::floor($Time / 60)
			$Seconds = $Time % 60
			write-verbose "Sleeping: $Minutes minutes and $Seconds Seconds"

			while($Time -gt 0)
			{
				if ($Minutes -lt 1)
				{
					if ($CountSeconds)
					{
						CountSleepSeconds $Time
					}
					else
					{
						write-host "Seconds left: $Time"
						sleep $Time
					}
				}
				else
				{
					write-host "Minutes left: $Minutes"
					
					if ($CountSeconds)
					{
						CountSleepSeconds $Time ($Time-60)
					}
					else
					{
						sleep 60
					}
				}

				$Time = $Time - 60
				$Minutes = $Time / 60
			}
		}
	}
}

function WatchdogProcess
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$True)]
		[string]$Executable="",
		[Parameter(Mandatory=$True)]
		[string]$ProcessName="",
		[Parameter(Mandatory=$false)][Alias('S','ST')]
		$SleepTime=1200, # 20 minutes
		[parameter(mandatory=$false)][Alias('W','WT')]
		$WaitTime=30, # 30 seconds
		[Alias('C','CT')]
		[switch]$CountTime,
		[Alias('CS')]
		[switch]$CountSeconds,
		[Alias('CM')]
		[switch]$CountMinutes,
		[Alias('Kill','K')]
		[switch]$KillIfNotRunning
	)

	if ($CountTime)
	{
		$CountSeconds = $True
		$CountMinutes = $True
	}

	while(1)
	{
		$TheProcess = get-process -name $processname -erroraction silentlycontinue
		
		if ($KillIfNotRunning -and $TheProcess -ne $null)
		{
			write-host "killing process $processname"
			stop-process -Name $processname -Force
			sleep 1
			wait-process -Timeout $WaitTime -name $processname -erroraction silentlycontinue
			$TheProcess = get-process -name $processname -erroraction silentlycontinue
			
			if ($TheProcess -ne $null)
			{
				write-error "Waited $WaitTime seconds, and $ProcessName didn't exit!"
				return $null;
			}
		}

		if ($TheProcess -eq $null)
		{
			write-host "starting process $executable"
			&$executable
		}

		SleepyTime $sleeptime -CountSeconds:$CountSeconds -CountMinutes:$CountMinutes
	}
}

### Set/Reset the colors of the terminal
$DefaultForeground = (Get-Host).UI.RawUI.ForegroundColor
$DefaultBackground = (Get-Host).UI.RawUI.BackgroundColor
function SetColors
{
	Param
	(
		[string]$Foreground = "",
		[string]$Background = ""
	)

	$ValidColors = "black","blue","cyan","darkblue"	,"darkcyan","darkgray",
		"darkgreen","darkmagenta","darkred","darkyellow","gray","green",
		"magenta","red","white","yellow";
	
	$Foreground = $Foreground.ToLower()
	$Background = $Background.ToLower()
	
	if ( $Foreground -eq "" )
	{
		$Foreground = $DefaultForeground
	}
	if ( $Background -eq "" )
	{
		$Background = $DefaultBackground
	}
	
	if ( $ValidColors -contains $Foreground -and
		 $ValidColors -contains $Background )
	{
		$a = (Get-Host).UI.RawUI
		$a.ForegroundColor = $Foreground
		$a.BackgroundColor = $Background
	}
	else 
	{
		write-host "Foreground/Background Colors must be one of the following:"
		$ValidColors 
	}
}
set-alias set-colors SetColors

### Similar to linux "Grep" function
function MyGrep
{
  param(  
	[string]$FindString = "",
	[string]$Color = "",
	[string]$Background = "",
	[string]$ColorNoMatch = "",
	[string]$BackgroundNoMatch = "",
	[switch]$CaseSensitive,
	[switch]$PrintAllLines,
	[Alias('I')]
	[switch]$PrintLineNumbers
	)
	
	$ValidColors = "black","blue","cyan","darkblue"	,"darkcyan","darkgray",
		"darkgreen","darkmagenta","darkred","darkyellow","gray","green",
		"magenta","red","white","yellow"
		
	$Color 				= $Color.tolower();
	$Background 		= $Background.tolower();
	$ColorNoMatch 		= $ColorNoMatch.tolower();
	$BackgroundNoMatch  = $BackgroundNoMatch.tolower();
	
	if ($Color 				-eq ""){$Color				= "red"}
	if ($Background 		-eq ""){$Background 		= $DefaultBackground}
	if ($ColorNoMatch 		-eq ""){$ColorNoMatch 		= $DefaultForeground}
	if ($BackgroundNoMatch  -eq ""){$BackgroundNoMatch  = $DefaultBackground}
	
	if ( $ValidColors -NotContains $Color -or 
		 $ValidColors -NotContains $Background -or
		 $ValidColors -NotContains $ColorNoMatch -or 
		 $ValidColors -NotContains $BackgroundNoMatch )
	{
		write-host "Foreground/Background Colors must be one of the following:"
		$ValidColors
		return -1;
	}
	
	if ( $FindString -eq "" )
	{
		write-host "Please enter a valid search parameter [-FindString]"
		return -1
	}

	$endoflinechar = "`n"
	
	$Str = $input | out-string
	
	$StrList = $Str.Split($endoflinechar)
	
	$LineIdx = 0
	
	foreach ( $line in $StrList )
	{
		if ($line.CompareTo("") -ne 0)
		{
			$line = $line.TrimEnd("`r`n`t ")
			$Temp = $line
			$TempFind = $FindString
			if (!$CaseSensitive)
			{
				$Temp = $Temp.ToLower()
				$FindString = $FindString.ToLower()
			}
			
			$PrintedLine = 0
			$IndexOf = $Temp.IndexOf($TempFind)
			
			if ($IndexOf -ne -1 -and $PrintLineNumbers)
			{
				write-host -NoNewline $LineIdx":" -foregroundcolor $ColorNoMatch -backgroundcolor $Background
			}

			while( $IndexOf -ne -1 )
			{
				$PrintedLine = 1
				
				write-host -NoNewline $line.Substring(0, $IndexOf) 				  -foregroundcolor $ColorNoMatch -backgroundcolor $Background
				write-host -NoNewline $line.Substring($IndexOf, $TempFind.Length) -foregroundcolor $Color 		 -backgroundcolor $Background
				
				$Temp = $line.Substring($IndexOf+$TempFind.Length)
				$line = $line.Substring($IndexOf+$TempFind.Length)
				
				$IndexOf = $Temp.IndexOf($TempFind)

				if ($IndexOf -eq -1)
				{
					write-host $line -foregroundcolor $ColorNoMatch -backgroundcolor $Background
				}
			}
			
			if ($PrintAllLines -And (-Not $PrintedLine) -And $line -ne "")
			{
				if ($PrintLineNumbers)
				{
					write-host -NoNewline $LineIdx":" -foregroundcolor $ColorNoMatch -backgroundcolor $BackgroundNoMatch
				}
				write-host "$line" -foregroundcolor $ColorNoMatch -backgroundcolor $BackgroundNoMatch
			}
		}
		
		$LineIdx++
	}
	
	write-host ""
}


#### AA-related build functions
function AALauncher_HAS
{
	&AALauncher /ds
}

function aa_make_full
{
	&aagame make -full
}
function aa_make
{
	&aagame make
}
function aa_server
{
	&aagame server bdx_breach_ex -lan
}

### crypto-algs
function MD5SUM
{
	param
	(
		[string]$File
	)
	
	$algo = [System.Security.Cryptography.HashAlgorithm]::Create("MD5")
	$stream = New-Object System.IO.FileStream($File, [System.IO.FileMode]::Open)
	
	$md5StringBuilder = New-Object System.Text.StringBuilder
	$algo.ComputeHash($stream) | % { [void] $md5StringBuilder.Append($_.ToString("x2")) }
	$md5StringBuilder.ToString()

	$stream.Dispose()
}

function SHA1SUM
{
	param
	(
		[string]$File
	)
	
	$algo = [System.Security.Cryptography.HashAlgorithm]::Create("SHA1")
	$stream = New-Object System.IO.FileStream($File, [System.IO.FileMode]::Open)
	
	$SHA1StringBuilder = New-Object System.Text.StringBuilder
	$algo.ComputeHash($stream) | % { [void] $SHA1StringBuilder.Append($_.ToString("x2")) }
	$SHA1StringBuilder.ToString()

	$stream.Dispose()
}

### Perforce syncing
function Get-Latest-Recursive
{
	$List = Get-ChildItem -r -Include *.* -Name
	
	for($FileIndex=0; $FileIndex -le $List.length; $FileIndex++)
	{
		echo $List[$FileIndex];
		p4 -s sync -s $List[$FileIndex];
	}
}

function Get-Latest-Multithreaded
{
	Param
	(
		[Switch]$Force,
		[Switch]$Recursive
	)
	
	$List = {}
	if ($Recursive)
	{
		$List = Get-ChildItem -r -Include *.* -Name;
		$ListIndex = 0;
	}
	else
	{
		$List = Get-ChildItem -Include *.* -Name;
		$ListIndex = 0;
	}
	
	$TotalJobs = 20;
	$JobQueue = New-Object System.Collections.Queue
	
	$Pwd = (pwd).Path

	$ScriptBlock = {echo "noscript";}
	
	if ($Force)
	{
		$ScriptBlock = 
		{
			param($Item);
			write-host $Item;
			p4 -s sync -f $Item;
		}
	}
	else
	{
		$ScriptBlock = 
		{
			param($Item);
			write-host $Item;
			p4 -s sync $Item;
		}
	}
	
	do 
	{
		if ($JobQueue.Count -le $TotalJobs)
		{
			$Item = $Pwd + "\" + $List[$ListIndex]

			$NewJob = Start-Job $ScriptBlock -ArgumentList $Item;
			$ListIndex++;
			$JobQueue.Enqueue($NewJob.Id);
		}
		else
		{
			for($JobIndex = 0; $JobIndex -le $TotalJobs; $JobIndex++)
			{
				$JobID = $JobQueue.Dequeue();
				
				$Job = Get-Job -Id $JobID
				
				if ($Job -and $Job.State -eq "Completed")
				{
					$Job | Receive-Job;
					Remove-Job -Id $JobID;
				}
				else
				{
					$JobQueue.Enqueue($JobID);
				}
			}
		}
		
	} while ($ListIndex -le $List.length)
}

### Browser-related functions:
function search
{
	Param
	(
		[string]$browser
	)
	foreach ($i in $args)
	{
		&$browser "https://www.bing.com/search?q=$i"
	}
}

function set-uas
{
	Param
	(
			[string]$UAS = "Default"
	)
	
	$FirefoxPrefs = "C:\Users\Admin\AppData\Roaming\Mozilla\Firefox\Profiles\*.default\prefs.js"
	
	if ($UAS -eq "Default")
	{
		$fileinfo = type $FirefoxPrefs
		$fileinfo = $fileinfo | findstr /v "general.appname.override" 	 
		$fileinfo = $fileinfo | findstr /v "general.appversion.override"
		$fileinfo = $fileinfo | findstr /v "general.platform.override"  
		$fileinfo = $fileinfo | findstr /v "general.useragent.appName"  
		$fileinfo = $fileinfo | findstr /v "general.useragent.override" 
		$fileinfo = $fileinfo | findstr /v "general.useragent.vendor"   
		$fileinfo = $fileinfo | findstr /v "general.useragent.vendorSub"
		$fileinfo += "user_pref(`"useragentswitcher.import.overwrite`", false);`n"
		$fileinfo += "user_pref(`"useragentswitcher.menu.hide`", false);`n"
		$fileinfo += "user_pref(`"useragentswitcher.reset.onclose`", false);`n"
		$fileinfo | Out-File -FilePath $FirefoxPrefs -Encoding ASCII
	}
	else
	{
		set-uas Default
	}
	
	if ($UAS -eq "iphone")
	{
		$fileinfo = ""
		$fileinfo += "user_pref(`"general.appname.override`", `"Netscape`");`n"
		$fileinfo += "user_pref(`"general.appversion.override`", `"5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16`");`n"
		$fileinfo += "user_pref(`"general.platform.override`", `"iPhone`");`n"																																		
		$fileinfo += "user_pref(`"general.useragent.appName`", `"Mozilla`");`n"																																		
		$fileinfo += "user_pref(`"general.useragent.override`", `"Mozilla/5.0 (iPhone; U; CPU iPhone OS 3_0 like Mac OS X; en-us) AppleWebKit/528.18 (KHTML, like Gecko) Version/4.0 Mobile/7A341 Safari/528.16`");`n"
		$fileinfo += "user_pref(`"general.useragent.vendor`", `"Apple Computer, Inc.`");`n"																															
		$fileinfo += "user_pref(`"general.useragent.vendorSub`", `"`");`n"																																			
		$fileinfo += "user_pref(`"useragentswitcher.reset.onclose`", false);`n"
		$fileinfo | Out-File -FilePath $FirefoxPrefs -Encoding ASCII -Append
	}
	elseif ($UAS -eq "lumia")
	{
		$fileinfo = ""
		$fileinfo += "user_pref(`"general.appname.override`", `"Netscape`");`n"
		$fileinfo += "user_pref(`"general.appversion.override`", `"9.80 (Windows Phone; Opera Mini/9.0.0/37.6652; U; en) Presto/2.12.423 Version/12.16`");`n"
		$fileinfo += "user_pref(`"general.platform.override`", `"Nokia`");`n"																																		
		$fileinfo += "user_pref(`"general.useragent.appName`", `"Mozilla`");`n"																																		
		$fileinfo += "user_pref(`"general.useragent.override`", `"Opera/9.80 (Windows Phone; Opera Mini/9.0.0/37.6652; U; en) Presto/2.12.423 Version/12.16`");`n"
		$fileinfo += "user_pref(`"general.useragent.vendor`", `"Microsoft`");`n"																															
		$fileinfo += "user_pref(`"general.useragent.vendorSub`", `"`");`n"																																			
		$fileinfo += "user_pref(`"useragentswitcher.reset.onclose`", false);`n"
		$fileinfo | Out-File -FilePath $FirefoxPrefs -Encoding ASCII -Append
	}
}

### Perform a number of searches in the selected browser to get bing rewards points
# function  getpoints
# {
	# Param
	# (
		# [string]$browser,
		# [string]$howmany
	# )
	
	# $Mod = Import-Module C:\Users\Admin\Documents\WindowsPowerShell\SearchTerms.psm1
	
	# $Dictionary = Read-Dictionary "C:\Users\Admin\Documents\WindowsPowerShell\ComicBookHeros.txt"

	# for ($i = 0; $i -lt $howmany; $i++)
	# {
		# $SearchTerm = Get-SearchTerm $Dictionary -1
		# search $browser $SearchTerm
		# #echo $SearchTerm
		# sleep(1)
	# };
# }
