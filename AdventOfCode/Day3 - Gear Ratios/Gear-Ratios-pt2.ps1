[CmdletBinding()] 
param(
    [String]$Gears = "example.txt"
)

if (-not ($Gears | Test-Path)) {
    # file with path $path doesn't exist
    throw "Input: [$Gears] Does not Exist!"
}

[int]$runningTotal = 0;

[system.char[][]]$file = Get-Content $Gears;

for ([int]$row = 0; $row -lt $file.Count; $row++) 
{
    for ([int]$col = 0; $col -lt $file[$row].Count; $col++) 
    {
        if ($file[$row][$col] -eq '*')
        {
            Write-Host "Found '$($file[$row][$col])'! There should be two parts number nearby!"
            
            $gearCount = 0;
            $gearRatio = 1;
            for ([int]$tempRow = $row - 1; $tempRow -le ($row + 1); $tempRow++) 
            {
                [System.String]$testLine =  -join $file[$tempRow];
                #Write-Host "TEST LINE: '$testLine'"
                for ([int]$tempCol = $col - 1; $tempCol -le ($col + 1); $tempCol++)
                {
                    # Write-Host -NoNewline $file[$tempRow][$tempCol]
                    if ([System.Char]::IsDigit($file[$tempRow][$tempCol]))
                    {
                        # Write-Host "Found '$($file[$tempRow][$tempCol])'! This is the start of a part number!";
                        [int]$start = $testLine.LastIndexOfAny('.*', $tempCol) + 1
                        if (-not [System.Char]::IsDigit($testLine[$start]))
                        {
                            # we just found the symbol that probably indicated this was a valid part number so skip it
                            $start++; 
                        }
                        [int]$end = $testLine.IndexOfAny('.*', $tempCol)
                        if ($end -gt $testLine.Length -or $end -eq -1)
                        {
                            $end = $testLine.Length;
                        }
                        if (-not [System.Char]::IsDigit($testLine[$end - 1]) -and
                           $testLine[$end - 1] -ne '.')
                        {
                            # we just found the symbol that probably indicated this was a valid part number so skip it
                            $end--; 
                        }
                        $tempCol = $end; #skip to the end of the number, so we don't duplicate it if we're adjacent to multiple digits

                        $num = $testLine.Substring($start, $end - $start);
                        if ($end -le $start) {
                            throw "Error at $tempRow : $start >= $end"
                        }
                        Write-Host "found: '$num'"
                        $gearRatio *= $num
                        $gearCount++;
                    }
                }
            }
            if ($gearCount -gt 1)
            {
                Write-Host "gear ratio: $gearRatio"
                $runningTotal += $gearRatio;
            }

        }
    }
}
return $runningTotal