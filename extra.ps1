# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
Set-Environment "GIT_AUTHOR_NAME" "Adnan Shaikh"
Set-Environment "GIT_COMMITTER_NAME" $env:GIT_AUTHOR_NAME
Set-Environment "GIT_AUTHOR_EMAIL" "adnan.shaikh1806@gmail.com"
Set-Environment "GIT_COMMITTER_EMAIL" $env:GIT_AUTHOR_EMAIL
Set-Environment "GIT_REVIEW_BASE" "master"
if ($null -ne (Get-Command git -ErrorAction SilentlyContinue)) {
    git config --global user.name $env:GIT_AUTHOR_NAME
    git config --global user.email $env:GIT_AUTHOR_EMAIL
    git config --global core.excludesfile (Join-path $env:USERPROFILE "\.gitignore")
}