$profileDir = Split-Path -parent $profile
$componentDir = Join-Path $profileDir "components"

New-Item $profileDir -ItemType Directory -Force -ErrorAction SilentlyContinue
New-Item $componentDir -ItemType Directory -Force -ErrorAction SilentlyContinue

Copy-Item -Path ./*.ps1 -Destination $profileDir -Exclude "bootstrap.ps1"
Copy-Item -Path ./macros.doskey -Destination $profileDir
Copy-Item -Path ./components/** -Destination $componentDir -Include **
Copy-Item -Path ./home/** -Destination $home -Include **
Copy-Item -Path ./appdata/** -Destination $env:APPDATA -Include ** -Force -Recurse

if (!(Test-Path "HKCU:\Software\Microsoft\Command Processor")) {New-Item -Path "HKCU:\Software\Microsoft\Command Processor" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\Software\Microsoft\Command Processor" "AutoRun" "Doskey /MacroFile=`"$profileDir\macros.doskey`""

$fontCSIDL = 0x14
$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace($fontCSIDL)

Get-ChildItem .\fonts\*.ttf | ForEach-Object{ $objFolder.CopyHere($_.FullName) }

Remove-Variable objFolder
Remove-Variable objShell
Remove-Variable fontCSIDL
Remove-Variable componentDir
Remove-Variable profileDir