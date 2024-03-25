param(
    [string]$File
)
try 
{
$path = (Get-ChildItem $File).FullName
[reflection.assembly]::LoadWithPartialName("System.Drawing")
$pic = New-Object System.Drawing.Bitmap($path)
$bitearr = $pic.GetPropertyItem(36867).Value 
$string = [System.Text.Encoding]::ASCII.GetString($bitearr) 
$DateTime = [datetime]::ParseExact($string,"yyyy:MM:dd HH:mm:ss`0",$Null)
$DateTime
}
catch {
    throw
}
finally {
    $pic.Dispose()
}