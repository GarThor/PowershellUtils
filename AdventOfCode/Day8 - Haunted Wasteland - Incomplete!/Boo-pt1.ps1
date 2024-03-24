[CmdletBinding()] 
param(
    [String]$Directions = "example2.txt"
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
$currentNodeName = "AAA"
$currentNode = $map[$currentNodeName];
$instructionIdx = 0;
while ($currentNode -and $currentNodeName -ne "ZZZ")
{
    [string]$instruction = $instructions[$instructionIdx];
    $instructionIdx++;
    if ($instructionIdx -ge $instructions.Length)
    {
        $instructionIdx = 0;
    }

    $currentNodeName = $currentNode[$instruction];
    $currentNode = $map[$currentNodeName]
    $stepCount++;
}

return $stepcount