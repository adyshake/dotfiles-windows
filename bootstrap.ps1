function Verify-Elevated {
    # Get the ID and security principal of the current user account
    $myIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myPrincipal=new-object System.Security.Principal.WindowsPrincipal($myIdentity)
    # Check to see if we are currently running "as Administrator"
    return $myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
    Start-Process powershell -Verb runAs -ArgumentList @("-NoExit", "-Command `"cd `'$(([string](Get-Location)).TrimEnd('\'))`'; $($myInvocation.MyCommand.Definition)`"")
    exit
 }

$profileDirPath = Split-Path -parent $profile
$componentDirPath = Join-Path $profileDirPath "components"
$vimDirPath = Join-Path $home "vimfiles"
$vimLinkDirPath = Join-Path $home ".vim"
$winDirPath = Join-Path $env:WINDIR "System32"
$firefoxDirPath = Join-Path $env:APPDATA "\Mozilla\Firefox\Profiles\*.default"
$firefoxDir = Get-ChildItem $firefoxDirPath -ErrorAction SilentlyContinue

New-Item $profileDirPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
New-Item $componentDirPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
New-Item $vimDirPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $vimLinkDirPath -ItemType SymbolicLink -Value $vimDirPath -Force -ErrorAction SilentlyContinue | Out-Null

Copy-Item -Path ./*.ps1 -Destination $profileDirPath -Force -Exclude "bootstrap.ps1"
Write-Host  "Copied all profiles"
Copy-Item -Path ./psh64.exe -Destination $winDirPath/psh.exe -Force
Write-Host  "Copied psh.exe"
Copy-Item -Path ./macros.doskey -Destination $profileDirPath -Force
Write-Host  "Copied cmd macros"
Copy-Item -Path ./fonts -Destination $profileDirPath -Force -Recurse
Write-Host  "Copied fonts"
Copy-Item -Path ./scripts/** -Destination $profileDirPath -Force -Include ** -Recurse
Write-Host  "Copied scripts"
Copy-Item -Path ./utils/** -Destination $profileDirPath -Force -Include ** -Recurse
Write-Host  "Copied utils"
Copy-Item -Path ./components/** -Destination $componentDirPath -Force -Include **
Write-Host  "Copied components"
Copy-Item -Path ./home/** -Destination $home -Force -Include **
Write-Host  "Copied home"
Copy-Item -Path ./appdata/** -Destination $env:APPDATA -Include ** -Force -Recurse
Write-Host  "Copied appdata"
Copy-Item -Path ./vim/** -Destination $vimDirPath -Include ** -Force -Recurse
Write-Host  "Copied vim dotfiles"
if($null -eq $firefoxDir) {
    Write-Host "Skipping Firefox config because it is not installed" -ForegroundColor Red
}
else {
    Copy-Item -Path ./firefox/** -Destination $firefoxDir -Include ** -Force -Recurse
    Write-Host  "Copied Firefox config"
}

if (!(Test-Path "HKCU:\Software\Microsoft\Command Processor")) {New-Item -Path "HKCU:\Software\Microsoft\Command Processor" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\Software\Microsoft\Command Processor" "AutoRun" "Doskey /MacroFile=`"$profileDirPath\macros.doskey`""
Write-Host  "Wrote cmd macros registry entry"

Remove-Variable firefoxDir
Remove-Variable firefoxDirPath
Remove-Variable winDirPath
Remove-Variable componentDirPath
Remove-Variable profileDirPath

Write-Host "Copied files. Press enter to close" 
$Host.UI.ReadLine()