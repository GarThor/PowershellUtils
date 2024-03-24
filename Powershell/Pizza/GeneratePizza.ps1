<#  
    .Synopsis  
#>
[CmdletBinding()]  
param(
    [String]$Ingredients = ".\mod-pizza-ingredients.psm1",
    [Int]$SauceCount = 2,
    [Int]$CheeseCount = 3,
    [Int]$MeatCount = 4,
    [Int]$VegieCount = 5,
    [Int]$FinishingSauceCount = 1
)

Import-Module -Name $Ingredients -Variable "Bases","Sauces","Cheeses","Meats","Vegies","FinishingSauces";

$myBases = Get-Random -InputObject $Bases;
[String[]]$mySauces = @();
for ([Int]$idx = 0; $idx -lt $SauceCount; $idx++)
{
    $mySauces += Get-Random -InputObject $Sauces;
}

[String[]]$myCheeses = @();
for ([Int]$idx = 0; $idx -lt $CheeseCount; $idx++)
{
    $myCheeses += Get-Random -InputObject $Cheeses;
}

[String[]]$myMeats = @();
for ([Int]$idx = 0; $idx -lt $MeatCount; $idx++)
{
    $myMeats += Get-Random -InputObject $Meats;
}

[String[]]$myVegies = @();
for ([Int]$idx = 0; $idx -lt $VegieCount; $idx++)
{
    $myVegies += Get-Random -InputObject $Vegies;
}

[String[]]$myFinishers = @();
for ([Int]$idx = 0; $idx -lt $FinishingSauceCount; $idx++)
{
    $myFinishers += Get-Random -InputObject $FinishingSauces;
}

Write-Host "Your Pizza is a $myBases with $($mySauces -join ", ") and $($myCheeses -join ", ").";
Write-Host "`tTopped With: $($myMeats -join ", ") and $($myVegies -join ", ").";
Write-Host "`tAnd Finished With: $($myFinishers -join ", ")."
