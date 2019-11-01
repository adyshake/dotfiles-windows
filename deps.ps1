# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);
 
    exit
 }
 
### Install PowerShell Modules
Write-Host "Installing PowerShell Modules..." -ForegroundColor "Yellow"
$installedModules = Get-InstalledModule
if ( $null -ne $installedModules -and $installedModules.Name.Contains("posh-git") ) {
    Write-Host "posh-git is already installed"
} else {
    Install-Module Posh-Git -Scope CurrentUser -Force
}

### Scoop, for Command Line utilities
Write-Host "Installing Command Line Utilities..." -ForegroundColor "Yellow"
if ($null -eq (which scoop)) {
    Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')
}

scoop install coreutils
scoop install git
scoop install grep
scoop install vim

scoop bucket add extras
scoop install goldendict

scoop bucket add java
scoop install adoptopenjdk-lts-hotspot

Refresh-Environment

### Chocolatey
Write-Host "Installing Desktop Utilities..." -ForegroundColor "Yellow"
if ($null -eq (which cinst)) {
    Invoke-Expression (new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')
    Refresh-Environment
    choco feature enable -n=allowGlobalConfirmation
}

if ($False -ne (Test-Path -Path "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe")) {
    Write-Host "Chrome is already installed"
} else {
    choco install GoogleChrome          --limit-output	
    choco pin add --name GoogleChrome   --limit-output
}

if ($False -ne (Test-Path -Path "$env:ProgramFiles\Microsoft VS Code\code.exe")) {
    Write-Host "VS Code is already installed"
} else {
    choco install vscode                --limit-output
    choco pin add --name vscode         --limit-output
    Refresh-Environment
}

code --install-extension stkb.rewrap

if ($False -ne (Test-Path -Path "$env:ProgramFiles\VideoLAN\VLC\vlc.exe")) {
    Write-Host "VLC is already installed"
} else {
    choco install vlc                   --limit-output
}

if ($False -ne (Test-Path -Path "$env:ProgramFiles\qBittorrent\qbittorrent.exe")) {
    Write-Host "qBittorrent is already installed"
} else {
    choco install qbittorrent           --limit-output
}

if ($False -ne (Test-Path -Path "$env:ProgramFiles\7-Zip\7zFM.exe")) {
    Write-Host "7zip is already installed"
} else {
    choco install 7zip                  --limit-output
}

Refresh-Environment
