[CmdletBinding()] 
param(
    [String]$Datasest = "example.txt"
)

if (-not ($Datasest | Test-Path)) {
    # file with path $path doesn't exist
    throw "Input: [$Datasest] Does not Exist!"
}

[string[]]$file = Get-Content $Datasest;

function SequenceIsAllZeroes([int[]]$sequence)
{
    [string]$result = $true;
    foreach ($item in $sequence)
    {
        if ($item -ne 0)
        {
            $result = $false;
            break;
        }
    }
    return $result;
}

[int]$runningTotal = 0;

for ($lineIdx = 0; $lineIdx -lt $file.Length; $lineIdx++)
{
    $line = $file[$lineIdx];
    $sequences = @()
    if ($line -match "(?<History>[\d\-\s]+)")
    {
        $initialSequence = $Matches.History.Split(' ') | ForEach-Object { [int]::parse($_) };
        $sequences += ,$initialSequence;
    }
    else 
    {
        throw "Invalid Line @ $lineIdx : '$line'"
    }

    $allZeroes = SequenceIsAllZeroes($sequences[-1]);
    while ($allZeroes -ne $true)
    {
        $newSequence = @();

        $currentSequence = $sequences[-1]
        for ($idx = 0; $idx -lt $currentSequence.Length - 1; $idx++)
        {
            $currentVal = $currentSequence[$idx];
            $nextVal = $currentSequence[$idx + 1];

            $newSequence += ($nextVal - $currentVal);
        }

        $sequences += ,$newSequence;
        $allZeroes = SequenceIsAllZeroes($sequences[-1]);

    }

    Write-Host "Processing Sequence Input #$lineIdx :"
    foreach ($sequence in $sequences)
    {
        Write-Verbose "$sequence";
    }

    $sequences[-1] += 0;
    for ($sequenceIdx = $sequences.Length - 2; $sequenceIdx -ge 0; $sequenceIdx--)
    {
        Write-Verbose "$($sequences[$sequenceIdx])"

        $c = $sequences[$sequenceIdx + 1][-1];
        $a = $sequences[$sequenceIdx][-1] + $c;

        $sequences[$sequenceIdx] += $a;
    }

    Write-Verbose "Sequence after processing #$lineIdx :"
    foreach ($sequence in $sequences)
    {
        Write-Verbose "$sequence";
    }

    $runningTotal += $sequences[0][-1];
}

$runningTotal