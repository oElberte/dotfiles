# dotfiles

Personal CachyOS / Linux dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

Covers shell, terminal emulators, editors, git, KDE theming, and AI tooling config. Browser profiles, secrets, and other stateful data are intentionally **out of scope** — they need manual backup before reinstalling the OS. See [Manual backup](#manual-backup-not-managed-by-chezmoi).

## Quickstart

On a fresh machine:

```bash
# 1. Install chezmoi
sudo pacman -S chezmoi

# 2. Initialize from this repo
chezmoi init git@github.com:oElberte/dotfiles.git

# 3. Preview what will change in $HOME
chezmoi diff

# 4. Apply
chezmoi apply -v
```

Daily use:

```bash
chezmoi edit ~/.zshrc      # edit a tracked file (chezmoi opens source copy)
chezmoi apply              # push staged changes into $HOME
chezmoi cd                 # jump into the source repo
git add -A && git commit -m "..." && git push
chezmoi update             # git pull && chezmoi apply
```

## What's managed

- **Shell**: `.zshrc`, `.p10k.zsh`, `.bashrc`, `.bash_profile`
- **Git**: `.gitconfig`, `~/.config/git/`
- **Terminals**: `~/.config/alacritty/`, `~/.config/ghostty/`, `~/.config/fish/`
- **Editors**: `~/.config/Code/User/{settings,keybindings,snippets}.json`, `~/.config/kate/`, `nvim/`
- **KDE / desktop**: `~/.config/{kdeglobals,kwinrc,plasmarc,kglobalshortcutsrc,konsolerc,dolphinrc,baloofilerc}`, `~/.config/gtk-3.0/`, `~/.config/gtk-4.0/`, `.gtkrc-2.0`
- **Fonts / input**: `~/.config/fontconfig/`, `.XCompose`
- **AI tooling config** (settings only — no credentials, no history): `~/.claude/settings*.json`, `~/.claude/CLAUDE.md`, `~/.claude/rules/`, `~/.codex/config*`, `.context7/config*`, `caveman/`, `.agents/`

## Manual backup (not managed by chezmoi)

Chezmoi is built for small, hand-edited text files. The items below are either too large, too sensitive, or too stateful for git and must be snapshotted manually **before** reformatting.

### Browser profiles — Zen, Firefox, Chrome

A full profile contains cookies, history, saved logins, extensions, and open tabs. To carry an exact session across a reinstall, tar the profile dirs while browsers are **closed**:

```bash
# Close all browsers first.
mkdir -p ~/browser-backup

tar --zstd -cf ~/browser-backup/zen.tar.zst     -C ~        .zen
tar --zstd -cf ~/browser-backup/firefox.tar.zst -C ~        .mozilla
tar --zstd -cf ~/browser-backup/chrome.tar.zst  -C ~/.config google-chrome
```

Restore on the new install (again, browsers closed):

```bash
tar --zstd -xf ~/browser-backup/zen.tar.zst     -C ~
tar --zstd -xf ~/browser-backup/firefox.tar.zst -C ~
tar --zstd -xf ~/browser-backup/chrome.tar.zst  -C ~/.config
```

**Lighter alternative — built-in sync:** Firefox Sync, Zen Sync (Firefox-based), Chrome Sync. Handles bookmarks, history, logins, tabs, extensions automatically, no tarballs.

**Security note:** these tarballs contain live session cookies. Keep them off shared drives; prefer encrypting (see [Secrets](#secrets--ssh-gpg-api-tokens) below for the `age` pattern).

### Secrets — SSH, GPG, API tokens

Private keys and tokens. **Never** commit to git, even inside this repo. Encrypt with [age](https://github.com/FiloSottile/age) before moving off the machine.

One-time key setup:

```bash
age-keygen -o ~/age-identity.txt
age-keygen -y ~/age-identity.txt > ~/age-recipients.txt
chmod 0600 ~/age-identity.txt
```

**Store `age-identity.txt` off the backup drive** — password manager attachment, printed QR, separate offline USB. Lose the identity = backup is unrecoverable.

Backup:

```bash
tar -cf - -C ~ .ssh .gnupg | \
  age -R ~/age-recipients.txt -o ~/secrets.tar.age
sha256sum ~/secrets.tar.age > ~/secrets.tar.age.sha256
```

Restore:

```bash
sha256sum -c ~/secrets.tar.age.sha256
age -d -i /path/to/age-identity.txt ~/secrets.tar.age | tar -xf - -C ~
chmod 700 ~/.ssh ~/.gnupg
ssh-add -l               # confirm keys load
gpg --list-secret-keys   # confirm GPG
```

**Filesystem warning:** exFAT/NTFS external drives strip Unix permissions. SSH refuses to load world-readable keys. Stage on a local ext4/btrfs filesystem and only move the opaque `.age` file to the external drive.

### Shell history

Personal log, small, optional:

```bash
mkdir -p ~/history-backup
cp ~/.zsh_history ~/.bash_history ~/history-backup/ 2>/dev/null || true
```

### Package lists

So a fresh install gets the same stack back:

```bash
pacman -Qqen > ~/packages-explicit.txt                          # official repos
pacman -Qqem > ~/packages-aur.txt                               # AUR
flatpak list --app --columns=application > ~/flatpaks.txt
```

Restore:

```bash
xargs -r -a packages-explicit.txt sudo pacman -S --needed
xargs -r -a packages-aur.txt      paru -S --needed              # or yay
xargs -r -a flatpaks.txt          flatpak install -y flathub
```

### AI tool state (optional)

Tool *config* is in this repo. Tool *state* (tokens, conversation memory, embedding DBs) is not:

| Path                | Contents                              |
|---------------------|---------------------------------------|
| `~/.claude.json`    | Claude Code auth / session            |
| `~/.claude-mem/`    | Claude memory DB                      |
| `~/.hermes/`        | Hermes data                           |
| `~/.codex/` (state) | Codex session files (not `config*`)   |
| `~/.context7/`      | Context7 history                      |
| `~/.copilot/`       | GitHub Copilot token                  |

Snapshot if you want it back:

```bash
tar --zstd -cf ~/ai-state.tar.zst -C ~ \
  .claude.json .claude-mem .hermes .copilot .context7
```

Treat this like a secrets bundle — encrypt with age.

### System files

Outside `$HOME` but handy to keep:

```bash
mkdir -p ~/system-snapshot
sudo cp /etc/fstab /etc/hostname /etc/hosts ~/system-snapshot/
```

### What to deliberately skip

Regenerable — don't back up, reinstall fresh:

- `~/.cache/`, `~/.local/share/Trash/`
- Toolchain caches: `.nvm/`, `.bun/`, `.pub-cache/`, `.gradle/`, `.java/`, `.dotnet/`, `.dartServer/`, `.dart-tool/`, `.npm/`, `~/fvm/`, `~/go/`, `~/.android/avd/`
- `.steam/`, `.ollama/` — reinstall, let apps re-download
- Source repos in `Development/`, `Projects/`, `Documents/`, `Android/`, `ProgramsDev/` — these live on git remotes

## Reformat checklist

1. **Backup** → browser tarballs, `secrets.tar.age`, shell history, package lists, AI state, system files.
2. **Push** any pending chezmoi changes: `chezmoi cd && git push`.
3. **Reinstall** the OS.
4. **Packages** → pacman, AUR helper, flatpaks from the `.txt` lists.
5. **Dotfiles** → `chezmoi init git@github.com:oElberte/dotfiles.git && chezmoi apply`.
6. **Secrets** → decrypt `secrets.tar.age` into `$HOME`.
7. **Browsers** → extract tarballs (browsers closed).
8. **AI state** → decrypt and extract if kept.
9. **Verify** → `ssh-add -l`, `gpg --list-secret-keys`, re-login to pick up shell config, open each browser.

## License

[MIT](LICENSE).
