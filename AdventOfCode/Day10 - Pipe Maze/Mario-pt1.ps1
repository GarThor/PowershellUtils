[CmdletBinding()] 
param(
    [String]$Pipes = "example1.txt"
)

if (-not ($Pipes | Test-Path)) {
    throw "Input file: [$Pipes] Does not Exist!"
}

[string[]]$file = Get-Content $Pipes;

Class Coordinates
{
    [int]$x;
    [int]$y;
    Coordinates($X,$Y)
    {
        $this.x = $X;
        $this.y = $Y;
    }

    [string]ToString()
    {
        return "($($this.x), $($this.y))"
    }

    [Coordinates]North()
    {
        return [Coordinates]::new($this.x, $this.y - 1);
    }
    [Coordinates]East()
    {
        return [Coordinates]::new($this.x + 1, $this.y);
    }
    [Coordinates]South()
    {
        return [Coordinates]::new($this.x, $this.y + 1);
    }
    [Coordinates]West()
    {
        return [Coordinates]::new($this.x - 1, $this.y);
    }

    [bool]IsNorthOf([Coordinates]$In)
    {
        return $this.x -eq $In.x -and $this.y -lt $In.y;
    }
    [bool]IsEastOf([Coordinates]$In)
    {
        return $this.x -gt $In.x -and $this.y -eq $In.y;
    }
    [bool]IsSouthOf([Coordinates]$In)
    {
        return $this.x -eq $In.x -and $this.y -gt $In.y;
    }
    [bool]IsWestOf([Coordinates]$In)
    {
        return $this.x -lt $In.x -and $this.y -eq $In.y;
    }
}

function GetTile {
    [OutputType([Char])]
    [CmdletBinding()] 
    param(
        [Parameter(Mandatory, ParameterSetName = 'XY', Position = 0)]
        $X,
        [Parameter(Mandatory, ParameterSetName = 'XY', Position = 1)]
        $Y,

        [Parameter(Mandatory, ParameterSetName = 'Coords', Position = 1)]
        [Coordinates]$Coords,

        $map = $file
    )
    switch ($PSCmdlet.ParameterSetName)
    {
        'XY' {return [Char]$map[$Y][$X];}
        'Coords' {return [Char]$map[$Coords.Y][$Coords.X];}
    }
    
}

[Coordinates]$startingPos = [Coordinates]::new(-1,-1);
for ($lineIdx = 0; $lineIdx -lt $file.Length; $lineIdx++)
{
    $pos = $file[$lineIdx].IndexOf('S');
    if ($pos -ge 0)
    {
        $startingPos.y = $lineIdx;
        $startingPos.x = $pos;
    }
}

if ($startingPos.y -eq -1 -or $startingPos.x -eq -1)
{
    throw "Invalid input, where is the starting position?"
}

Write-Verbose "Input has a starting position of ($($startingPos.x),$($startingPos.y))"

# find the initial direction:
[Coordinates[]]$possibleNextSquares = @()
if ((GetTile -X ($startingPos.x - 1) -Y $startingPos.y) -in [char[]]"FL-")
{
    Write-Verbose "Creature can move west."
    $possibleNextSquares += [Coordinates]::new($startingPos.x - 1,$startingPos.y)
}
if ((GetTile -X ($startingPos.x + 1) -Y $startingPos.y) -in [char[]]"J7-")
{
    Write-Verbose "Creature can move east."
    $possibleNextSquares += [Coordinates]::new($startingPos.x + 1, $startingPos.y);
}
if ((GetTile -X $startingPos.x -Y ($startingPos.y - 1)) -in [char[]]"|7F")
{
    Write-Verbose "Creature can move north."
    $possibleNextSquares += [Coordinates]::new($startingPos.x, $startingPos.y - 1);
}
if ((GetTile -X $startingPos.x -Y ($startingPos.y + 1)) -in [char[]]"|LJ")
{
    Write-Verbose "Creature can move south."
    $possibleNextSquares += [Coordinates]::new($startingPos.x, $startingPos.y - 1);
}

if ($possibleNextSquares.Length -gt 2)
{
    throw "Too many possible paths for the creature... found $($possibleNextSquares.Length) possibilities: $possibleNextSquares"
}
if ($possibleNextSquares.Length -lt 2)
{
    throw "Not enough possible paths for the creature... found $($possibleNextSquares.Length) possibilities: $possibleNextSquares"
}

$stepCount = 1; # already found the first step.
$lastPos = $startingPos;
$currentPos = $possibleNextSquares[0]; # arbitrarially go with the first position
while ((GetTile -Coords $currentPos) -ne 'S')
{
    [char]$currentTile = GetTile -Coords $currentPos;
    [Coordinates]$nextPos = [Coordinates]::new(-1, -1);
    Write-Verbose "Step $stepCount : Moving From $lastPos to $currentPos"
    if ($lastPos.IsNorthOf($currentPos))
    {
        Write-Verbose "   - moving south"
        switch ($currentTile)
        {
            'L' {$nextPos = $currentPos.East();}
            'J' {$nextPos = $currentPos.West();}
            '|' {$nextPos = $currentPos.South();}
        }
    }
    elseif ($lastPos.IsEastOf($currentPos))
    {
        Write-Verbose "   - moving west"
        switch ($currentTile)
        {
            'L' {$nextPos = $currentPos.North();} 
            'F' {$nextPos = $currentPos.South();} 
            '-' {$nextPos = $currentPos.West();}
        }
    }
    elseif ($lastPos.IsSouthOf($currentPos))
    {
        Write-Verbose "   - moving north"
        switch ($currentTile)
        {
            '7' {$nextPos = $currentPos.West();} # moving west
            'F' {$nextPos = $currentPos.East();} # moving east
            '|' {$nextPos = $currentPos.North();} # continuing north
        }
    }
    elseif ($lastPos.IsWestOf($currentPos)) 
    {
        Write-Verbose "   - moving east"
        switch ($currentTile)
        {
            'J' {$nextPos = $currentPos.North();} # moving north
            '7' {$nextPos = $currentPos.South();} # moving south
            '-' {$nextPos = $currentPos.East();} # continuing east
        }
    }

    if ($nextPos.y -lt 0 -or $nextPos.y -ge $file.Length -or
        $nextPos.x -lt 0 -or $nextPos.x -ge $file[$nextPos.Y].Length)
    {
        $x, $y = $currentPos.X, $currentPos.Y;
        $lx, $ly = $lastPos.X, $lastPos.Y;
        $nx, $ny = $nextPos.X, $nextPos.Y;
        throw "Invalid input $stepCount @ ($x,$y) '$currentTile', w/ lastpos ($lx,$ly) next pos ($nx,$ny) out of range"       
    }
    $lastPos = $currentPos;
    $currentPos = $nextPos;
    $stepCount++;
}

return ($stepCount / 2)
