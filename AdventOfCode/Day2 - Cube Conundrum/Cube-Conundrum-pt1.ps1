[CmdletBinding()] 
param(
    [String]$Games = "example.txt",
    [int]$Reds = 12,
    [int]$Greens = 13,
    [int]$Blues = 14
    
)

if (-not ($Games | Test-Path)) {
    # file with path $path doesn't exist
    throw "Input: [$Games] Does not Exist!"
}

[int]$runningTotal = 0;

$file = Get-Content $Games;

foreach ($line in $file) {
    if ($line -match "Game (?<GameID>\d*): (?<GameSets>[\d\w\s,;]*)") {
        Write-Verbose "*** $line"
        $gameID = $matches.GameID;
        $gameSets = $matches.GameSets;
        Write-Host "Game #$gameID [$gameSets)]"
        [string[]]$sets = $gameSets.Split(";").Trim();
        
        [bool]$gameIsValid = $true; #assume game is valid, until proven otherwise.
        for ([int]$setNumber = 0; $setNumber -lt $sets.length -and $gameIsValid; $setNumber++) {
            [string]$set = $sets[$setNumber];
            Write-Verbose "    Set #$($setNumber): [$set]"

            [int]$gameReds = 0;
            [int]$gameGreens = 0;
            [int]$gameBlues = 0;
            [string[]]$diceGroups = $set.Split(",");
            [string[]]$diceGroups = $diceGroups.Trim();
            foreach ($diceGroup in $diceGroups) {
                Write-Debug "        Group: [$diceGroup]"

                if ($diceGroup -match "(?<NumDice>\d*) (?<DiceColor>red|green|blue)") {
                    switch ($matches.DiceColor) {
                        "red" {
                            $gameReds += $matches.NumDice;
                        }
                        "green" {
                            $gameGreens += $matches.NumDice;
                        }
                        "blue" {
                            $gameBlues += $matches.NumDice;
                        }
                        default {
                            throw "$($matches.DiceColor) not recognised";
                        }
                    }
                }
                else {
                    throw "Dice Group did not match regex: $diceGroup, (for set number $idx in gameid: $($matches.GameId))";
                }
            }

            if ($gameReds -gt $Reds) {
                Write-Verbose "Too Many Reds, Game is invalid!"
                $gameIsValid = $false;
            }
            elseif ($gameGreens -gt $Greens) {
                Write-Verbose "Too Many Greens, Game is invalid!"
                $gameIsValid = $false;
            }
            elseif ($gameBlues -gt $Blues) {
                Write-Verbose "Too Many Blues, Game is invalid!"
                $gameIsValid = $false;
            }
        }

        if ($gameIsValid) {
            Write-Verbose "Game is valid, adding $gameID to running total!"
            $runningTotal += $gameID;
        }
    }
    else {
        throw "Input: '$line' did not match needed input"
    }
}


return $runningTotal