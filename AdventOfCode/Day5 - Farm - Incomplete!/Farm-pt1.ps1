[CmdletBinding()] 
param(
    [String]$Almanac = "example.txt"
)

if (-not ($Almanac | Test-Path)) {
    # file with path $path doesn't exist
    throw "Input: [$Almanac] Does not Exist!"
}

[string[]]$file = Get-Content $Almanac;

[int[]]$seeds;
if ($file[0] -match "seeds: (?<Seeds>[\d\s]*)")
{
    $seeds = $Matches.Seeds.Trim().Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries);
}
else 
{
    throw "File has no seeds! $($file[0])"
}

$transition = @{};
foreach ($seed in $seeds)
{
    $transition[$seed] = @($seed)
}

$maps = @{}
$currentMapName = "";
for ([int]$lineIdx = 2; $lineIdx -lt $file.Length; $lineIdx++)
{
    $line = $file[$lineIdx];
    if ($line -match "(?<MapName>[\w\-]+) map:")
    {
        # Start of a new map
        Write-Host "Start of " $Matches.MapName
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
    elseif ($line -match "(?<Dest>[\d]+) (?<Source>[\d]+) (?<Length>[\d]+)")
    {
        # Add this line to the current map
        [int]$source = $Matches.Source;
        [int]$dest = $Matches.Dest;
        [int]$length = $Matches.Length;

        Write-Host "    Dest: " $Matches.Dest "Source: " $Matches.Source "    Length: " $Matches.Length;
        $obj = @{
            Src = $source
            Dest = $dest
            Len  = $length
        }
        $maps[$currentMapName]  += $obj;
    }
    elseif ($line.Length -eq 0) 
    {
        # end of map, do some procesing
        Write-Host "End of map"

        $currentMap = $maps[$currentMapName];

        for ([int]$i = 0; $i -lt $seeds.Length; $i++)
        {
            $seed = $seeds[$i]
            $obj = $currentMap | Where-Object {
                [int]$start = $_.Src;
                [int]$end = $_.Src + $_.Len;
                return [int]$seed -ge [int]$start -and [int]$seed -lt [int]$end;
            };
            if ($obj)
            {
                Write-Host "Modifying $seed to $($obj.Dst)"
                [int]$last = $transition[$seed][-1];
                [int]$diff = [int]$last - [int]$obj.Src;
                [int]$next = [int]$obj.Dest + [int]$diff
                $transition[$seed] += $next;
            }
            else
            {
                Write-Host "$seed not found, keeping value"
            }

        }
    }
    else 
    {
        throw "[$line] did not match any available parameters"
    }
}


return $transition;