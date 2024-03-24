[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True)]
	[string]$Out = "asdf.png"
)


if (Test-Path "temp3")
{
	rm temp3 -Force -Recurse
}

mkdir temp3

cp ".\temp2\Intermediate_928.png" ".\temp3\Intermediate_928.png"

for ($x = 928; $x -le 1107; $x++)
{
	$j = $x - 1;
	echo "**** Stitching **** "

	$File1 = ".\temp3\Intermediate_"+$j+".png"
	$File2 = ".\temp2\Intermediate_"+$x+".png"
	$File3 = ".\temp3\Intermediate_"+$x+".png"

	echo $File1
	echo $File2
	echo $File3
	echo ""

	.\Stitch.ps1 $File1 $File2 -Out $File3
}

cp $File3 $Out


