[CmdletBinding()] 
param(
    [String]$TimeSheet = "example.txt"
)

if (-not ($TimeSheet | Test-Path)) {
    # file with path $path doesn't exist
    throw "Input: [$TimeSheet] Does not Exist!"
}

[string[]]$file = Get-Content $TimeSheet;

[int[]]$raceDurations = @();
if ($file[0] -match "Time:\s+(?<Durations>[\d\s]+)")
{
    $raceDurations = $Matches.Durations.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries);
}
else
{
    throw "Line 0 of $TimeSheet wasn't a time input row."
}

[int[]]$raceDistanceRecords = @();
if ($file[1] -match "Distance:\s+(?<Durations>[\d\s]+)")
{
    $raceDistanceRecords = $Matches.Durations.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries);
}
else
{
    throw "Line 1 of $TimeSheet wasn't a distance input row."
}

Write-Verbose "RaceDurations: $raceDurations"
Write-Verbose "RaceDistances: $raceDistanceRecords"

if ($raceDurations.Count -ne $raceDistanceRecords.Count)
{
    throw "Counts aren't equal!"
}

[int]$totalMarginOfError = 1;
for ([int]$raceIndex = 0; $raceIndex -lt $raceDurations.Count; $raceIndex++)
{
    $duration = $raceDurations[$raceIndex];
    $record = $raceDistanceRecords[$raceIndex];
    Write-Host "Processing Race $raceIndex With $duration / $record"

    # brute force time!
    [int]$winCount = 0;
    for ([int]$guessIdx = 1; $guessIdx -lt $duration; $guessIdx++)
    {
        $result = $guessIdx * ($duration - $guessIdx);
        if ($result -gt $record)
        {
            $winCount++;
        }
    }
    Write-Host "$winCount ways to beat the record for race $raceIndex"

    $totalMarginOfError *= $winCount;
}

return $totalMarginOfError