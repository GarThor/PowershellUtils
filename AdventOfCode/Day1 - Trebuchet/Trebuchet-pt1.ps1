param(
    [String]$Coordinates = ".input.txt"
)

if (-not ($Coordinates | Test-Path)) {
    # file with path $path doesn't exist
    throw "Input: [$Coordinates] Does not Exist!"
}

$file = Get-Content $Coordinates;

[int]$runningTotal = 0;
foreach ($line in $file) {
    [char]$first = 0;
    Write-Host $line
    [bool]$foundFirst = $false
    for ($idx = 0; $idx -lt $line.length; $idx++) {
        [char]$testCharacter = $line[$idx];
        if ($testCharacter -ge '0' -and $testCharacter -le '9') {
            $first = $testCharacter;
            $foundFirst = $true;
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
    }

    if (-not $foundLast) {
        throw "No digits found in $line";
    }

    $lineResultStr = "$first$last";
    [int]$lineResult = [int]$lineResultStr
    Write-Host $lineResult;
    $runningTotal += $lineResult;
}

return $runningTotal