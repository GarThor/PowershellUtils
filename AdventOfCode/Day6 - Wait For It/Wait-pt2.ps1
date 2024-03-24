[CmdletBinding()] 
param(
    [String]$TimeSheet = "input.txt"
)

if (-not ($TimeSheet | Test-Path)) {
    # file with path $path doesn't exist
    throw "Input: [$TimeSheet] Does not Exist!"
}

[string[]]$file = Get-Content $TimeSheet;

[uint64]$raceDuration = 0;
if ($file[0] -match "Time:\s+(?<Durations>[\d\s]+)")
{
    $raceDuration = $Matches.Durations.Replace(' ', '');
}
else
{
    throw "Line 0 of $TimeSheet wasn't a time input row."
}

[uint64]$raceDistanceRecord = 0;
if ($file[1] -match "Distance:\s+(?<Distance>[\d\s]+)")
{
    $raceDistanceRecord = $Matches.Distance.Replace(' ', '');
}
else
{
    throw "Line 1 of $TimeSheet wasn't a distance input row."
}

Write-Verbose "RaceDurations: $raceDuration"
Write-Verbose "RaceDistances: $raceDistanceRecord"

function Find-Button-Duration 
{ 
    [OutputType([uint64])]
    param([uint64]$Lower, [uint64]$Upper)

    if ($Lower -eq $Upper -or ($Lower + 1) -eq $Upper)
    {
        Write-Verbose "midpoint is betweeen $Lower & $Upper"
        return $Upper;
    }

    [uint64]$midpoint = (( $Upper - $Lower ) / 2 ) + $Lower;
    [uint64]$result = $midpoint * ($raceDuration - $midpoint);
    if ($result -lt $raceDistanceRecord)
    {
        # result is in the upper bounds
        return Find-Button-Duration -Lower $midpoint -Upper $Upper;
    }
    elseif ($result -eq $raceDistanceRecord) 
    {
        # result IS the race distance record
        Write-Verbose "midpoint equals record"
        return $midpoint;
    }
    else 
    {
        # result is in the lower bounds
        return Find-Button-Duration -Lower $Lower -Upper $midpoint;
    }
}

# the halfway mark will always be the max, because of how multiplication works!
[uint64]$halfWay = $raceDuration / 2;

[uint64]$recordHolderButtonDuration = Find-Button-Duration -Lower 0 -Upper $halfway;

Write-Host "Need to hold the button at least $recordHolderButtonDuration to produce desired result"

$maxForTheWin = $raceDuration - $recordHolderButtonDuration;
Write-Host "And at most $maxForTheWin to produce desired result"

$totalWaysToWin = $maxForTheWin - $recordHolderButtonDuration + 1;
Write-Host "Total possible ways to beat the record is $totalWaysToWin"


