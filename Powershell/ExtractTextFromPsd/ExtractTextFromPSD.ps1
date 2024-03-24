[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True)]
	[string]$InFile = "asdf.png",

	[Parameter(Mandatory=$True)]
	[string]$OutFile = "asdf.png"
)

if (!(Test-Path $InFile)) {
    Write-Error "IN FILE DOES NOT EXIST: TRY AGAIN!"
    return -1;   
}

if (Test-Path $OutFile) {
    $title = 'warning'
    $msg = "Do you want to overwrite $OutFile?"
    $options = '&Yes', '&No'
    $default = 1 # 0 = yes, 1 = No
    $response = $Host.UI.PromptForChoice($title, $msg, $options, $default);
    if ($response -eq 1) {
        Write-Error "Out File Already Exists, User selected not to overwrite!"     
    }

    "" | Out-File -FilePath $OutFile  -NoNewline -Encoding default;
}

$content = Get-Content $InFile

foreach ($line in $content) {
    if ($line -match "< photoshop : LayerName>(?<text>.+)") {
        $line | Out-File -FilePath $OutFile -Append -Encoding default
    }
}