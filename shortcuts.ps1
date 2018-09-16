# Unpin everything from the start menu
$startMenuItems = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items()
ForEach ($item in $startMenuItems) {
    $item.Verbs() | Where-Object {$_.Name.replace('&','') -match 'Unpin from Start'} | ForEach-Object {$_.DoIt()}
}

# Unpin everything from the taskbar
Remove-Item -Path "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*" -Force -Recurse
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" "Favorites" ([byte[]](0xFF))
Remove-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband" "FavoritesResolve"
Stop-Process -ProcessName Explorer

# Pin Home folder and Projects folder to Quick Access 
$shell = New-Object -Com "Shell.Application"  
$projectFolder = Join-Path $env:USERPROFILE "Projects"
New-Item $projectFolder -ItemType Directory -Force -ErrorAction SilentlyContinue

$shell.Namespace("$env:USERPROFILE").Self.InvokeVerb("pintohome")
$shell.Namespace("$projectFolder").Self.InvokeVerb("pintohome")