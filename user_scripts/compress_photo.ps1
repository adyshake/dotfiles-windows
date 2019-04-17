Param(
    [Parameter(Mandatory=$true)]
    [System.IO.FileInfo]$path
)

$file_formats = ('*.jpg', '*.jpeg')

$profileDir = Split-Path -parent $profile
$utilsDir = Join-Path $profileDir "utils"

$ip_files = Get-ChildItem $path -Recurse -Include $file_formats
if ($ip_files.Count -eq 0) {
    Write-Host "No photos found to be compressed" -ForegroundColor Yellow
    Return
}

$ip_total_size = [Math]::Round( ($ip_files | Measure-Object -Sum Length).Sum / 1MB, 2 )
Write-Host "Photos to be compressed:" -ForegroundColor Yellow
$ip_files | ForEach-Object { Write-Host $_.Fullname -ForegroundColor DarkMagenta}
Write-Host "Size of uncompressed photos is" $ip_total_size "MB" -ForegroundColor Yellow
Write-Host "Begin conversion? (y/n)?" -ForegroundColor Yellow

$choice = Read-Host
if ($choice -eq "y" -or $choice -eq "Y") {
    $optimized_dir_path = Join-Path $path "\optimized\"
    New-Item $optimized_dir_path -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    $ip_files | ForEach-Object {
        Write-Host "Now converting" $_.FullName -ForegroundColor DarkMagenta
        & "$utilsDir\jpegoptim.exe" "$($_.FullName)" -m80 -p -d "$($optimized_dir_path)\"
    }
    
    $op_files = Get-ChildItem $optimized_dir_path -Recurse -Include $file_formats
    $op_total_size = [Math]::Round( ($op_files | Measure-Object -Sum Length).Sum / 1MB, 2 )
    Write-Host "Size of compressed photos is" $op_total_size "MB" -ForegroundColor Yellow
    Write-Host "Data saved around" $($ip_total_size - $op_total_size) "MB" -ForegroundColor Yellow
    
    # Make sure at least some files have been generated before entering this scary code block
    if ($ip_files.Count -eq $op_files.Count) {
        Write-Host "Verify you want to delete the following uncompressed photos:" -ForegroundColor Yellow
        $ip_files | ForEach-Object { Write-Host $_.Fullname -ForegroundColor DarkMagenta}
        Write-Host "Delete (y/n)?" -ForegroundColor Yellow
        $choice = Read-Host
        if ($choice -eq "y" -or $choice -eq "Y") {
            $ip_files | Remove-Item
            Write-Host "Deleted uncompressed photos" -ForegroundColor Green
        }
        else {
            Write-Host "Skipped deleting uncompressed photos" -ForegroundColor Green
        }
    }
    else {
        Write-Host "No files uncompressed photos to delete" -ForegroundColor Green
    }
    if ($op_files.Count -gt 0) {
        Write-Host "Verify you want to move the compressed photos out of the ./optimized/ dir:" -ForegroundColor Yellow
        $op_files | ForEach-Object { Write-Host $_.Fullname -ForegroundColor DarkMagenta}
        Write-Host "Move (y/n)?" -ForegroundColor Yellow
        $choice = Read-Host
        if ($choice -eq "y" -or $choice -eq "Y") {
            $op_files | Move-Item -Destination $path
            Remove-Item $optimized_dir_path
            Write-Host "Moved compressed photos" -ForegroundColor Green
        }
        else {
            Write-Host "Skipped moving compressed photos" -ForegroundColor Green
        }
    }
    else {
        Write-Host "No photos to move" -ForegroundColor Green
    }
}
else {
    Write-Host "No photos compressed" -ForegroundColor Green
}
