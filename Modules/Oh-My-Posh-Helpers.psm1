$script:CurrentTheme = "";
$script:DefaultTheme = "Jandedobbeleer.omp";
$script:ThemeStack = New-Object System.Collections.Stack;

function Find-Themes {   
    [CmdletBinding()]  
    param (
        [string]$Path = $ENV:POSH_THEMES_PATH
    )

    $themes = Get-ChildItem "$ENV:POSH_THEMES_PATH\*.omp.*" | Where-Object { ($_.extension -eq ".json") -or ($_.extension -eq ".yaml") };
    $themes.BaseName;
}

function Set-Theme {
    [CmdletBinding()]  
    param (
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
                Find-Themes | Where-Object { $_.StartsWith($wordToComplete) };
            } )]
        [ValidateScript({ (Test-Path "$ENV:POSH_THEMES_PATH\$_.json") -or (Test-Path "$ENV:POSH_THEMES_PATH\$_.yaml") })]  
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Theme
    )

    if (Test-Path "$ENV:POSH_THEMES_PATH\$Theme.json") {
        oh-my-posh init powershell --config "$ENV:POSH_THEMES_PATH\$Theme.json" | Invoke-Expression
    }
    elseif (Test-Path "$ENV:POSH_THEMES_PATH\$Theme.yaml") {
        oh-my-posh init powershell --config "$ENV:POSH_THEMES_PATH\$Theme.yaml" | Invoke-Expression
    }
    $script:CurrentTheme = $Theme;
}

function Get-Theme {
    return $script:CurrentTheme
}

function Push-Theme {
    [CmdletBinding()]  
    param (
        [ArgumentCompleter( {
                param ( $commandName,
                    $parameterName,
                    $wordToComplete,
                    $commandAst,
                    $fakeBoundParameters )
                Find-Themes | Where-Object { $_.StartsWith($wordToComplete) };
            } )]
        [ValidateScript({ (Test-Path "$ENV:POSH_THEMES_PATH\$_.json") -or (Test-Path "$ENV:POSH_THEMES_PATH\$_.yaml") })]  
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Theme
    )

    if ($null -eq $script:ThemeStack) {
        $script:ThemeStack = New-Object System.Collections.Stack;
    }
    
    if ($script:ThemeStack.Count -eq 0) {
        if ($null -eq $script:CurrentTheme -or "" -eq $script:CurrentTheme) {
            $script:ThemeStack.Push($script:DefaultTheme);
        }
        else {
            $script:ThemeStack.Push($script:CurrentTheme);
        }
    }

    Set-Theme $Theme;
    $script:ThemeStack.Push($Theme);
}
function Pop-Theme {
    [CmdletBinding()]  
    param (
    )

    if ($null -eq $script:ThemeStack) {
        $script:ThemeStack = New-Object System.Collections.Stack;
    }

    if ($script:ThemeStack.Count -gt 0) {
        $script:ThemeStack.Pop() | out-null;
        Set-Theme $script:ThemeStack.Peek();
    }
    else {
        throw { "Error: no more themes on stack!" }
    }
}
function Get-ThemeStack {
    return $script:ThemeStack;
}

Export-ModuleMember -Function *;