param(
    [string]$Filter,
    [string]$OutputFile,
    [int]$NumJobs
)
Write-Output "" | Out-File $OutputFile;
$files = Get-ChildItem -Recurse -Filter:$Filter | Sort-Object -Property Length -Descending;

$hashScript = {
    param(
        $file,$OutputFile
    )
    try {
        $hash = (Get-FileHash $file.FullName -Algorithm MD5).hash; 
        $size = (Get-item $file.FullName).Length; 
        Write-Host "Done Hashing: '$($file.FullName)' to '$OutputFile'"
        return "$hash,$($file.FullName),$size"
    }
    catch {
        Write-Error "error on file: $($file.FullName)"
        Write-Error "error message: $($_.Exception.Message)"
    }
};

foreach ($file in $files) {
    $jobs = Get-Job
    if ($jobs.Count -gt $NumJobs) {
        $job_complete = Wait-Job -Any $jobs
        $text = Receive-Job $job_complete
        Write-Host $text
        Write-Output $text | Out-File $OutputFile -Append;
        Remove-Job $job_complete
    }

    Start-Job -ScriptBlock $hashScript -ArgumentList $file,$OutputFile
}