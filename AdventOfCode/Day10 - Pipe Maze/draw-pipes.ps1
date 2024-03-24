[CmdletBinding()] 
param(
    [String]$Pipes = "example1.txt"
)

if (-not ($Pipes | Test-Path)) {
    throw "Input file: [$Pipes] Does not Exist!"
}

[string[]]$file = Get-Content $Pipes;

[string[]]$result = @();
foreach ($line in $file)
{
    [string]$temp = [System.Text.Encoding]::UTF8.GetBytes($temp);
    $temp = $temp.Replace('7',[char]0x00BB);
    $temp = $temp.Replace('F','P');
    $temp = $temp.Replace('L','P');
    $temp = $temp.Replace('J','P');

    $result += ,$temp;
}


return $result;