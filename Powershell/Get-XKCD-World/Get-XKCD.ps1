
mkdir XKCD

for ($y = -1112; $y -le -928; $y++)
{
	for ($x = 928; $x -le 1108; $x++)
	{
		$url = "http://xkcd.com/1608/" + $x + ":" + $y + "+s.png"
		
		echo $url
		
		$j = $y * -1
		
		$path = "XKCD\XKCD_"+$x+"_"+$j+".png"
		
		echo $path
		
		Invoke-WebRequest $url -OutFile $path
	}
}