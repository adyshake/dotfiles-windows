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

### Sensible Windows defaults

When setting up a new Windows PC, you may want to set some Windows defaults and features, such as showing hidden files in Windows Explorer and installing IIS. This will also set your machine name and full user name, so you may want to modify this file before executing.

```post
.\windows.ps1
```

### Install dependencies and packages

When setting up a new Windows box, you may want to install some common packages, utilities, and dependencies. These could include node.js packages via [NPM](https://www.npmjs.org), [Chocolatey](http://chocolatey.org/) packages, Windows Features and Tools via [Web Platform Installer](https://www.microsoft.com/web/downloads/platform.aspx), and Visual Studio Extensions from the [Visual Studio Gallery](http://visualstudiogallery.msdn.microsoft.com/).

```posh
.\deps.ps1
```

> The scripts will install Chocolatey & scoop if necessary.

This is to get Beeminder off my ass.

## Thanks to…

Jay Harris' repo [dotfiles-windows](https://github.com/jayharris/dotfiles-windows) from which this repo is based on.