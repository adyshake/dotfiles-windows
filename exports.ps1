# Make vim the default editor
Set-Environment "EDITOR" "gvim --nofork"
Set-Environment "GIT_EDITOR" $Env:EDITOR
Set-Environment "HOME" $env:USERPROFILE

# Disable the Progress Bar
#$ProgressPreference='SilentlyContinue'