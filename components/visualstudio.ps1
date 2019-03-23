# Configure Visual Studio
if ((Test-Path "hklm:\SOFTWARE\Microsoft\VisualStudio\SxS\VS7") -or (Test-Path "hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VS7")) {
    # Add a folder to $env:Path
    function Append-EnvPath([String]$path) { $env:PATH = $env:PATH + ";$path" }
    function Append-EnvPathIfExists([String]$path) { if (Test-Path $path) { Append-EnvPath $path } }

    $vsRegistry = Get-Item "hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VS7" -ErrorAction SilentlyContinue
    if ($null -eq $vsRegistry) { $vsRegistry = Get-Item "hklm:\SOFTWARE\Microsoft\VisualStudio\SxS\VS7" }
    $vsVersion  = $vsRegistry.property | Sort-Object {[int]$_} -Descending | Select-Object -first 1
    $vsinstall  = ForEach-Object -process {$vsRegistry.GetValue($vsVersion)}
    Remove-Variable vsRegistry

    if ((Test-Path $vsinstall) -eq 0) {Write-Error "Unable to find Visual Studio installation"}

    $env:VisualStudioVersion = $vsVersion
    $env:Framework40Version  = "v4.0"
    $env:VSINSTALLDIR = $vsinstall
    $env:DevEnvDir    =  Join-Path $vsinstall "Common7\IDE\"
    Remove-Variable vsinstall

    $vsInstallerPath = Split-Path -parent $env:VSINSTALLDIR
    $vsInstallerPath = Split-Path -parent $vsInstallerPath

    Append-EnvPathIfExists (Join-Path $vsInstallerPath "Installer")

    $installationPath = vswhere.exe -prerelease -latest -property installationPath
    if ($installationPath -and (test-path "$installationPath\Common7\Tools\vsdevcmd.bat")) {
        & "${env:COMSPEC}" /s /c "`"$installationPath\Common7\Tools\vsdevcmd.bat`"  -arch=amd64 -host_arch=amd64 -no_logo && set" | foreach-object {
            $name, $value = $_ -split '=', 2
            set-content env:\"$name" $value
        }
    }
    
    # Configure Visual Studio functions
    function Start-VisualStudio ([string] $solutionFile) {
        $devenv = Join-Path $env:DevEnvDir "devenv.exe"
        if (($solutionFile -eq $null) -or ($solutionFile -eq "")) {
            $solutionFile = (Get-ChildItem -Filter "*.sln" | Select-Object -First 1).Name
        }
        if (($null -ne $solutionFile) -and ($solutionFile -ne "") -and (Test-Path $solutionFile)) {
            Start-Process $devenv -ArgumentList $solutionFile
        } else {
            Start-Process $devenv
        }
    }
    Set-Alias -name vs -Value Start-VisualStudio

    function Start-VisualStudioAsAdmin ([string] $solutionFile) {
        $devenv = Join-Path $env:DevEnvDir "devenv.exe"
        if (($solutionFile -eq $null) -or ($solutionFile -eq "")) {
            $solutionFile = (Get-ChildItem -Filter "*.sln" | Select-Object -First 1).Name
        }
        if (($null -ne $solutionFile) -and ($solutionFile -ne "") -and (Test-Path $solutionFile)) {
            Start-Process $devenv -ArgumentList $solutionFile -Verb "runAs"
        } else {
            Start-Process $devenv -Verb "runAs"
        }
    }
    Set-Alias -name vsadmin -Value Start-VisualStudioAsAdmin
}
