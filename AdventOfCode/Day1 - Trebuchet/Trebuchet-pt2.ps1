param(
    [String]$Coordinates = ".input.txt"
)

if (-not ($Coordinates | Test-Path)) {
    # file with path $path doesn't exist
    throw "Input: [$Coordinates] Does not Exist!"
}

$file = Get-Content $Coordinates;

$nums = @{
    "one" =     '1' ;
    "two" =     '2' ;
    "three" =   '3' ;
    "four" =    '4' ;
    "five" =    '5' ;
    "six" =     '6' ;
    "seven" =   '7' ;
    "eight" =   '8' ;
    "nine" =    '9' };

[int]$runningTotal = 0;
foreach ($line in $file) {
    [char]$first = 0;
    Write-Host $line
    [bool]$foundFirst = $false
    for ($idx = 0; $idx -lt $line.length; $idx++) {
        [char]$testCharacter = $line[$idx];
        if (($testCharacter -ge '0' -and $testCharacter -le '9')) {
            $first = $testCharacter;
            $foundFirst = $true;
            break;
        }
        foreach ($num in $nums.Keys) {
            if ($line.length -gt ($idx + $num.length - 1)) {
                if ($line.Substring($idx, $num.length) -eq $num) {
                    $first = $nums[$num];
                    $foundFirst = $true;
                    break;
                }
            }
        }

        if ($foundFirst) {
            break;
        }
    }

    if (-not $foundFirst) {
        throw "No digits found in $line";
    }

    [char]$last = 0;
    [bool]$foundLast = $false;
    for ($idx = $line.length; $idx -ge 0; $idx--) {
        [char]$testCharacter = $line[$idx];
        if ($testCharacter -ge '0' -and $testCharacter -le '9') {
            $last = $testCharacter;
            $foundLast = $true;
            break;
        }        
        foreach ($num in $nums.Keys) {
            if ($line.length -gt ($idx + $num.length - 1)) {
                if ($line.Substring($idx, $num.length) -eq $num) {
                    $last = $nums[$num];
                    $foundLast = $true;
                    break;
                }
            }
        }

        if ($foundLast) {
            break;
        }
    }

    if (-not $foundLast) {
        throw "No digits found in $line";
    }

    $lineResultStr = "$first$last";
    [int]$lineResult = [int]$lineResultStr
    Write-Host "result: $lineResult";
    $runningTotal += $lineResult;
}

return $runningTotal