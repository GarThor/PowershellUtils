
if (Test-Path "temp")
{
	rm temp -Force -Recurse
}
else
{
}

if (Test-Path "temp2")
{
	rm temp2 -Force -Recurse
}

mkdir temp
mkdir temp2

$StartX = 928
$EndX	= 1108

$StartY = 1069
$EndY	= 1111

$y = $StartY
$x = $StartX

for ($x = $StartX; $x -le $EndX; $x++)
{
	$File1 = ".\XKCD\XKCD_"+$x+"_"+$y+".png"
	$File2 = ".\temp\temp_"+$x+"_"+$y+".png"

	if (!(Test-Path $File2))
	{
		if (Test-Path $File1)
		{
			echo "Copying: "
			echo $File1 + " to "
			echo $File2
			
			cp $File1 $File2
		}
		else
		{
			echo "Copying: "
			echo ".\White.png to "
			echo $File2
			
			cp ".\White.png" $File2
		}
	}

	for ($y = $StartY; $y -le $EndY; $y++)
	{
		$j = $y + 1;
		echo "Stitching: "
		$File1 = ".\XKCD\XKCD_"+$x+"_"+$j+".png"
		$File2 = ".\temp\temp_"+$x+"_"+$y+".png"
		$File3 = ".\temp\temp_"+$x+"_"+$j+".png"

		echo $File1
		echo $File2
		echo $File3
		echo ""
		
		.\Stitch.ps1 $File1 $File2 -Vertical -Out $File3
	}
	
	$y = $StartY
	
	cp $File3 ".\temp2\Intermediate_$x.png"
	rm ".\temp\temp*.png"
}

