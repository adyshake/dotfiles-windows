# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
    Start-Process powershell -Verb runAs -ArgumentList @("-NoExit", "-Command `"cd `'$(([string](Get-Location)).TrimEnd('\'))`'; $($myInvocation.MyCommand.Definition)`"")
    exit
}

Unregister-Event -SourceIdentifier graphicsCardChanged -ErrorAction SilentlyContinue
Register-WmiEvent -Class Win32_DeviceChangeEvent -SourceIdentifier graphicsCardChanged

# Get inital eGPU state
$GPUConnected = $false
if ($null -ne (Get-PnpDevice | Where-Object {($_.friendlyname) -like "Radeon RX 590*" -and ($_.status) -like "Ok"})) {
    # Write-Host("eGPU is initially connected")
    $GPUConnected = $true
}
do{
    $newEvent = Wait-Event -SourceIdentifier graphicsCardChanged
    $eventType = $newEvent.SourceEventArgs.NewEvent.EventType
    #Write-Host($eventType)
    
    if ($GPUConnected -eq $false) {
        $isEGPUConnected = $null -ne (Get-PnpDevice | Where-Object {($_.friendlyname) -like "Radeon RX 590*" -and ($_.status) -like "Ok"})
        if ($eventType -eq 2 -and $isEGPUConnected) {
            #Event - Device Arrival
            # Write-Host("Device Arrived")
            Get-PnpDevice| Where-Object {$_.friendlyname -like "Intel(R) Iris(R) Plus Graphics*"} | Disable-PnpDevice -Confirm:$false
            $GPUConnected = $true
        }
    }

    if ($GPUConnected -eq $true -and $eventType -eq 1 -or $eventType -eq 3) {
        #Event - Device config changed
        # For some reason when I plug out the Razer Core X, it doesn't send an
        # event type 3 signal, so I'm working with config changed instead.
        # Write-Host("Device config changed")
        $isEGPUUnknown = $null -ne (Get-PnpDevice | Where-Object {($_.friendlyname) -like "Radeon RX 590*" -and ($_.status) -like "Unknown"})
        if ($isEGPUUnknown) {
            # Write-Host("eGPU is Unknown")
            Get-PnpDevice| Where-Object {$_.friendlyname -like "Intel(R) Iris(R) Plus Graphics*"} | Enable-PnpDevice -Confirm:$false
            $GPUConnected = $false
        }
    }	
    Remove-Event -SourceIdentifier graphicsCardChanged
} while (1-eq1) #Loop until next event
Unregister-Event -SourceIdentifier graphicsCardChanged


