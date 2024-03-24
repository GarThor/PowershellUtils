[CmdletBinding()] 
param(
    [String]$Games = "example.txt"
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
        [int]$minGameReds = 0;
        [int]$minGameGreens = 0;
        [int]$minGameBlues = 0;
        for ([int]$setNumber = 0; $setNumber -lt $sets.length -and $gameIsValid; $setNumber++) {
            [string]$set = $sets[$setNumber];
            Write-Verbose "    Set #$($setNumber): [$set]"

            [int]$setReds = 0;
            [int]$setGreens = 0;
            [int]$setBlues = 0;
            [string[]]$diceGroups = $set.Split(",");
            [string[]]$diceGroups = $diceGroups.Trim();
            foreach ($diceGroup in $diceGroups) {
                Write-Debug "        Group: [$diceGroup]"

                if ($diceGroup -match "(?<NumDice>\d*) (?<DiceColor>red|green|blue)") {
                    switch ($matches.DiceColor) {
                        "red" {
                            $setReds += $matches.NumDice;
                        }
                        "green" {
                            $setGreens += $matches.NumDice;
                        }
                        "blue" {
                            $setBlues += $matches.NumDice;
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

            if ($setReds -gt $minGameReds) {$minGameReds = $setReds}
            if ($setGreens -gt $minGameGreens) {$minGameGreens = $setGreens}
            if ($setBlues -gt $minGameBlues) {$minGameBlues = $setBlues}
            Write-Verbose "     Game Minimums: Reds $minGameReds, Greens $minGameGreens, Blues $minGameBlues"
        }

        $gamePower = $minGameReds * $minGameGreens * $minGameBlues;
        Write-Verbose "Resulting Game Power: $minGameReds * $minGameGreens * $minGameBlues = $gamePower"
        $runningTotal += $gamePower;
    }
    else {
        throw "Input: '$line' did not match needed input"
    }
}


return $runningTotal