# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);
 
    exit
 }

 ### Update Help for Modules
 Write-Host "Updating Help..." -ForegroundColor "Yellow"
 Update-Help -Force
 
'''
### Package Providers
Write-Host "Installing Package Providers..." -ForegroundColor "Yellow"
Get-PackageProvider NuGet -Force | Out-Null
# Chocolatey Provider is not ready yet. Use normal Chocolatey
#Get-PackageProvider Chocolatey -Force
#Set-PackageSource -Name chocolatey -Trusted
'''

### Install PowerShell Modules
Write-Host "Installing PowerShell Modules..." -ForegroundColor "Yellow"
Install-Module Posh-Git -Scope CurrentUser -Force
Install-Module PSWindowsUpdate -Scope CurrentUser -Force

### Scoop, for Command Line utilities
Write-Host "Installing Command Line Utilities..." -ForegroundColor "Yellow"
if ($null -eq (which scoop)) {
    Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')
}

scoop install coreutils
scoop install curl
scoop install git
scoop install grep
scoop install wget
scoop install ruby
scoop install msys2
#scoop install vim
#scoop install openssh
#scoop install nvm

Refresh-Environment

### Set up Ruby and bundler
ridk install
gem install bundler

### Chocolatey
Write-Host "Installing Desktop Utilities..." -ForegroundColor "Yellow"
if (null -eq (which cinst)) {
    Invoke-Expression (new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')
    Refresh-Environment
    choco feature enable -n=allowGlobalConfirmation
}

choco install vim                   --limit-output

choco install GoogleChrome          --limit-output
choco pin add --name GoogleChrome   --limit-output

choco install vscode                --limit-output
choco pin add --name vscode         --limit-output
Refresh-Environment
code --install-extension stkb.rewrap

choco install vlc                   --limit-output

choco install qbittorrent           --limit-output

choco install rufus                 --limit-output

choco install winrar                 --limit-output

Refresh-Environment

'''
nvm on
$nodeLtsVersion = choco search nodejs-lts --limit-output | ConvertFrom-String -TemplateContent "{Name:package-name}\|{Version:1.11.1}" | Select -ExpandProperty "Version"
nvm install $nodeLtsVersion
nvm use $nodeLtsVersion
Remove-Variable nodeLtsVersion

gem pristine --all --env-shebang


### Windows Features
Write-Host "Installing Windows Features..." -ForegroundColor "Yellow"
# IIS Base Configuration
Enable-WindowsOptionalFeature -Online -All -FeatureName `
    "IIS-BasicAuthentication", `
    "IIS-DefaultDocument", `
    "IIS-DirectoryBrowsing", `
    "IIS-HttpCompressionDynamic", `
    "IIS-HttpCompressionStatic", `
    "IIS-HttpErrors", `
    "IIS-HttpLogging", `
    "IIS-ISAPIExtensions", `
    "IIS-ISAPIFilter", `
    "IIS-ManagementConsole", `
    "IIS-RequestFiltering", `
    "IIS-StaticContent", `
    "IIS-WebSockets", `
    "IIS-WindowsAuthentication" `
    -NoRestart | Out-Null

# ASP.NET Base Configuration
Enable-WindowsOptionalFeature -Online -All -FeatureName `
"NetFx3", `
"NetFx4-AdvSrvs", `
"NetFx4Extended-ASPNET45", `
"IIS-NetFxExtensibility", `
"IIS-NetFxExtensibility45", `
"IIS-ASPNET", `
"IIS-ASPNET45" `
-NoRestart | Out-Null

# Web Platform Installer for remaining Windows features
webpicmd /Install /AcceptEula /Products:"UrlRewrite2"
#webpicmd /Install /AcceptEula /Products:"NETFramework452"
webpicmd /Install /AcceptEula /Products:"Python279"

### Node Packages
Write-Host "Installing Node Packages..." -ForegroundColor "Yellow"
if (which npm) {
    npm update npm
    npm install -g gulp
    npm install -g mocha
    npm install -g node-inspector
    npm install -g yo
}

### Janus for vim
Write-Host "Installing Janus..." -ForegroundColor "Yellow"
if ((which curl) -and (which vim) -and (which rake) -and (which bash)) {
    curl.exe -L https://bit.ly/janus-bootstrap | bash
}
'''

### Visual Studio Plugins
if (which Install-VSExtension) {
    ### Visual Studio 2015
    # VsVim
    # Install-VSExtension https://visualstudiogallery.msdn.microsoft.com/59ca71b3-a4a3-46ca-8fe1-0e90e3f79329/file/6390/57/VsVim.vsix
    # Productivity Power Tools 2015
    # Install-VSExtension https://visualstudiogallery.msdn.microsoft.com/34ebc6a2-2777-421d-8914-e29c1dfa7f5d/file/169971/1/ProPowerTools.vsix
}