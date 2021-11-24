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
scoop install python
scoop install grep
scoop install vim
scoop install adb
scoop install latex
scoop install perl
scoop install ffmpeg
scoop install dos2unix
scoop install nodejs
scoop install youtube-dl
scoop install sqlite
scoop install jq

# Install common python modules
python -m pip install numpy pandas requests pillow matplotlib beautifulsoup4 scipy tqdm

scoop bucket add extras
scoop install goldendict
scoop install WinDirStat
scoop install handbrake
scoop install imagemagick

scoop bucket add java
scoop install corretto-jdk

Refresh-Environment

### Chocolatey
Write-Host "Installing Desktop Utilities..." -ForegroundColor "Yellow"
if ($null -eq (which cinst)) {
    Invoke-Expression (new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')
    Refresh-Environment
    choco feature enable -n=allowGlobalConfirmation
}

if ($False -ne (Test-Path -Path "${env:ProgramFiles}\Mozilla Firefox\firefox.exe")) {
    Write-Host "Firefox is already installed"
} else {
    choco install firefox               --limit-output
    # Launch Firefox once so that it can generate the profile directory
    Start-Process "${env:ProgramFiles}\Mozilla Firefox\firefox.exe"
    Start-Sleep -Seconds 5
    $firefoxDirPath = Join-Path $env:APPDATA "\Mozilla\Firefox\Profiles\*.default-release"
    $firefoxDir = Get-ChildItem $firefoxDirPath -ErrorAction SilentlyContinue
    if($null -eq $firefoxDir) {
        Write-Host "Skipping Firefox config because it is not installed" -ForegroundColor Red
    }
    else {
        Copy-Item -Path ./firefox/** -Destination $firefoxDir -Include ** -Force -Recurse
        Write-Host  "Copied Firefox config"
    }
    Remove-Variable firefoxDir
    Remove-Variable firefoxDirPath
}

if ($False -ne (Test-Path -Path "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe")) {
    Write-Host "Chrome is already installed"
} else {
    choco install GoogleChrome          --limit-output
}

if ($False -ne (Test-Path -Path "${env:ProgramFiles}\IrfanView\i_view64.exe")) {
    Write-Host "IrfanView is already installed"
} else {
    choco install irfanview             --limit-output
    choco install ghostscript           --limit-output
    choco install irfanviewplugins      --limit-output
}

if ($False -ne (Test-Path -Path "$env:ProgramFiles\Microsoft VS Code\code.exe")) {
    Write-Host "VS Code is already installed"
} else {
    choco install vscode                --limit-output
    Refresh-Environment
}

# Run this to list currently installed extensions
# code --list-extensions | % { "code --install-extension $_" }

code --install-extension ban.spellright
code --install-extension GrapeCity.gc-excelviewer
code --install-extension James-Yu.latex-workshop
code --install-extension mechatroner.rainbow-csv
code --install-extension monokai.theme-monokai-pro-vscode
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-vscode.cpptools
code --install-extension ms-vscode.powershell
code --install-extension stkb.rewrap

# Run this to list currently install choco apps
# choco list -local-only

if ($False -ne (Test-Path -Path "$env:ProgramFiles\VideoLAN\VLC\vlc.exe")) {
    Write-Host "VLC is already installed"
} else {
    choco install vlc                   --limit-output
}

# Uninstall Windows Store Spotify
Get-AppxPackage "SpotifyAB.SpotifyMusic" -AllUsers | Remove-AppxPackage
Get-AppXProvisionedPackage -Online | Where-Object DisplayNam -like "SpotifyAB.SpotifyMusic" | Remove-AppxProvisionedPackage -Online

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

if ($False -ne (Test-Path -Path "$env:LocalAppData\Discord\app-*\Discord.exe")) {
    Write-Host "Discord is already installed"
} else {
    choco install Discord               --limit-output
}

choco install coretemp --limit-output
$coretempDir = Get-ChildItem (Join-Path $env:ProgramData "\chocolatey\lib\coretemp\tools") -ErrorAction SilentlyContinue
if($null -eq $coretempDir) {
    Write-Host "Skipping coretemp config because it is not installed" -ForegroundColor Red
}
else {
    Copy-Item -Path ./misc_app_data/coretemp/** -Destination $coretempDir -Include ** -Force -Recurse
    Write-Host  "Copied coretemp config"
}

choco install ditto --limit-output
# Import Ditto settings
reg import .\misc_app_data\ditto\ditto_settings.reg

choco install protonvpn --limit-output
choco install yubico-authenticator --limit-output
choco install obs-studio --limit-output

# Pin apps to the taskbar
Import-StartLayout -LayoutPath .\taskbar_configuration.xml -MountPath $env:SystemDrive\

# Restart explorer.exe
Stop-Process -ProcessName explorer

Refresh-Environment

Remove-Item "$env:USERPROFILE\Desktop\*lnk" -Force
Remove-Item "$env:PUBLIC\Desktop\*lnk" -Force
