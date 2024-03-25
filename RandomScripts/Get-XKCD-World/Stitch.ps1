[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True)]
	[string]$File1 = "12345",
	[Parameter(Mandatory=$True)]
	[string]$File2 = "12345",
	[Parameter(Mandatory=$True)]
	[string]$Out = "asdf.jpg",
	
	
    [switch]$Vertical
)

Import-Module .\Image\Image.psm1

echo $File1
echo $File2

$Path = pwd

$File1 = $Path.path + "\" + $File1
$File2 = $Path.path + "\" + $File2
$Image1 = Get-image $File1
$Image2 = Get-image $File2

if (!$Image1)
{
	echo "Getting blank for Image 1"
	$File1 = $Path.path + "\White.png"
	$Image1 = Get-image $File1
}

if (!$Image2)
{
	echo "Getting blank for Image 2"
	$File2 = $Path.path + "\White.png"
	$Image2 = Get-image $File2
}

$Width = 12.1
$Height = 12.1
	
if ($Vertical)
{
	echo "Appending file1 to file2 vertically"

	$Width = $Image1.Width
	$Height = $Image1.Height + $Image2.Height

	echo $Width
	echo $Height
	
	if ($Image1.width -le $Image2.width)
	{
		$Width = $Image2.width
	}
	
	$Filter = Add-ScaleFilter -width $Width -height $Height -doNotPreserveAspectRatio -passThru | 
		Add-OverlayFilter -Image $Image1 -Left 0 -Top 0 -passThru |
		Add-OverlayFilter -Image $Image2 -Left 0 -Top $Image1.Height -passThru
}
else
{
	echo "Appending file1 to file2 horizontally"

	$Width = $Image1.Width + $Image2.Width
	$Height = $Image1.Height

	echo $Width
	echo $Height
	
	if ($Image1.Height -le $Image2.Height)
	{
		$Height = $Image2.Height
	}
	
	$Filter = Add-ScaleFilter -width $Width -height $Height -doNotPreserveAspectRatio -passThru | 
		Add-OverlayFilter -Image $Image1 -Left 0 -Top 0 -passThru |
		Add-OverlayFilter -Image $Image2 -Left $Image1.Width -Top 0 -passThru
}

$NewImage = Get-Image ".\White.png"

$NewImage = $NewImage | Set-ImageFilter -filter $Filter -passThru

$Path = pwd
echo $Out
$FileName = $Path.Path + "\" + $Out
echo $FileName
$NewImage.SaveFile($FileName)
