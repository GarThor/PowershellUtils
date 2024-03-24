[CmdletBinding()] 
param(
    [String]$Scratchers = "example.txt"
)

if (-not ($Scratchers | Test-Path)) {
    # file with path $path doesn't exist
    throw "Input: [$Scratchers] Does not Exist!"
}

[string[]]$file = Get-Content $Scratchers;

$cardCount = @{};

foreach ($line in $file) 
{
    if ($line -match "Card\s+(?<CardNum>[\d]*):\s*(?<MyCardNumbers>[\d\s]*)\s*\|\s*(?<WinningCardNumbers>[\d\s]*)")
    {
        [int]$cardNum = $Matches.CardNum;
        $myCard = $Matches.MyCardNumbers;
        $winningNums = $Matches.WinningCardNumbers;

        # Count one for this card
        $cardCount[$cardNum]++;

        Write-Host "Card Number: [$cardNum]"
        Write-Verbose "Scratches: [$myCard]"
        Write-Verbose "Winners: [$winningNums]"
        [string[]]$scratches = $myCard.Trim().Split(' ',[System.StringSplitOptions]::RemoveEmptyEntries);
        [string[]]$winners = $winningNums.Trim().Split(' ',[System.StringSplitOptions]::RemoveEmptyEntries);

        [int]$countOfWinningNumbers = 0;
        foreach ($scratch in $scratches)
        {
            Write-Verbose "[$scratch]"
            if ($scratch -in $winners) 
            {
                Write-Host "Found a wining number: [$scratch]"
                $countOfWinningNumbers++;
            }
        }

        [int]$start = $cardNum + 1;
        [int]$end = $cardNum + $countOfWinningNumbers;
        [int]$countOfThisCard = $cardCount[$cardNum];
        for ([int]$cardIdx = $start; $cardIdx -le $end; $cardIdx++ )
        {
            $cardCount[$cardIdx] += $countOfThisCard;
        }
    }
    else 
    {
        throw "Card does not match regex: $line"
    }
}
[int]$runningTotal = 0;
foreach ($card in $cardCount.GetEnumerator())
{
    $runningTotal += $card.value;
}
return $runningTotal