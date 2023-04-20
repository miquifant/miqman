# XYZMAN - TODO Name (XYZ Manager)

TODO Description

Content

* [Objective](#objective)
* [Install](#install)
* [Usage](#usage)

## Objective

TODO Objective

## Install

### Prerequisites for Windows users

In order to use XYZMAN from Windows, you can install following elements previously<sup>*</sup>:

- **MobaXterm** from [here](https://mobaxterm.mobatek.net/download-home-edition.html)
- **Git** plugin from [here](https://mobaxterm.mobatek.net/plugins.html)

<sup>\* Probably you could also use cygwin, gitbash or WSL, but this tool is not tested with them.</sup>

### XYZMAN installation

For installing XYZMAN, just execute this from your command line:

```bash
bash <(curl -ks https://raw.githubusercontent.com/miquifant/xyzman/main/install-xyzman.sh)
```

### What is being installed on my machine?

Install script will create or update following elements at the user's home:

- `.xyzman/`        - Here it will be all _Xyzman_ software
- `.config/xyzman/` - Here it will be the user's config of the tool
- `.bashrc`         - Install process will insert two lines in .bashrc file, that you'll find with the _TAG_ `# XYZMAN`
- `.zshrc`          - The same way, two lines will be inserted in .zsh file
- `.gitconfig`      - If it wasn't yet, install process will disable `http.sslverify` parameter (asking first). Only for intranet environments

### XYZMAN uninstall

Except for that last change, all changes made by the install script can be reverted using uninstall script:

```bash
~/.xyzman/bin/uninstall-aceman.sh
```

By default, it will keep the user configuration files,
although they can also be deleted, if the user requests it during the uninstall process


## Usage

All XYZMAN functionality is available through the `xyz` tool,
which will be followed by the command to execute.

```
Usage: xyz <command>

   commands:
       config    or c             Configures Xyzman
       ...
       version   or v
       help
       update           [force]   Updates Xyzman to the current version
```
