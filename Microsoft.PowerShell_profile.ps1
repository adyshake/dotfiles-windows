# Profile for the Microsoft.Powershell Shell, only. (Not Visual Studio or other PoSh instances)
# ===========

Push-Location (Split-Path -parent $profile)
"components-shell" | ForEach-Object -process {Invoke-Expression ". .\$_.ps1"}
Pop-Location