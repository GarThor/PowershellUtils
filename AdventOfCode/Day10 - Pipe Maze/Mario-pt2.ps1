[CmdletBinding()] 
param(
    [String]$Pipes = "example1.txt"
)

if (-not ($Pipes | Test-Path)) {
    throw "Input file: [$Pipes] Does not Exist!"
}

Class Coordinates : System.IEquatable[Object]
{
    [int]$x;
    [int]$y;
    Coordinates($X,$Y)
    {
        $this.x = $X;
        $this.y = $Y;
    }

    [boolean]Equals([Object]$other)
    {
        if ($null -eq $other)
        {
            return $false;
        }
        return $this.x -eq $other.x -and $this.y -eq $other.y;
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

[string[]]$file = Get-Content $Pipes;

function GetTile {
    [OutputType([Char])]
    [CmdletBinding()] 
    param(
        [Parameter(Mandatory, ParameterSetName = 'XY', Position = 0)]
        [int]$X,
        [Parameter(Mandatory, ParameterSetName = 'XY', Position = 1)]
        [int]$Y,

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

enum TileType {
    Unknown = 0
    Path
    Inside
    Outsidex
    Left
    Right
}
[TileType[][]]$tiles = @();

function SetTileType {
    [OutputType([Void])]
    [CmdletBinding()] 
    param(
        [Parameter(Mandatory, ParameterSetName = 'XY', Position = 0)]
        [int]$X,
        [Parameter(Mandatory, ParameterSetName = 'XY', Position = 1)]
        [int]$Y,

        [Parameter(Mandatory, ParameterSetName = 'Coords', Position = 1)]
        [Coordinates]$Coords,

        $Map = $tiles,
        [TileType]$NewType,
        [switch]$Force
    )
    $thisX = -1;
    $thisY = -1;
    switch ($PSCmdlet.ParameterSetName)
    {
        'XY' {
            $thisX = $X;
            $thisY = $Y;
        }
        'Coords' {
            $thisX = $Coords.X;
            $thisY = $Coords.Y;
        }
    }

    if ($thisY -ge 0 -and $thisY -lt $map.Length)
    {
        if ($thisX -ge 0 -and $thisX -lt $map[$thisY].Length)
        {
            if ($Force -or $map[$thisY][$thisX] -eq [TileType]::Unknown -or
                $NewType -eq [TileType]::Path)
            {
                $map[$thisY][$thisX] = $newType;
            }
        }
    }
}

function GetTiles 
{
    $result = @();
    [int]$rowIdx = 0;
    foreach ($tileA in $tiles)
    {
        $result += ,[Char[]]::new($tileA.Length);
        $colIdx = 0;
        foreach ($tile in $tileA)
        {
            switch ($tile)
            {
                Unknown {$result[$rowIdx][$colIdx] = '.'}
                Left {$result[$rowIdx][$colIdx] = 'L'}
                Right {$result[$rowIdx][$colIdx] = 'R'}
                Path {$result[$rowIdx][$colIdx] = 'P'}
                Inside {$result[$rowIdx][$colIdx] = 'I'}
                Outside {$result[$rowIdx][$colIdx] = 'O'}
            }
            $colIdx++;
        }
        $rowIdx++;
    }
    return $result;
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

    $tiles += ,[TileType[]]::new($file[$lineIdx].Length);
}

if ($startingPos.y -eq -1 -or $startingPos.x -eq -1)
{
    throw "Invalid input, where is the starting position?"
}

Write-Verbose "Input has a starting position of ($($startingPos.x),$($startingPos.y))"

SetTileType -Coords $startingPos -NewType Path;

# find the initial direction:
[Coordinates[]]$possibleNextSquares = @()
if ((GetTile -Coords $startingPos.West()) -in [char[]]"FL-")
{
    Write-Verbose "Creature can move west."
    $possibleNextSquares += $startingPos.West();
}
if ((GetTile -Coords $startingPos.East()) -in [char[]]"J7-")
{
    Write-Verbose "Creature can move east."
    $possibleNextSquares += $startingPos.East();
}
if ((GetTile -Coords $startingPos.North()) -in [char[]]"|7F")
{
    Write-Verbose "Creature can move north."
    $possibleNextSquares += $startingPos.North();
}
if ((GetTile -Coords $startingPos.South()) -in [char[]]"|LJ")
{
    Write-Verbose "Creature can move south."
    $possibleNextSquares += $startingPos.South();
}

if ($possibleNextSquares.Length -gt 2)
{
    throw "Too many possible paths for the creature... found $($possibleNextSquares.Length) possibilities: $possibleNextSquares"
}
if ($possibleNextSquares.Length -lt 2)
{
    throw "Not enough possible paths for the creature... found $($possibleNextSquares.Length) possibilities: $possibleNextSquares"
}

$nextPos = $possibleNextSquares[0]; # arbitrarially go with the first position
$lastPos = $possibleNextSquares[1];

if ($nextPos -eq $startingPos.North())
{
    switch ($lastPos)
    {
        $startingPos.East()     {throw "start is L"}
        $startingPos.South()    {throw "start is |"}
        $startingPos.West()     {throw "start is J"}
        default                 {throw "start is ???"}
    }
}
elseif ($nextPos -eq $startingPos.East())
{
    switch ($lastPos)
    {
        $startingPos.North()    {throw "start is L"}
        $startingPos.South()    {
            SetTileType -Coords $startingPos.North() -NewType Left
            SetTileType -Coords $startingPos.West() -NewType Left
            SetTileType -Coords $startingPos.North().West() -NewType Left
            SetTileType -Coords $startingPos.East() -NewType Right
        }
        $startingPos.West()     {throw "start is -"}
        default                 {throw "start is ???"}
    }
}
elseif ($nextPos -eq $startingPos.South())
{
    switch ($lastPos)
    {
        $startingPos.East()     {throw "start is F"}
        $startingPos.North()    {throw "start is |"}
        $startingPos.West()     {throw "start is 7"}
        default                 {throw "start is ???"}
    }
}
elseif ($nextPos -eq $startingPos.West())
{
    switch ($lastPos)
    {
        $startingPos.North()     {throw "start is J"}
        $startingPos.East()      {throw "start is -"}
        $startingPos.South()     {
            SetTileType -Coords $startingPos.North().East() -NewType Right
            SetTileType -Coords $startingPos.North() -NewType Right
            SetTileType -Coords $startingPos.East() -NewType Right
            SetTileType -Coords $startingPos.South().West() -NewType Left
        }
        default                  {throw "start is ???"}
    }
}

$stepCount = 1; # already found the first step.
$lastPos = $startingPos;
$currentPos = $nextPos; # arbitrarially go with the first position
while ((GetTile -Coords $currentPos) -ne 'S')
{
    SetTileType -Coords $currentPos -NewType Path;
    [char]$currentTile = GetTile -Coords $currentPos;
    [Coordinates]$nextPos = [Coordinates]::new(-1, -1);
    Write-Verbose "Step $stepCount : Moving From $lastPos to $currentPos"
    if ($lastPos.IsNorthOf($currentPos))
    {
        Write-Verbose "   - moving south"
        switch ($currentTile)
        {
            'L' {
                $nextPos = $currentPos.East();
                SetTileType -Coords $currentPos.North().East() -NewType Left;
                SetTileType -Coords $currentPos.South().West() -NewType Right;
                SetTileType -Coords $currentPos.South() -NewType Right;
                SetTileType -Coords $currentPos.West() -NewType Right;
            }
            'J' {
                $nextPos = $currentPos.West();
                SetTileType -Coords $currentPos.East() -NewType Left;
                SetTileType -Coords $currentPos.South() -NewType Left;
                SetTileType -Coords $currentPos.South().East() -NewType Left;
                SetTileType -Coords $currentPos.North().West() -NewType Left;
            }
            '|' {
                $nextPos = $currentPos.South();
                SetTileType -Coords $currentPos.East() -NewType Left;
                SetTileType -Coords $currentPos.West() -NewType Right;
            }
        }
    }
    elseif ($lastPos.IsEastOf($currentPos))
    {
        Write-Verbose "   - moving west"
        switch ($currentTile)
        {
            'L' {
                $nextPos = $currentPos.North();
                SetTileType -Coords $currentPos.South() -NewType Left;
                SetTileType -Coords $currentPos.West() -NewType Left;
                SetTileType -Coords $currentPos.South().West() -NewType Left;
                SetTileType -Coords $currentPos.North().East() -NewType Right;
            } 
            'F' {
                $nextPos = $currentPos.South();
                SetTileType -Coords $currentPos.South().East() -NewType Left;
                SetTileType -Coords $currentPos.North() -NewType Right;
                SetTileType -Coords $currentPos.West() -NewType Right;
                SetTileType -Coords $currentPos.North().West() -NewType Right;
            } 
            '-' {
                $nextPos = $currentPos.West();
                SetTileType -Coords $currentPos.North() -NewType Right;
                SetTileType -Coords $currentPos.South() -NewType Left;
            }
        }
    }
    elseif ($lastPos.IsSouthOf($currentPos))
    {
        Write-Verbose "   - moving north"
        switch ($currentTile)
        {
            '7' {
                $nextPos = $currentPos.West();
                SetTileType -Coords $currentPos.South().West() -NewType Left;
                SetTileType -Coords $currentPos.North() -NewType Right;
                SetTileType -Coords $currentPos.East() -NewType Right;
                SetTileType -Coords $currentPos.North().East() -NewType Right;
            } 
            'F' {
                $nextPos = $currentPos.East();
                SetTileType -Coords $currentPos.South().East() -NewType Right;
                SetTileType -Coords $currentPos.North() -NewType Left;
                SetTileType -Coords $currentPos.West() -NewType Left;
                SetTileType -Coords $currentPos.North().West() -NewType Left;
            } 
            '|' {
                $nextPos = $currentPos.North();
                SetTileType -Coords $currentPos.East() -NewType Right;
                SetTileType -Coords $currentPos.West() -NewType Left;
            }
        }
    }
    elseif ($lastPos.IsWestOf($currentPos)) 
    {
        Write-Verbose "   - moving east"
        switch ($currentTile)
        {
            'J' {
                $nextPos = $currentPos.North();
                SetTileType -Coords $currentPos.North().West() -NewType Left;
                SetTileType -Coords $currentPos.South() -NewType Right;
                SetTileType -Coords $currentPos.East() -NewType Right;
                SetTileType -Coords $currentPos.South().East() -NewType Right;
            } 
            '7' {
                $nextPos = $currentPos.South();
                SetTileType -Coords $currentPos.North() -NewType Left;
                SetTileType -Coords $currentPos.North().East() -NewType Left;
                SetTileType -Coords $currentPos.East() -NewType Left;
                SetTileType -Coords $currentPos.South().West() -NewType Right;
            } 
            '-' {
                $nextPos = $currentPos.East();
                SetTileType -Coords $currentPos.North() -NewType Left;
                SetTileType -Coords $currentPos.South() -NewType Right;
            } 
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

# find the first unknown/left/right on the outside of the map
$unknowns = [System.Collections.Queue]::new();
$outside = $null;
$row = 0;
for ($col = 0; 
     $col -lt $tiles[$row].Length -and 
     $unknowns.Count -eq 0 -and 
     $null -eq $outside; $col++)
{
    switch (GetTile -X $col -Y 0)
    {
        Left { $outside = "left" }
        Right { $outside = "right" }
        Unknown { $unknowns.Enqueue([Coordinates]::new($col, $row)); }
    }
}

if ($null -eq $outside -and $unknowns.Count -eq 0)
{
    # try the bottom row
    $row = $tiles.Length - 1;
    for ($col = 0; 
        $col -lt $tiles[$row].Length -and 
        $unknowns.Count -eq 0 -and 
        $null -eq $outside; $col++)
    {
        switch (GetTile -X $col -Y $row)
        {
            Left { $outside = "left" }
            Right { $outside = "right" }
            unknown { $unknowns.Enqueue([Coordinates]::new($col, $row)); }
        }
    }
}

if ($null -eq $outside -and $unknowns.Count -eq 0)
{
    # try the sides
    for ($row = 0; 
        $row -lt $tiles.Length -and 
        $unknowns.Count -eq 0 -and 
        $null -eq $outside; $col++)
    {
        $first = 0;
        $last = $tiles[$row].Length - 1;
        switch (GetTile -X $first -Y $row)
        {
            Left { $outside = "left" }
            Right { $outside = "right" }
            unknown { $unknowns.Enqueue([Coordinates]::new($first, $row)); }
        }
        switch (GetTile -X $last -Y $row)
        {
            Left { $outside = "left" }
            Right { $outside = "right" }
            unknown { $unknowns.Enqueue([Coordinates]::new($last, $row)); }
        }
    }
}

if ($null -eq $outside -and $unknowns.Count -eq 0)
{
    throw "Both inside & outside were null.  This probably means that both left & right are both 'inside' but I don't want to deal with that case right now... so go away";
}

while ($outside.Count -gt 0)
{
    $currentPos = $outside.Dequeue();
    $north = $currentPos.North();
    $east = $currentPos.East();
    $south = $currentPos.South();
    $west = $currentPos.West();

    if ($north.Y -lt 0 -or $south.Y -ge $tiles.Length)
    {
        SetTileType -Coords $currentPos -NewType Outside;
    }
    elseif ($west.X -lt 0 -or $east.X -ge $tiles[$east.X].Length)
    {
        SetTileType -Coords $currentPos -NewType Outside;
    }
}

$foo = GetTiles;
[string[]]$lines = @();
foreach ($line in $foo)
{
    Write-Host $line;
    $lines += [string]$line;
}

return $lines
