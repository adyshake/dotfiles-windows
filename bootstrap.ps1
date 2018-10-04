$profileDir = Split-Path -parent $profile
$componentDir = Join-Path $profileDir "components"
$winDir = Join-Path $env:WINDIR "System32"

New-Item $profileDir -ItemType Directory -Force -ErrorAction SilentlyContinue
New-Item $componentDir -ItemType Directory -Force -ErrorAction SilentlyContinue

Copy-Item -Path ./*.ps1 -Destination $profileDir -Force -Exclude "bootstrap.ps1"
Copy-Item -Path ./psh64.exe -Destination $winDir/psh.exe -Force
Copy-Item -Path ./macros.doskey -Destination $profileDir -Force
Copy-Item -Path ./fonts -Destination $profileDir -Force -Recurse
Copy-Item -Path ./components/** -Destination $componentDir -Force -Include **
Copy-Item -Path ./home/** -Destination $home -Force -Include **
Copy-Item -Path ./appdata/** -Destination $env:APPDATA -Include ** -Force -Recurse

if (!(Test-Path "HKCU:\Software\Microsoft\Command Processor")) {New-Item -Path "HKCU:\Software\Microsoft\Command Processor" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\Software\Microsoft\Command Processor" "AutoRun" "Doskey /MacroFile=`"$profileDir\macros.doskey`""

Remove-Variable componentDir
Remove-Variable profileDir