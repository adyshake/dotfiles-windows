$profileDirPath = Split-Path -parent $profile
$componentDirPath = Join-Path $profileDirPath "components"
$winDirPath = Join-Path $env:WINDIR "System32"
$firefoxDirPath = Join-Path $env:APPDATA "\Mozilla\Firefox\Profiles\*.default"
$firefoxDir = Get-ChildItem $firefoxDirPath

New-Item $profileDirPath -ItemType Directory -Force -ErrorAction SilentlyContinue
New-Item $componentDirPath -ItemType Directory -Force -ErrorAction SilentlyContinue

Copy-Item -Path ./*.ps1 -Destination $profileDirPath -Force -Exclude "bootstrap.ps1"
Copy-Item -Path ./psh64.exe -Destination $winDirPath/psh.exe -Force
Copy-Item -Path ./macros.doskey -Destination $profileDirPath -Force
Copy-Item -Path ./fonts -Destination $profileDirPath -Force -Recurse
Copy-Item -Path ./scripts/** -Destination $profileDirPath -Force -Include ** -Recurse
Copy-Item -Path ./utils/** -Destination $profileDirPath -Force -Include ** -Recurse
Copy-Item -Path ./components/** -Destination $componentDirPath -Force -Include **
Copy-Item -Path ./home/** -Destination $home -Force -Include **
Copy-Item -Path ./appdata/** -Destination $env:APPDATA -Include ** -Force -Recurse
Copy-Item -Path ./firefox/** -Destination $firefoxDir -Include ** -Force -Recurse

if (!(Test-Path "HKCU:\Software\Microsoft\Command Processor")) {New-Item -Path "HKCU:\Software\Microsoft\Command Processor" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\Software\Microsoft\Command Processor" "AutoRun" "Doskey /MacroFile=`"$profileDirPath\macros.doskey`""

Remove-Variable firefoxDir
Remove-Variable firefoxDirPath
Remove-Variable winDirPath
Remove-Variable componentDirPath
Remove-Variable profileDirPath