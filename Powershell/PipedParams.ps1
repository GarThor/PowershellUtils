param (
	[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
	[string] $inst = $null
)

Process {
	if ($PSCmdlet.ShouldProcess("$inst","Return Database Options"))        
	{
		foreach ($svr in $inst)
		{
			write-output "Do stuff on server `$inst = $inst"
		}
	}
}