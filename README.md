# Elberte's Dotfiles

Welcome to my dotfiles repository! This repo helps me manage configurations for Neovim and WezTerm, keeping my development setup consistent and portable. If you're cloning this for your own use, you're in the right place—let's get you set up quickly.

## Overview
This repository tracks my essential configs:
- **Neovim**: Custom settings for a streamlined coding experience (located in the `nvim/` directory).
- **WezTerm**: Terminal configurations for efficient workflows (located in the `wezterm/` directory).

These files are symlinked to their respective system locations (e.g., on Windows, Neovim at `C:\Users\Elberte\AppData\Local\nvim`). This setup makes it easy to sync changes across machines without conflicts.

## Prerequisites
Before you begin, ensure you have the following installed:
- **Git**: For cloning and managing the repository.
- **PowerShell**: Built into Windows; make sure it's up to date.
- **Neovim**: Download from [neovim.io](https://neovim.io) if you haven't already.
- **WezTerm**: Get it from [wezfurlong.org/wezterm](https://wezfurlong.org/wezterm/install.html).
- **Optional Tools**: If you're using advanced features, consider installing Git Bash, yadm (for dotfiles management), or GNU Stow (for symlinks).

## Quickstart Guide
Follow these steps to set up your environment after cloning the repository. This process uses symlinks to connect the repo files to your system without overwriting anything.

### 1. Clone the Repository
Open a terminal (e.g., PowerShell or WezTerm) and clone this repo to a convenient location, like your home directory:
```bash
git clone https://github.com/Elberte/dotfiles.git
cd dotfiles
```

### 2. Install Dependencies and Set Up Symlinks
Run the included setup script to create symlinks. This will link the configs in this repo to your system's default locations. **Note**: You may need to run PowerShell as an administrator for symlink creation to work properly.

- If you have the `install.ps1` script in this repo, run:
  ```powershell
  .\install.ps1
  ```
- If you don't have a script yet, you can manually create symlinks using PowerShell:
  ```powershell
  New-Item -ItemType SymbolicLink -Path "~\AppData\Local\nvim" -Target "$PWD\nvim"
  New-Item -ItemType SymbolicLink -Path "~\.wezterm.lua" -Target "$PWD\wezterm\.wezterm.lua"
  ```

This step ensures that changes in your system's configs are tracked in the repo, and vice versa.

### 3. Reload and Verify
- **For Neovim**: Open Neovim and run `:Lazy sync` (if you're using Lazy.nvim) or restart it to apply changes.
- **For WezTerm**: Restart WezTerm. Your keybindings and settings should now be active.
- Test everything:
  - In WezTerm, try your leader key (e.g., `CTRL + A + C` to open a new tab).
  - In Neovim, check if your plugins load correctly.

### 4. Customize and Commit Changes
- Make tweaks as needed! Edit files in the `nvim/` or `wezterm/` directories.
- Once you're happy, stage and commit your changes:
  ```bash
  git add .
  git commit -m "Update configs for [describe your changes]"
  git push
  ```

## Tips and Troubleshooting
- **Syncing Across Devices**: If you use this on another machine (e.g., Linux), adjust the paths in your setup script accordingly.
- **Common Issues**:
  - **Symlink Errors**: If you get permission errors, run PowerShell as administrator or check your system's symlink settings.
  - **Conflicts**: If Neovim or WezTerm complains about configs, ensure there are no existing files overriding the symlinks.
  - **Advanced Management**: For more automation, try tools like [yadm](https://yadm.io) or [GNU Stow](https://www.gnu.org/software/stow/). They can handle dotfiles more robustly.
- **Contributing**: Feel free to fork this repo and adapt it for your needs. Pull requests are welcome if you have improvements!

Thanks for checking out my dotfiles! If you have questions, feel free to open an issue on this repository. Happy coding! 🚀
