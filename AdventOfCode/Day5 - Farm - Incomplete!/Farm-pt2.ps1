[CmdletBinding()] 
param(
    [String]$Almanac = "example.txt"
)

if (-not ($Almanac | Test-Path)) {
    # file with path $path doesn't exist
    throw "Almanac File: [$Almanac] Does not Exist!"
}

[string[]]$file = Get-Content $Almanac;

[uint64[]]$seeds = @();
if ($file[0] -match "seeds: (?<Seeds>[\d\s]*)")
{
    $seeds = [uint64[]]$Matches.Seeds.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries);
}
else 
{
    throw "File has no seeds! $($file[0])"
}

Class PathLink {
    [string]$Name; # For Debug Only
    [uint64]$Start;
    [uint64]$Length;

    PathLink([string]$Name, [uint64]$Start, [uint64]$Length)
    {
        $this.Name = $Name;
        $this.Start = $Start;
        $this.Length = $Length;
    }

    [uint64]GetEnd()
    {
        return $this.Start + $this.Length;
    }
}

Class AlmanacMapItem {
    [string]$Name; # For debugging purposes only
    [uint64]$Source;
    [uint64]$Dest;
    [uint64]$Length;

    AlmanacMapItem(
        [string]$Name,
        [uint64]$Source, 
        [uint64]$Dest, 
        [uint64]$Length)
    {
        $this.Name = $Name;
        $this.Source = $Source;
        $this.Dest = $Dest;
        $this.Length = $Length;
    }

    [uint64]GetSourceEnd()
    {
        return $this.Source + $this.Length;
    }

    [uint64]GetDestEnd()
    {
        return $this.Dest + $this.Length;
    }

    [bool]Contains([uint64]$Point)
    {
        return $Point -ge $this.Source -and $Point -lt ($this.Source + $this.Length);
    }

    [uint64]TranslatePoint([uint64]$Point)
    {
        if ($Point -ge $this.Source -and $Point -lt ($this.Source + $this.Length))
        {
            [uint64]$diff = $Point - $this.Source;

            $Point = $this.Dest + $diff;
        }

        return $Point;
    }

    [object]TranslatePath([PathLink]$Path)
    {
        $ThisLevel = New-Object System.Collections.ArrayList;
        $NextLevel = New-Object System.Collections.ArrayList;
        
        if ($this.Contains($Path.Start) -and $this.Contains($Path.GetEnd()))
        {
            # path is fully contained within this map range
            $path1 = [PathLink]::New($this.Name, $this.TranslatePoint($Path.Start), $Path.Length);
            $NextLevel.Add($path1) > $null;
        }
        elseif ($this.Contains($Path.Start) -and -not $this.Contains($Path.GetEnd()))
        {
            # path start is within almanac, but path end is off the end
            $path1 = [PathLink]::New(
                $this.Name, 
                $this.TranslatePoint($Path.Start), 
                $Path.Length - ($Path.GetEnd() - $this.GetSourceEnd()));
            $NextLevel.Add($path1) > $null;

            $path2 = [PathLink]::New(
                $Path.Name, 
                $this.GetSourceEnd(), 
                $Path.GetEnd() - $this.GetSourceEnd());
            $ThisLevel.Add($path2) > $null;
        }
        elseif (-not $this.Contains($Path.Start) -and $this.Contains($Path.GetEnd()))
        {
            #path start is before the almanac, but path end is within
            $path1 = [PathLink]::New(
                $Path.Name,
                $Path.Start,
                $this.Source - $Path.Start
            )
            $ThisLevel.Add($path1) > $null;

            $path2 = [PathLink]::New(
                $this.Name, 
                $this.Dest, 
                $Path.GetEnd() - $this.Start);
            $NextLevel.Add($path2) > $null;
        }
        else
        {
            #this is more complicated, the path either spans the almanac, comes before
            #   or comes after
            if ($Path.GetEnd() -lt $this.Start -or $Path.Start -lt $this.GetSourceEnd())
            {
                # Path comes either completely before or after Almanac
                $ThisLevel.Add($Path) > $null;
            }
            else 
            {
                # Path spans Almanac
                #path start is before the almanac, but path end is within
                $path1 = [PathLink]::New(
                    $Path.Name,
                    $Path.Start,
                    $this.Dest
                )
                $ThisLevel.Add($path1) > $null;

                $path2 = [PathLink]::New(
                    $this.Name, 
                    $this.Dest, 
                    $this.Length);
                $NextLevel.Add($path2) > $null;
                
                $path3 = [PathLink]::New(
                    $Path.Name,
                    $this.GetSourceEnd(),
                    $Path.GetEnd() - $this.GetSourceEnd()
                )
                $ThisLevel.Add($path3) > $null;
            }
        }
        $result = @{
            ThisLevel = $ThisLevel 
            NextLevel = $Nextlevel
        }
        return $result;
    }
}


$currentPaths = New-Object System.Collections.Queue;
$nextPaths = New-Object System.Collections.Queue;
$seedRangeCount = $seeds.Length / 2;
for ($seedRangeIdx = 0; $seedRangeIdx -lt $seedRangeCount; $seedRangeIdx++)
{
    [int]$arrayPos  = $seedRangeIdx * 2;
    [uint64]$start  = $seeds[$arrayPos];
    [uint64]$length = $seeds[$arrayPos + 1]

    $initialValue = [PathLink]::New("seed", [uint64]$start, [uint64]$length);
    
    $currentPaths.Enqueue($initialValue);
}

$maps = @{}
$currentMapName = "";
for ([int]$lineIdx = 2; $lineIdx -lt $file.Length; $lineIdx++)
{
    $line = $file[$lineIdx];
    switch -regex ($line)
    {
        "(?<MapName>[\w\-]+) map:"
        {
            # Start of a new map
            Write-Host "Processing Map: " $Matches.MapName
            $currentMapName = $Matches.MapName
            if (-not $maps[$currentMapName])
            {
                $maps[$currentMapName] = @()
            }
            else 
            {
                throw "Adding to existing map? $currentMapName";
            }
        }
        "(?<Dest>[\d]+) (?<Source>[\d]+) (?<Length>[\d]+)"
        {
            # Add this line to the current map
            [uint64]$source = $Matches.Source;
            [uint64]$dest = $Matches.Dest;
            [uint64]$length = $Matches.Length;
    
            Write-Verbose "    Dest: $dest Source: $source Length: $length";
            $newRange = [AlmanacMapItem]::New($currentMapName, $source, $dest, $length);
            $maps[$currentMapName] += $newRange;

            $pathsToProcess = $currentPaths.ToArray();
            foreach ($path in $pathsToProcess)
            {
                $resultPaths = $newRange.TranslatePath($path);
                foreach ($oldPath in $resultPaths.ThisLevel)
                {
                    $currentPaths.Enqueue($oldPath);
                }
                foreach ($newPath in $resultPaths.ThisLevel)
                {
                    $nextPaths.Enqueue($newPath);
                }
            }
        }
        "^$"
        {
            # Empty String (Handled Below)
        }
        default 
        {
            throw "Line Number $lineIdx did not match any available parameters: '$line'"
        }
    }
    
    if ($line.Length -eq 0 -or $lineIdx -eq ($file.Length - 1)) 
    {
        # end of map, move everything over to new paths
        Write-Host "End of map"

        foreach ($path in $currentPaths)
        {
            $path.Name = $currentMapName;
        }

        foreach ($path in $nextPaths)
        {
            $currentPaths.Enqueue($path);
        }

        $nextPaths.Clear();

    }
}

Write-Verbose "*** File Done, Finding closest location!"
[uint64]$smallestLocation = [uint64]::maxvalue;
foreach ($path in $paths)
{
    Write-Verbose ("*** Path")
    foreach ($element in $path.ToArray())
    {
        Write-Verbose "$($element.Name)  --> $($element.Start) - $($element.Start + $element.Length)"
    }
    $smallestLocation = [Math]::min($smallestLocation, $path.Peek().Start);
}

return $smallestLocation;