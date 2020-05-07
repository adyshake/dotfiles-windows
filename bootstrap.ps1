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

# Create Johnny Decimal Folders
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\JD\10-19_Projects"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\JD\10-19_Projects\11_Github"

New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\JD\20-29_Media"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\JD\20-29_Media\32_Identification"

New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\JD\30-39_Documents"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\JD\40-49_University"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\JD\50-59_Youtube"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\JD\60-69_Software"

$profileDirPath = Split-Path -parent $profile
$vimDirPath = Join-Path $home "vimfiles"
$vimLinkDirPath = Join-Path $home ".vim"
$winDirPath = Join-Path $env:WINDIR "System32"
$firefoxDirPath = Join-Path $env:APPDATA "\Mozilla\Firefox\Profiles\*.default"
$firefoxDir = Get-ChildItem $firefoxDirPath -ErrorAction SilentlyContinue

New-Item $profileDirPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
New-Item $vimDirPath -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -Path $vimLinkDirPath -ItemType SymbolicLink -Value $vimDirPath -Force -ErrorAction SilentlyContinue | Out-Null

#TODO - Remove old profiles
#TODO - Remove psh64
#TODO - Remove hosts
#TODO - Remove home
#TODO - Remove appdata
#TODO - Remove vim
#TODO - Remove firefox

Copy-Item -Path ./*.ps1 -Destination $profileDirPath -Force -Exclude "bootstrap.ps1"
Write-Host  "Copied all profiles"
if ([Environment]::Is64BitOperatingSystem -eq $True) {
    Copy-Item -Path ./psh64.exe -Destination $winDirPath/psh.exe -Force
} else {
    Copy-Item -Path ./psh32.exe -Destination $winDirPath/psh.exe -Force
}
Write-Host  "Copied psh.exe"
Copy-Item -Path ./macros.doskey -Destination $profileDirPath -Force
Write-Host  "Copied cmd macros"
Copy-Item -Path ./hosts -Destination $env:windir\System32\drivers\etc\ -Force
Write-Host  "Copied hosts file"
Copy-Item -Path ./fonts -Destination $profileDirPath -Force -Recurse
Write-Host  "Copied fonts"
Copy-Item -Path ./dicts -Destination $profileDirPath -Force -Recurse
Write-Host  "Copied dicts"
Copy-Item -Path ./user_scripts -Destination $profileDirPath -Force -Include ** -Recurse
Write-Host  "Copied user scripts"
Copy-Item -Path ./utils -Destination $profileDirPath -Force -Include ** -Recurse
Write-Host  "Copied utils"
Copy-Item -Path ./components -Destination $profileDirPath -Force -Include ** -Recurse
Write-Host  "Copied components"
Copy-Item -Path ./home/** -Destination $home -Force -Include ** -Recurse
Write-Host  "Copied home"
Copy-Item -Path ./appdata/** -Destination $env:APPDATA -Include ** -Force -Recurse
#TODO - Replace USER_PATH_WITH_BACKSLASHES with C:\Users\adnan
#TODO - Replace USER_PATH_WITH_FORWARDSLASHES with C:/Users/adnan
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
Remove-Variable profileDirPath

Write-Host "Copied files"

$installGPU = Read-Host "Register Raden RX 590 GPU switcher task? (y/n)"

if ($installGPU -eq 'y') {
    $taskName = "GPU switcher"
    $userName = $env:UserName

    $password = Read-Host "Password"

    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -Erroraction SilentlyContinue

    $profileDirPath = Split-Path -parent $profile
    $gpuScript = Join-Path $profileDirPath "gpu_switcher.ps1"
    $action = New-ScheduledTaskAction -Execute powershell.exe -Argument "`"$gpuScript`""
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

    Register-ScheduledTask -Action $action -TaskName $taskName -Settings $settings  -Description "Switches to the Radeon RX 590 eGPU when plugged in" -User $userName -Password $password

    # Now add a special trigger to it with COM API.
    # Get the service and task
    $ts = New-Object -ComObject Schedule.Service
    $ts.Connect()
    $task = $ts.GetFolder("\").GetTask($taskName).Definition

    # Create the trigger
    $TRIGGER_TYPE_STARTUP=8
    $startTrigger=$task.Triggers.Create($TRIGGER_TYPE_STARTUP)
    $startTrigger.Enabled=$true
    $startTrigger.Id="StartupTrigger"

    # Re-save the task in place.
    $TASK_CREATE_OR_UPDATE=6
    $TASK_LOGIN_PASSWORD=1
    $ts.GetFolder("\").RegisterTaskDefinition($taskName, $task, $TASK_CREATE_OR_UPDATE, $userName, $password, $TASK_LOGIN_PASSWORD)

    Start-ScheduledTask -TaskName $taskName
}

#Unblock files
Get-ChildItem -Path $profileDirPath -Recurse | Unblock-File

Write-Host "Press enter to close" 
$Host.UI.ReadLine()