# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);
 
    exit
 }

###############################################################################
### Security and Identity                                                     #
###############################################################################
Write-Host "Configuring System..." -ForegroundColor "Yellow"

# Set Computer Name
$computerName = Read-Host "Please name your computer (Example: adnan-rbs13)"
(Get-WmiObject Win32_ComputerSystem).Rename($computerName) | Out-Null

# Set DisplayName for my account. Use only if you are not using a Microsoft Account
# $myIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
# $user = Get-WmiObject Win32_UserAccount | Where-Object {$_.Caption -eq $myIdentity.Name}
# $user.FullName = "Adnan Shaikh"
# $user.Put() | Out-Null
# Remove-Variable user
# Remove-Variable myIdentity

###############################################################################
### Privacy                                                                   #
###############################################################################
Write-Host "Configuring Privacy..." -ForegroundColor "Yellow"

# Feedback: Windows should never ask for my feedback
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf" -Type Folder | Out-Null}
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" 0

# Feedback: Telemetry: Send Diagnostic and usage data: Basic: 1, Enhanced: 2, Full: 3
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" 1

###############################################################################
### Devices, Power, and Startup                                               #
###############################################################################
Write-Host "Configuring Devices, Power, and Startup..." -ForegroundColor "Yellow"

# Sound: Disable Startup Sound
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableStartupSound" 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" "DisableStartupSound" 1

# Power: Disable Hibernation
powercfg /hibernate off

# Set to balanced mode by default

# Power: Set monitor and sleep options
powercfg /X monitor-timeout-ac 30
powercfg /X standby-timeout-ac 0

powercfg /X monitor-timeout-dc 5
powercfg /X standby-timeout-dc 60

# Power: Disable sleep on lid close
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0

# Switch to high performance power mode
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Power: Set monitor and sleep options
powercfg /X monitor-timeout-ac 60
powercfg /X standby-timeout-ac 0

powercfg /X monitor-timeout-dc 10
powercfg /X standby-timeout-dc 60

# Power: Disable sleep on lid close
powercfg -setacvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg -setdcvalueindex 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0


# SSD: Disable SuperFetch
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnableSuperfetch" 0

# Network: Disable WiFi Sense
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" "AutoConnectAllowedOEM" 0

###############################################################################
### Windows Security                                                          #
###############################################################################

# Disable Windows Security
Write-Host "Please disable Tamper Protection from Windows Security within the Settings app and then press Enter to continue" -NoNewLine
$Host.UI.ReadLine()

Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableEmailScanning $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -MAPSReporting 0
Set-MpPreference -DisableCatchupFullScan $true
Set-MpPreference -DisableBehaviorMonitoring $true
Set-MpPreference -DisableArchiveScanning $true
Set-MpPreference -SubmitSamplesConsent 3

if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows Defender\Real-Time Protection")) {New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" -Type Folder | Out-Null}
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 1

# Run this command to get all system environment variables
# Get-ChildItem Env: | Sort-Object Name

# Get-MpPreference to list exclusions

Add-MpPreference -ExclusionPath "$env:HOME\.gradle"
Add-MpPreference -ExclusionPath "$env:HOME\AndroidStudioProjects\Project_Directory"
Add-MpPreference -ExclusionPath "$env:HOME\AppData\Local\Android\SDK"
Add-MpPreference -ExclusionPath "$env:HOME\AppData\Local\JetBrains"
Add-MpPreference -ExclusionPath "$env:HOME\IdeaProjects"
Add-MpPreference -ExclusionPath "$env:HOME\JD"
Add-MpPreference -ExclusionPath "$env:HOME\scoop"
Add-MpPreference -ExclusionPath "$env:HOME\Desktop"
Add-MpPreference -ExclusionPath "$env:ProgramFiles\Android\Android Studio"
Add-MpPreference -ExclusionPath "$env:ProgramFiles\Adobe"
Add-MpPreference -ExclusionPath "${env:ProgramFiles(x86)}\Adobe"
Add-MpPreference -ExclusionPath "$env:SystemDrive\Games"

###############################################################################
### Explorer, Taskbar, and System Tray                                        #
###############################################################################
Write-Host "Configuring Explorer, Taskbar, and System Tray..." -ForegroundColor "Yellow"

# Ensure necessary registry paths
if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Type Folder | Out-Null}
if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState")) {New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Type Folder | Out-Null}
if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search")) {New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Type Folder | Out-Null}

# Explorer: Show hidden files by default: Show Files: 1, Hide Files: 2
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1

# Explorer: Show file extensions by default
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

# Explorer: Open File Explorer to: This PC: 1, Quick Access: 2 
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "LaunchTo" 1

# Explorer: Show recently recently used files in Quick access: Show: 1, Hide: 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "ShowRecent" 0

# Explorer: Show recently recently used folder in Quick access: Show: 1, Hide: 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "ShowFrequent" 0

# Explorer: Show path in title bar
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" "FullPath" 1

# Explorer: Avoid creating Thumbs.db files on network volumes
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableThumbnailsOnNetworkFolders" 1

# Taskbar: Disable Bing Search
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0 # For Windows 10

# Taskbar: Disable Cortana
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0

# Disable Sticky Keys
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Type String -Value "58"
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Type String -Value "122"

# Sync Settings: Disable automatically syncing settings with other Windows 10 devices
# Theme
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" "Enabled" 0
# Passwords
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" "Enabled" 0
# Language
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" "Enabled" 0
# Accessibility / Ease of Access
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" "Enabled" 0
# Other Windows Settings
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" "Enabled" 0

# Set dark theme
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0

# Hide AMD's context menu item "AMD Radeon Software"
If (Test-Path "Registry::HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\ACE") {
    Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\Background\shellex\ContextMenuHandlers\ACE" -Recurse
}

# Add username folder to shortcut sidebar
$shellObject = New-Object -com shell.application
$shellObject.Namespace("$env:USERPROFILE").Self.InvokeVerb("pintohome")
$shellObject.Namespace("$env:USERPROFILE\JD").Self.InvokeVerb("pintohome")

# Unpin all apps from the start menu
Write-Output "Unpinning all Start Menu tiles..."
If ([System.Environment]::OSVersion.Version.Build -ge 15063 -And [System.Environment]::OSVersion.Version.Build -le 16299) {
    Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Include "*.group" -Recurse | ForEach-Object {
        $data = (Get-ItemProperty -Path "$($_.PsPath)\Current" -Name "Data").Data -Join ","
        $data = $data.Substring(0, $data.IndexOf(",0,202,30") + 9) + ",0,202,80,0,0"
        Set-ItemProperty -Path "$($_.PsPath)\Current" -Name "Data" -Type Binary -Value $data.Split(",")
    }
} ElseIf ([System.Environment]::OSVersion.Version.Build -ge 17134) {
    $key = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current"
    $data = $key.Data[0..25] + ([byte[]](202,50,0,226,44,1,1,0,0))
    Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $data
    Stop-Process -Name "ShellExperienceHost" -Force -ErrorAction SilentlyContinue
}

# Unpin all taskbar icons
Write-Output "Unpinning all Taskbar icons..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "Favorites" -Type Binary -Value ([byte[]](255))
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "FavoritesResolve" -ErrorAction SilentlyContinue

# Hide 'Recently added' list from the Start Menu
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideRecentlyAddedApps" -Type DWord -Value 1

###############################################################################
### MS Office Settings                                                        #
###############################################################################

If (Test-Path "HKLM:\SOFTWARE\Classes\Word.Application") {
    $MSWord = new-object -com word.application
    $MSWord.visible = $false
    
    $auc = $MSWord.autoCorrect
    $auc.correctInitialCaps             = $false   #   Correct TWo INitial CApitals
    $auc.correctSentenceCaps            = $false   #   Capitalize first letter of sentences
    $auc.correctTableCells              = $false   #   Capitalize first letter of table cells
    
    $opt = $MSWord.options
    $opt.ignoreInternetAndFileAddresses = $false   #   Ignore Internet and file addresses
    $opt.repeatWord                     = $true    #   Flag repeated words
    $opt.ignoreUppercase                = $false   #   Ignore words in UPPERCASE
    $opt.checkSpellingAsYouType         = $true    #   Check-spelling as you type
    $opt.checkGrammarAsYouType          = $true    #   Mark grammar errors as you type
    $opt.contextualSpeller              = $true    #   Frequently confused words
    $opt.checkGrammarWithSpelling       = $true    #   Check grammar with spelling
    
    $MSWord.quit()
} else {
	Write-host "Microsoft Word is not installed. Skipping MS Word Configuration"
}

###############################################################################
### File Associations                                                         #
###############################################################################

# Run './utils/SetUserFTA.exe get' to get all file associations

# Set 7zip as default for all archives
reg import .\system_scripts\7z\7z_create_file_associations.reg
.\utils\SetUserFTA.exe .\system_scripts\7z\7z_file_associations_config.txt

###############################################################################
### Default Windows Applications                                              #
###############################################################################
Write-Host "Configuring Default Windows Applications..." -ForegroundColor "Yellow"

$bloatApps = @(
    "2414FC7A.Viber",
    "41038Axilesoft.ACGMediaPlayer",
    "46928bounde.EclipseManager",
    "4DF9E0F8.Netflix",
    "64885BlueEdge.OneCalendar",
    "7EE7776C.LinkedInforWindows",
    "828B5831.HiddenCityMysteryofShadows",
    "89006A2E.AutodeskSketchBook",
    "9E2F88E3.Twitter",
    "A278AB0D.DisneyMagicKingdoms",
    "A278AB0D.DragonManiaLegends",
    "A278AB0D.MarchofEmpires",
    "ActiproSoftwareLLC.562882FEEB491",
    "AD2F1837.GettingStartedwithWindows8",
    "AD2F1837.HPJumpStart",
    "AD2F1837.HPRegistration",
    "AdobeSystemsIncorporated.AdobePhotoshopExpress",
    "Amazon.com.Amazon",
    "C27EB4BA.DropboxOEM",
    "CAF9E577.Plex",
    "CyberLinkCorp.hs.PowerMediaPlayer14forHPConsumerPC",
    "D52A8D61.FarmVille2CountryEscape",
    "D5EA27B7.Duolingo-LearnLanguagesforFree",
    "DB6EA5DB.CyberLinkMediaSuiteEssentials",
    "DolbyLaboratories.DolbyAccess",
    "Drawboard.DrawboardPDF",
    "Facebook.Facebook",
    "Fitbit.FitbitCoach",
    "flaregamesGmbH.RoyalRevolt2",
    "GAMELOFTSA.Asphalt8Airborne",
    "KeeperSecurityInc.Keeper",
    "king.com.BubbleWitch3Saga",
    "king.com.CandyCrushFriends",
    "king.com.CandyCrushSaga",
    "king.com.CandyCrushSodaSaga",
    "king.com.FarmHeroesSaga",
    "Nordcurrent.CookingFever",
    "PandoraMediaInc.29680B314EFC2",
    "PricelinePartnerNetwork.Booking.comBigsavingsonhot",
    "SpotifyAB.SpotifyMusic",
    "ThumbmunkeysLtd.PhototasticCollage",
    "WinZipComputing.WinZipUniversal",
    "XINGAG.XING",

    "Microsoft.3DBuilder",
    "Microsoft.AppConnector",
    "Microsoft.BingFinance",
    "Microsoft.BingFoodAndDrink",
    "Microsoft.BingHealthAndFitness",
    "Microsoft.BingMaps",
    "Microsoft.BingNews",
    "Microsoft.BingSports",
    "Microsoft.BingTranslator",
    "Microsoft.BingTravel",
    "Microsoft.BingWeather",
    "Microsoft.CommsPhone",
    "Microsoft.ConnectivityStore",
    "Microsoft.FreshPaint",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.HelpAndTips",
    "Microsoft.Media.PlayReadyClient.2",
    "Microsoft.Messaging",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftPowerBIForWindows",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MinecraftUWP",
    "Microsoft.MixedReality.Portal",
    "Microsoft.MoCamera",
    "Microsoft.NetworkSpeedTest",
    "Microsoft.OfficeLens",
    "Microsoft.Office.OneNote",
    "Microsoft.Office.Sway",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.Print3D",
    "Microsoft.Reader",
    "Microsoft.SkypeApp",
    "Microsoft.Todos",
    "Microsoft.Wallet",
    "Microsoft.WebMediaExtensions",
    "Microsoft.Whiteboard",
    "Microsoft.WindowsAlarms",
    "microsoft.windowscommunicationsapps",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsPhone",
    "Microsoft.WindowsReadingList",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.Advertising.Xaml"
)

foreach ($appName in $bloatApps) {
    Get-AppxPackage $appName -AllUsers | Remove-AppxPackage
    Get-AppXProvisionedPackage -Online | Where-Object DisplayNam -like $appName | Remove-AppxProvisionedPackage -Online
}

# Uninstall Windows Media Player
Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null

# Disable Application suggestions and automatic installation
Write-Output "Disabling Application suggestions..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-314559Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace" -Name "AllowSuggestedAppsInWindowsInkWorkspace" -Type DWord -Value 0
# Empty placeholder tile collection in registry cache and restart Start Menu process to reload the cache
If ([System.Environment]::OSVersion.Version.Build -ge 17134) {
    $key = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*windows.data.placeholdertilecollection\Current"
    Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $key.Data[0..15]
    Stop-Process -Name "ShellExperienceHost" -Force -ErrorAction SilentlyContinue
}

# Restart explorer.exe
Stop-Process -ProcessName explorer

###############################################################################
### Accessibility and Ease of Use                                             #
###############################################################################
Write-Host "Configuring Accessibility..." -ForegroundColor "Yellow"

# Turn Off Windows Narrator
if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe")) {New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe" -Type Folder | Out-Null}
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe" "Debugger" "%1"

# Disable showing what can be snapped next to a window
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SnapAssist" 0

# Disable auto-correct
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\TabletTip\1.7" "EnableAutocorrection" 0

###############################################################################
### Internet Explorer                                                         #
###############################################################################
Write-Host "Configuring Internet Explorer..." -ForegroundColor "Yellow"

# Set home page to `about:blank` for faster loading
Set-ItemProperty "HKCU:\Software\Microsoft\Internet Explorer\Main" "Start Page" "about:blank"

# Disable 'Default Browser' check: "yes" or "no"
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main" "Check_Associations" "no"

# Disable Password Caching [Disable Remember Password]
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" "DisablePasswordCaching" 1

###############################################################################
### Fonts                                                                     #
###############################################################################

$fontCSIDL = 0x14
$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace($fontCSIDL)
$fontPath = Join-Path (Split-Path -parent $profile) "fonts\*.ttf"
Get-ChildItem $fontPath | ForEach-Object {
    if ((Test-Path "$($env:LOCALAPPDATA)\Microsoft\Windows\Fonts\$($_.Name)") -eq $False)
    {
        $objFolder.CopyHere($_.FullName) 
    }
}
Remove-Variable fontPath
Remove-Variable objFolder
Remove-Variable objShell
Remove-Variable fontCSIDL

###############################################################################
### PowerShell Console                                                        #
###############################################################################
Write-Host "Configuring Console..." -ForegroundColor "Yellow"

#Reference: http://michaellwest.blogspot.com/2013/03/add-font-to-powershell-console.html
#Reference: http://support.microsoft.com/default.aspx?scid=KB;EN-US;Q247815 This explains why we name it 000
# Make 'Source Code Pro' an available Console font
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont' -Name 000 -Value 'Source Code Pro'

# Create custom path for PSReadLine Settings
if (!(Test-Path "HKCU:\Console\PSReadLine")) {New-Item -Path "HKCU:\Console\PSReadLine" -Type Folder | Out-Null}

# PSReadLine: Normal syntax color. vim Normal group. (Default: Foreground)
Set-ItemProperty "HKCU:\Console\PSReadLine" "NormalForeground" 0xF

# PSReadLine: Comment Token syntax color. vim Comment group. (Default: 0x2)
Set-ItemProperty "HKCU:\Console\PSReadLine" "CommentForeground" 0x7

# PSReadLine: Keyword Token syntax color. vim Statement group. (Default: 0xA)
Set-ItemProperty "HKCU:\Console\PSReadLine" "KeywordForeground" 0x1

# PSReadLine: String Token syntax color. vim String [or Constant] group. (Default: 0x3)
Set-ItemProperty "HKCU:\Console\PSReadLine" "StringForeground"  0xA

# PSReadLine: Operator Token syntax color. vim Operator [or Statement] group. (Default: 0x8)
Set-ItemProperty "HKCU:\Console\PSReadLine" "OperatorForeground" 0xB

# PSReadLine: Variable Token syntax color. vim Identifier group. (Default: 0xA)
Set-ItemProperty "HKCU:\Console\PSReadLine" "VariableForeground" 0xB

# PSReadLine: Command Token syntax color. vim Function [or Identifier] group. (Default: 0xE)
Set-ItemProperty "HKCU:\Console\PSReadLine" "CommandForeground" 0x1

# PSReadLine: Parameter Token syntax color. vim Normal group. (Default: 0x8)
Set-ItemProperty "HKCU:\Console\PSReadLine" "ParameterForeground" 0xF

# PSReadLine: Type Token syntax color. vim Type group. (Default: 0x7)
Set-ItemProperty "HKCU:\Console\PSReadLine" "TypeForeground" 0xE

# PSReadLine: Number Token syntax color. vim Number [or Constant] group. (Default: 0xF)
Set-ItemProperty "HKCU:\Console\PSReadLine" "NumberForeground" 0xC

# PSReadLine: Member Token syntax color. vim Function [or Identifier] group. (Default: 0x7)
Set-ItemProperty "HKCU:\Console\PSReadLine" "MemberForeground" 0xE

# PSReadLine: Emphasis syntax color. vim Search group. (Default: 0xB)
Set-ItemProperty "HKCU:\Console\PSReadLine" "EmphasisForeground" 0xD

# PSReadLine: Error syntax color. vim Error group. (Default: 0xC)
Set-ItemProperty "HKCU:\Console\PSReadLine" "ErrorForeground" 0x4

@(`
"HKCU:\Console\%SystemRoot%_System32_bash.exe",`
"HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe",`
"HKCU:\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe",`
"HKCU:\Console\Windows PowerShell (x86)",`
"HKCU:\Console\Windows PowerShell",`
"HKCU:\Console"`
) | ForEach-Object {
    If (!(Test-Path $_)) {
        New-Item -path $_ -ItemType Folder | Out-Null
    }

# Dimensions of window, in characters: 8-byte; 4b height, 4b width. Max: 0x7FFF7FFF (32767h x 32767w)
Set-ItemProperty $_ "WindowSize"           0x002D0078 # 45h x 120w
# Dimensions of screen buffer in memory, in characters: 8-byte; 4b height, 4b width. Max: 0x7FFF7FFF (32767h x 32767w)
Set-ItemProperty $_ "ScreenBufferSize"     0x0BB80078 # 3000h x 120w
# Percentage of Character Space for Cursor: 25: Small, 50: Medium, 100: Large
Set-ItemProperty $_ "CursorSize"           100
# Name of display font
Set-ItemProperty $_ "FaceName"             "Source Code Pro"
# Font Family: Raster: 0, TrueType: 54
Set-ItemProperty $_ "FontFamily"           54
# Dimensions of font character in pixels, not Points: 8-byte; 4b height, 4b width. 0: Auto
Set-ItemProperty $_ "FontSize"             0x00110000 # 17px height x auto width
# Boldness of font: Raster=(Normal: 0, Bold: 1), TrueType=(100-900, Normal: 400)
Set-ItemProperty $_ "FontWeight"           400
# Number of commands in history buffer
Set-ItemProperty $_ "HistoryBufferSize"    50
# Discard duplicate commands
Set-ItemProperty $_ "HistoryNoDup"         1
# Typing Mode: Overtype: 0, Insert: 1
Set-ItemProperty $_ "InsertMode"           1
# Enable Copy/Paste using Mouse
Set-ItemProperty $_ "QuickEdit"            1
# Background and Foreground Colors for Window: 2-byte; 1b background, 1b foreground; Color: 0-F
Set-ItemProperty $_ "ScreenColors"         0x0F
# Background and Foreground Colors for Popup Window: 2-byte; 1b background, 1b foreground; Color: 0-F
Set-ItemProperty $_ "PopupColors"          0xF0
# Adjust opacity between 30% and 100%: 0x4C to 0xFF -or- 76 to 255
Set-ItemProperty $_ "WindowAlpha"          0xF2

# The 16 colors in the Console color well (Persisted values are in BGR).
# Theme: Jellybeans
Set-ItemProperty $_ "ColorTable00"         $(Convert-ConsoleColor "#151515") # Black (0)
Set-ItemProperty $_ "ColorTable01"         $(Convert-ConsoleColor "#8197bf") # DarkBlue (1)
Set-ItemProperty $_ "ColorTable02"         $(Convert-ConsoleColor "#437019") # DarkGreen (2)
Set-ItemProperty $_ "ColorTable03"         $(Convert-ConsoleColor "#556779") # DarkCyan (3)
Set-ItemProperty $_ "ColorTable04"         $(Convert-ConsoleColor "#902020") # DarkRed (4)
Set-ItemProperty $_ "ColorTable05"         $(Convert-ConsoleColor "#540063") # DarkMagenta (5)
Set-ItemProperty $_ "ColorTable06"         $(Convert-ConsoleColor "#dad085") # DarkYellow (6)
Set-ItemProperty $_ "ColorTable07"         $(Convert-ConsoleColor "#888888") # Gray (7)
Set-ItemProperty $_ "ColorTable08"         $(Convert-ConsoleColor "#606060") # DarkGray (8)
Set-ItemProperty $_ "ColorTable09"         $(Convert-ConsoleColor "#7697d6") # Blue (9)
Set-ItemProperty $_ "ColorTable10"         $(Convert-ConsoleColor "#99ad6a") # Green (A)
Set-ItemProperty $_ "ColorTable11"         $(Convert-ConsoleColor "#c6b6ee") # Cyan (B)
Set-ItemProperty $_ "ColorTable12"         $(Convert-ConsoleColor "#cf6a4c") # Red (C)
Set-ItemProperty $_ "ColorTable13"         $(Convert-ConsoleColor "#f0a0c0") # Magenta (D)
Set-ItemProperty $_ "ColorTable14"         $(Convert-ConsoleColor "#fad07a") # Yellow (E)
Set-ItemProperty $_ "ColorTable15"         $(Convert-ConsoleColor "#e8e8d3") # White (F)
}

# Remove property overrides from PowerShell and Bash shortcuts
Reset-AllPowerShellShortcuts
Reset-AllBashShortcuts

Write-Host "Done. Note that some of these changes require a logout/restart to take effect."