[CmdletBinding()] 
param(
    [String]$Hands = "example.txt"
)

if (-not ($Hands | Test-Path)) {
    # file with path $path doesn't exist
    throw "Input: [$Hands] Does not Exist!"
}

[string[]]$file = Get-Content $Hands;

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
        $cardTypes = "J23456789TQKA"
        $cardRanks = "0123456789abc"
        $scoreCard = New-Object int[] ($cardTypes.Length);
        [string]$secondaryScore = ""
        [int]$wildCount = 0;
        for ($cardIdx = 0; $cardIdx -lt $this.Cards.Length; $cardIdx++)
        {
            $card = $this.Cards[$cardIdx];
            if ($card -eq "J")
            {
                $wildCount++;
            }
            [int]$rank = $cardTypes.IndexOf($card);
            if ($rank -lt 0) 
            {
                throw "Invalid Card!"
            }
            $scoreCard[$rank]++;
            $secondaryScore += $cardRanks[$rank];
        }
        $sortedScoreCard = $scoreCard | Sort-Object -Descending

        $scoreTypes = @{
           Five_of_a_kind   = "6.";
           Four_of_a_kind   = "5.";
           Full_house       = "4.";
           Three_of_a_kind  = "3.";
           Two_pair         = "2.";
           One_pair         = "1.";
           High_card        = "0.";
        }

        if ($wildCount -gt 0)
        {
            Write-Verbose "Hand had wilds: $($this.Cards)"
        }

        [bool]$handWasUpgraded = $false;

        [string]$score = "";
        if ($sortedScoreCard[0] -eq 5)
        {
            # "Five of a kind"
            $score = $scoreTypes.Five_of_a_kind + $secondaryScore;
            if ($wildCount -eq 5)
            {
                # hand already has the max primary score.
                $handWasUpgraded = $true; 
            }
        }
        elseif ($sortedScoreCard[0] -eq 4)
        {
            # "Four of a kind"
            $score = $scoreTypes.Four_of_a_kind + $secondaryScore;
            if ($wildCount -eq 1 -or $wildCount -eq 4)
            {
                # the odd card out is a either a wild, or the other four are 
                #   so upgrade this to five of a kind!
                $score = $scoreTypes.Five_of_a_kind + $secondaryScore;
                $handWasUpgraded = $true;
            }
        }
        elseif ($sortedScoreCard[0] -eq 3 -and $sortedScoreCard[1] -eq 2)
        {
            # "Full house"
            $score = $scoreTypes.Full_house + $secondaryScore;
            if ($wildCount -eq 2 -or $wildCount -eq 3)
            {
                # one of the two sets is wild, upgrade to five of a kind!
                $score = $scoreTypes.Five_of_a_kind + $secondaryScore;
                $handWasUpgraded = $true;
            }
        }
        elseif ($sortedScoreCard[0] -eq 3 -and $sortedScoreCard[1] -eq 1)
        {
            # "Three of a kind"
            $score = $scoreTypes.Three_of_a_kind + $secondaryScore;
            if ($wildCount -eq 1 -or $wildCount -eq 3) 
            {
                # Either the wild is the same type as the three matching cards
                #   or, the wilds are the three matching cards...
                #   This upgrades this hand to a four of a kind
                $score = $scoreTypes.Four_of_a_kind + $secondaryScore;
                $handWasUpgraded = $true;
            }
        }
        elseif ($sortedScoreCard[0] -eq 2 -and $sortedScoreCard[1] -eq 2)
        {
            # "Two Pair"
            $score = $scoreTypes.Two_pair + $secondaryScore;
            if ($wildCount -eq 1)
            {
                # upgrade to full house IE: AAJBB = AAABB / AABBB
                $score = $scoreTypes.Full_house + $secondaryScore;
                $handWasUpgraded = $true;
            }
            elseif ($wildCount -eq 2)
            {
                # one of the pairs is wild, which means this is actually a four of a kind
                $score = $scoreTypes.Four_of_a_kind + $secondaryScore;
                $handWasUpgraded = $true;
            }
        }
        elseif ($sortedScoreCard[0] -eq 2 -and $sortedScoreCard[1] -eq 1)
        {
            # "One Pair"
            $score = $scoreTypes.One_pair + $secondaryScore;
            if ($wildCount -eq 1 -or $wildCount -eq 2)
            {
                # upgrade to 3 of a kind; AABCJ becomes AACDA, and JJABC becomes AAABC 
                $score = $scoreTypes.Three_of_a_kind + $secondaryScore;
                $handWasUpgraded = $true;
            }
        }
        else 
        {
            # "High Card"
            $score = $scoreTypes.High_card + $secondaryScore;
            if ($wildCount -eq 1)
            {
                # upgrade to 1-pair
                $score = $scoreTypes.One_pair + $secondaryScore;
                $handWasUpgraded = $true;
            }
        }

        if ($score -eq "")
        {
            throw "Card cannot be scored $($this.Card) $($this.Bid)"
        }

        if ($wildCount -gt 0 -and -not $handWasUpgraded)
        {
            throw "Could not upgrade hand: $($this.Card) $($this.Bid)"
        }
        return $score
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