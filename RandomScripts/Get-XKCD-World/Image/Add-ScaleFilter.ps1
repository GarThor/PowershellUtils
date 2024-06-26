#requires -version 2.0
function Add-ScaleFilter {    
    <#
        .Synopsis
            Adds a Scale  Filter to a list of filters, or creates a new filter
        .Description
            Adds a Scale Filter to a list of filters, or creates a new filter
        .Example
            $image = Get-Image .\Try.jpg            
            $image = $image | Set-ImageFilter -filter (Add-ScaleFilter -Width 200 -Height 200 -passThru) -passThru                    
            $image.SaveFile("$pwd\Try2.jpg")
        .Parameter image
            Optional.  If set, allows you to specify the crop in terms of a percentage
        .Parameter width
            The new width of the image in pixels (if width is greater than one) or in percent (if width is less than one and image is provided)
        .Parameter height
            The new height of the image in pixels (if height is greater than one) or in percent (if height is less than one and image is provided)
        .Parameter doNotPreserveAspectRatio
            If set, the aspect ratio will not be conserved when resizing
        .Parameter passthru
            If set, the filter will be returned through the pipeline.  This should be set unless the filter is saved to a variable.
        .Parameter filter
            The filter chain that the rotate filter will be added to.  If no chain exists, then the filter will be created
    #>

    param(
    [Parameter(ValueFromPipeline=$true)]
    [__ComObject]
    $filter,
    
    [__ComObject]
    $image,
        
    [Double]$width,
    [Double]$height,
    
    [switch]$DoNotPreserveAspectRatio,
    
    [switch]$passThru                      
    )
    
    process {
        if (-not $filter) {
            $filter = New-Object -ComObject Wia.ImageProcess
        } 
		$index = $filter.Filters.Count + 1
        if (-not $filter.Apply) { return }
        $scale = $filter.FilterInfos.Item("Scale").FilterId                    
        $isPercent = $true
        if ($width -gt 1) { $isPercent = $false }
        if ($height -gt 1) { $isPercent = $false } 
        $filter.Filters.Add($scale)
        $filter.Filters.Item($index).Properties.Item("PreserveAspectRatio") = "$(-not $DoNotPreserveAspectRatio)"
        if ($isPercent -and $image) {
            $filter.Filters.Item($index).Properties.Item("MaximumWidth") = $image.Width * $width
            $filter.Filters.Item($index).Properties.Item("MaximumHeight") = $image.Height * $height
        } else {
            $filter.Filters.Item($index).Properties.Item("MaximumWidth") = $width
            $filter.Filters.Item($index).Properties.Item("MaximumHeight") = $height
        }
        if ($passthru) { return $filter }         
    }
}