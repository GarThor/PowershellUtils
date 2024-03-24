[CmdletBinding()] 
param(
    [String]$Directions = "input.txt"
)

if (-not ($Directions | Test-Path)) {
    # file with path $path doesn't exist
    throw "Input: [$Hands] Does not Exist!"
}

[string[]]$file = Get-Content $Directions;

[string]$instructions = "";
if ($file[0] -match "(?<Instructions>[LR]+)")
{
    $instructions = $Matches.Instructions;
}
else 
{
    throw "Invalid instructions."
}

$map = @{};
for ($lineIdx = 2; $lineIdx -lt $file.Length; $lineIdx++)
{
    $line = $file[$lineIdx]
    if ($line -match "(?<NodeName>[\w]{3}) = \((?<Left>[\w]{3}), (?<Right>[\w]{3})\)")
    {
        if ($map[$Matches.NodeName])
        {
            throw "Node already exists! $lineIdx : $line"
        }

        $map[$Matches.NodeName] = @{ 'L' = $Matches.Left; 'R' = $Matches.Right }
    }
    else 
    {
        throw "Line $lineIdx : '$line' does not match expected input"
    }
}

[int]$stepcount = 0
[string[]]$currentNodeNames = $map.Keys | Where-Object {$_.EndsWith('A')}
$done = $false
$instructionIdx = 0;
while (-not $done)
{
    [string]$instruction = $instructions[$instructionIdx];
    $instructionIdx++;
    if ($instructionIdx -ge $instructions.Length)
    {
        $instructionIdx = 0;
    }

    $doneCount = 0;
    for ($nodeIdx = 0; $nodeIdx -lt $currentNodeNames.Length; $nodeIdx++)
    {
        $currentNodeName    = $currentNodeNames[$nodeIdx];
        $currentNode        = $map[$currentNodeName];
        $nextNodeName       = $currentNode[$instruction];
        $currentNodeNames[$nodeIdx] = $nextNodeName;

        if ($nextNodeName.EndsWith('Z'))
        {
            $doneCount++;
        }
    }

    Write-Host "Current Step: $currentNodeNames"
    if ($doneCount -gt 0)
    {
        Write-Host "Current Step: $currentNodeNames" -BackgroundColor Red -ForegroundColor Black;
    }

    if ($doneCount -eq $currentNodeNames.Length)
    {
        $done = $true;
    }
    $stepCount++;
}

return $stepcount