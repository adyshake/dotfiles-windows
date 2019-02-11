Param(
    [Parameter(Mandatory=$true)]
    [System.IO.FileInfo]$path
)

$file_formats = ('*.webm', '*.mkv', '*.flv', '*.ogg', '*.ogv', '*.avi', '*.mov',
                 '*.qt', '*.wmv', '*.amv', '*.mp4', '*.m4p', '*.m4v', '*.mpg',
                 '*.mp2', '*.mpeg', '*.mpe', '*.mpv', '*.m2v', '*.3gp', '*.3g2')
$suffix = "_ffmpeg"

$ip_files = Get-ChildItem $path -Recurse -Include $file_formats -Exclude $("*"+$suffix+"*")
if ($ip_files.Count -eq 0) {
    Write-Host "No footage found to be compressed" -ForegroundColor Yellow
    Return
}
$ip_total_size = [Math]::Round( ($ip_files | Measure-Object -Sum Length).Sum / 1GB, 2 )
Write-Host "Footage files to be compressed:" -ForegroundColor Yellow
$ip_files | ForEach-Object { Write-Host $_.Fullname -ForegroundColor DarkMagenta}
Write-Host "Size of uncompressed footage is" $ip_total_size "GB" -ForegroundColor Yellow
Write-Host "Begin conversion? (y/n)?" -ForegroundColor Yellow
$choice = Read-Host
if ($choice -eq "y" -or $choice -eq "Y") {
    $ip_files | ForEach-Object {
        Write-Host "Now converting" $_.FullName -ForegroundColor DarkMagenta
        ffmpeg -i "$($_.FullName)" -hide_banner -loglevel panic "-c:v" libx264 -crf 23 "-c:a" aac -map_metadata 0 "$(Join-Path $_.Directory ($_.BaseName + $suffix + '.mp4'))"
    }
    
    $op_files = Get-ChildItem $path -Recurse -Include $file_formats -Filter $("*"+$suffix+"*")
    $op_total_size = [Math]::Round( ($op_files | Measure-Object -Sum Length).Sum / 1GB, 2 )
    Write-Host "Size of compressed footage is" $op_total_size "GB" -ForegroundColor Yellow
    Write-Host "Data saved around" $($ip_total_size - $op_total_size) "GB" -ForegroundColor Yellow
    
    # Make sure at least some files have been generated before entering this scary code block
    if ($ip_files.Count -eq $op_files.Count) {
        Write-Host "Verify you want to delete the following uncompressed footage files:" -ForegroundColor Yellow
        $ip_files | ForEach-Object { Write-Host $_.Fullname -ForegroundColor DarkMagenta}
        Write-Host "Delete (y/n)?" -ForegroundColor Yellow
        $choice = Read-Host
        if ($choice -eq "y" -or $choice -eq "Y") {
            $ip_files | Remove-Item
            Write-Host "Deleted uncompressed footage" -ForegroundColor Green
        }
        else {
            Write-Host "Skipped deleting uncompressed footage" -ForegroundColor Green
        }
    }
    else {
        Write-Host "No files uncompressed files to delete" -ForegroundColor Green
    }
    if ($op_files.Count -gt 0) {
        Write-Host "Verify you want to remove the '$($suffix)' suffix from the following compressed footage files:" -ForegroundColor Yellow
        $op_files | ForEach-Object { Write-Host $_.Fullname -ForegroundColor DarkMagenta}
        Write-Host "Rename (y/n)?" -ForegroundColor Yellow
        $choice = Read-Host
        if ($choice -eq "y" -or $choice -eq "Y") {
            $op_files | Rename-Item -NewName {$_.Name -Replace $suffix, ""}
            Write-Host "Removed suffixes" -ForegroundColor Green
        }
        else {
            Write-Host "Skipped removing suffix" -ForegroundColor Green
        }
    }
    else {
        Write-Host "No suffixes to remove" -ForegroundColor Green
    }
}
else {
    Write-Host "No files converted" -ForegroundColor Green
}
