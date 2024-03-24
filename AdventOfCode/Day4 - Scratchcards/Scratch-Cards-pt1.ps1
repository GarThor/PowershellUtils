[CmdletBinding()] 
param(
    [String]$Scratchers = "example.txt"
)

if (-not ($Scratchers | Test-Path)) {
    # file with path $path doesn't exist
    throw "Input: [$Scratchers] Does not Exist!"
}

[int]$runningTotal = 0;

[string[]]$file = Get-Content $Scratchers;

foreach ($line in $file) 
{
    [int]$countOfWinningNumbers = 0;
    if ($line -match "Card\s+(?<CardNum>[\d]*):\s*(?<MyCardNumbers>[\d\s]*)\s*\|\s*(?<WinningCardNumbers>[\d\s]*)")
    {
        Write-Host "Card Number: [$($Matches.CardNum)]"
        Write-Verbose "Scratches: [$($Matches.MyCardNumbers)]"
        Write-Verbose "Winners: [$($Matches.WinningCardNumbers)]"
        [string[]]$scratches = $Matches.MyCardNumbers.Trim().Split(' ',[System.StringSplitOptions]::RemoveEmptyEntries);
        [string[]]$winners = $Matches.WinningCardNumbers.Trim().Split(' ',[System.StringSplitOptions]::RemoveEmptyEntries);
        foreach ($scratch in $scratches)
        {
            Write-Verbose "[$scratch]"
            if ($scratch -in $winners) 
            {
                Write-Host "Found a wining number: [$scratch]"
                $countOfWinningNumbers++;
            }
        }
    }
    else 
    {
        throw "Card does not match regex: $line"
    }
    [int]$points = [Math]::Pow(2, $countOfWinningNumbers - 1)
    Write-Host "Card Result = $points"

    $runningTotal += $points;
}
return $runningTotal