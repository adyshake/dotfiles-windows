# Adnan Shaikh's dotfiles for Windows

A collection of PowerShell files for Windows, including common application installation through `Chocolatey` and developer-minded Windows configuration defaults. 

## Installation

> **Note:** You must have your execution policy set to unrestricted (or at least in bypass) for this to work. To set this, run `Set-ExecutionPolicy Unrestricted` from a PowerShell running as Administrator.

### Using Git and the bootstrap script

You can clone the repository wherever you want. The bootstrapper script will copy the files to your PowerShell Profile folder.

From PowerShell:
```posh
git clone https://github.com/adyshake/dotfiles-windows.git; cd dotfiles-windows; . .\bootstrap.ps1
```

### Git-free install

To install these dotfiles from PowerShell without Git:

```bash
iex ((new-object net.webclient).DownloadString('https://raw.github.com/adyshake/dotfiles-windows/master/setup/install.ps1'))
```

To update later on, just run that command again.

### After Install
To set some Windows defaults and features, such as Explorer and privacy settings, run the following script

```post
.\windows.ps1
```

To install common packages, utilities and dependencies, run this script next

```post
.\deps.ps1
```

## Thanks to…

Jay Harris' repo [dotfiles-windows](https://github.com/jayharris/dotfiles-windows) from which this repo is based on.