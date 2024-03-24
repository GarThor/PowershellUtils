[CmdletBinding()] 
param(
    [String]$Hands = "example.txt"
)

if (-not ($Hands | Test-Path)) {
    # file with path $path doesn't exist
    throw "Input: [$Hands] Does not Exist!"
}

[string[]]$file = Get-Content $Hands;

Class Card 
{
    # A, K, Q, J, T, 9, 8, 7, 6, 5, 4, 3, or 2
}

Class HandType
{
    [string]$Cards;
    [int]$Bid;

    HandType([string]$Cards, [int]$Bid)
    {
        $this.Cards = $Cards;
        $this.Bid = $Bid;
    }

    [string]Score()
    {
        $cardTypes = "23456789TJQKA"
        $cardRanks = "023456789abcd"
        $scoreCard = New-Object int[] ($cardTypes.Length);
        [string]$secondaryScore = ""
        for ($cardIdx = 0; $cardIdx -lt $this.Cards.Length; $cardIdx++)
        {
            $card = $this.Cards[$cardIdx];
            [int]$rank = $cardTypes.IndexOf($card);
            if ($rank -lt 0) 
            {
                throw "Invalid Card!"
            }
            $scoreCard[$rank]++;
            $secondaryScore += $cardRanks[$rank];
        }
        $sortedScoreCard = $scoreCard | Sort-Object -Descending

        if ($sortedScoreCard[0] -eq 5)
        {
            # "Five of a kind"
            return "6." + $secondaryScore;
        }
        elseif ($sortedScoreCard[0] -eq 4)
        {
            # "Four of a kind"
            return "5." + $secondaryScore;
        }
        elseif ($sortedScoreCard[0] -eq 3 -and $sortedScoreCard[1] -eq 2)
        {
            # "Full house"
            return "4." + $secondaryScore;
        }
        elseif ($sortedScoreCard[0] -eq 3 -and $sortedScoreCard[1] -eq 1)
        {
            # "Three of a kind"
            return "3." + $secondaryScore;
        }
        elseif ($sortedScoreCard[0] -eq 2 -and $sortedScoreCard[1] -eq 2)
        {
            # "Two Pair"
            return "2." + $secondaryScore;
        }
        elseif ($sortedScoreCard[0] -eq 2 -and $sortedScoreCard[1] -eq 1)
        {
            # "One Pair"
            return "1." + $secondaryScore;
        }
        else 
        {
            # "High Card"
            return "0." + $secondaryScore;
        }

        throw "Card cannot be scored $($this.Card) $($this.Bid)"
        return '-1'
    }
}

[HandType[]]$hands = @();
foreach ($line in $file)
{
    if ($line -match "(?<Hand>[\dAKQJT]{5}) (?<Bid>[\d]+)")
    {
        $hands += [HandType]::New($Matches.Hand, [int]$Matches.Bid);
    }
}

$hands = $hands | Sort-Object -property @{Expression={$_.Score()}}

[int]$runningTotal = 0;
for ([int]$handIdx = 0; $handIdx -lt $hands.Length; $handIdx++)
{
    [int]$rank = $handIdx + 1;
    [int]$winnings = $hands[$handIdx].Bid * $rank;
    $runningTotal += $winnings;
}

return $runningTotal;