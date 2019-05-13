# Dotfiles for a serial yak shaver 🐑

Here ye, here ye. Welcome to the repo where most of my yak shaving happens. You'll find here my very own configuration scripts for Windows. I'd like to think this would come in handy when I need to hop around various virtual machines to really speed up my workflow (10x engineers, I'm looking at you). But to be honest, this has only come in handy whenever I've wiped my system by calling a recursive ```Remove-Item``` on the root directory. You'd think after the first incident I'd have learned to use the ```-WhatIf``` switch.

Having a consistent experience with Windows is difficult, even if you can manage it, it's short-lived. You can thank Microsoft's commitment to their incessant updates for that -- Not a rant but one could hope for registry keys that live longer than a year. There's a silver lining to all of this, as with all things that obey the laws of entropy, I have to keep adding to energy to the system. How else am I going to paint my GitHub tiles green so that I can delude myself into believing that I'm a _productive_ programmer.

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