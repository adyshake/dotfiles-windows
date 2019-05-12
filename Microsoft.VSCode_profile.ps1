# Profile for the Microsoft.VSCode Shell, only. (Not Visual Studio or other PoSh instances)
# ===========

Push-Location (Split-Path -parent $profile)
"components-shell", "components" | ForEach-Object -process {Invoke-Expression ". .\$_.ps1"}
Pop-Location